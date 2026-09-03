#!/usr/bin/env bash
# build-prod-release.sh
# Builds a Google Play Store-ready .aab (Android App Bundle) for production release.
#
# Usage:
#   ./build-prod-release.sh            # Full production release build
#   ./build-prod-release.sh --dry-run  # Pre-checks and version info only — no build

set -eo pipefail

# ── Setup ──────────────────────────────────────────────────────────────────────

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_DIR"

# Colours
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Colour

pass() { echo -e "  ${GREEN}✔${NC}  $1"; }
fail() { echo -e "  ${RED}✗${NC}  $1"; exit 1; }
info() { echo -e "  ${BLUE}ℹ${NC}  $1"; }
warn() { echo -e "  ${YELLOW}⚠${NC}  $1"; }
step() { echo -e "\n${CYAN}▶${NC}  ${BOLD}$1${NC}"; }

# ── Parse flags ────────────────────────────────────────────────────────────────

DRY_RUN=0
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    *) echo -e "${RED}Unknown argument: $arg${NC}"; echo "Usage: $0 [--dry-run]"; exit 1 ;;
  esac
done

# ── Header ─────────────────────────────────────────────────────────────────────

echo ""
echo -e "${BLUE}══════════════════════════════════════════════════${NC}"
if [[ $DRY_RUN -eq 1 ]]; then
  echo -e "${BLUE}   🏗️  Flutter Production Release Build [DRY RUN]   ${NC}"
else
  echo -e "${BLUE}       🚀 Flutter Production Release Build          ${NC}"
fi
echo -e "${BLUE}══════════════════════════════════════════════════${NC}"
echo ""

# ── [1/5] Flutter check ────────────────────────────────────────────────────────

step "[1/5] Checking environment..."
if ! command -v flutter &> /dev/null; then
  fail "'flutter' command not found. Please install Flutter and make sure it is in your PATH."
fi
pass "Flutter found: $(flutter --version --machine 2>/dev/null | grep -o '"frameworkVersion":"[^"]*"' | cut -d'"' -f4 || flutter --version | head -1)"

# ── [2/5] Signing key check ────────────────────────────────────────────────────

KEY_PROPERTIES="$PROJECT_DIR/android/key.properties"
if [[ ! -f "$KEY_PROPERTIES" ]]; then
  fail "android/key.properties not found. A signing key is required for a production release build.\n     Run the signing setup first, or see verify-signing-key.sh for guidance."
fi
pass "android/key.properties found"

# ── [3/5] Version info ─────────────────────────────────────────────────────────

step "[2/5] Checking version..."

PUBSPEC="$PROJECT_DIR/pubspec.yaml"
LAST_RELEASE_FILE="$PROJECT_DIR/last-prod-release-version.txt"

# Read current version from pubspec.yaml
CURRENT_VERSION=$(grep -E '^version:' "$PUBSPEC" | sed 's/version:[[:space:]]*//' | tr -d '[:space:]')
if [[ -z "$CURRENT_VERSION" ]]; then
  fail "Could not read version from pubspec.yaml"
fi

# Parse versionName and versionCode
VERSION_NAME="${CURRENT_VERSION%%+*}"
VERSION_CODE="${CURRENT_VERSION##*+}"

echo ""
echo -e "  ${BOLD}Current version :${NC}  ${GREEN}${CURRENT_VERSION}${NC}  (name: ${VERSION_NAME}, code: ${VERSION_CODE})"

VERSION_SAME=0
if [[ -f "$LAST_RELEASE_FILE" ]]; then
  LAST_VERSION=$(cat "$LAST_RELEASE_FILE" | tr -d '[:space:]')
  echo -e "  ${BOLD}Last released   :${NC}  ${YELLOW}${LAST_VERSION}${NC}"
  if [[ "$CURRENT_VERSION" == "$LAST_VERSION" ]]; then
    VERSION_SAME=1
  fi
else
  echo -e "  ${BOLD}Last released   :${NC}  ${YELLOW}(no previous release recorded)${NC}"
fi

echo ""

if [[ $VERSION_SAME -eq 1 ]]; then
  BLINK_RED='\033[1;5;31m'
  echo -e "  ${BLINK_RED}⚠  VERSION ALERT  ⚠${NC}"
  warn "Version has NOT been bumped since the last release (${LAST_VERSION})."
  warn "Google Play will REJECT a duplicate versionCode (${VERSION_CODE})."
  warn "Run: ./manage-version.sh bump patch   (or minor/major)"
  echo ""
fi

GIT_TAG="releases/v${CURRENT_VERSION}"
info "Git tag that will be created on success: ${GIT_TAG}"

# ── Dry-run exit ───────────────────────────────────────────────────────────────

if [[ $DRY_RUN -eq 1 ]]; then
  echo ""
  echo -e "${YELLOW}══════════════════════════════════════════════════${NC}"
  echo -e "${YELLOW}  🏜️  DRY RUN complete — no build was performed.   ${NC}"
  echo -e "${YELLOW}══════════════════════════════════════════════════${NC}"
  echo ""
  echo "  The following would happen on a real build:"
  echo "    1. flutter clean && flutter pub get"
  echo "    2. flutter build appbundle --release --obfuscate --split-debug-info=..."
  echo "    3. Debug symbols zipped alongside .aab"
  echo "    4. verify-signing-key.sh run to confirm signing"
  echo "    5. last-prod-release-version.txt written: ${CURRENT_VERSION}"
  echo "    6. Git tag created: ${GIT_TAG}"
  echo ""
  exit 0
fi

# ── Confirmation prompt ────────────────────────────────────────────────────────

step "[3/5] Confirmation..."
echo ""
if [[ $VERSION_SAME -eq 1 ]]; then
  echo -e "  ${RED}${BOLD}⚠  Duplicate version detected. This build WILL be rejected by Google Play.${NC}"
  printf "  Proceed anyway? [y/N] "
else
  printf "  Proceed with production release build of ${GREEN}${BOLD}${CURRENT_VERSION}${NC}? [y/N] "
fi
read -r CONFIRM
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
  echo ""
  echo -e "  ${YELLOW}Build cancelled.${NC}"
  echo ""
  exit 0
fi

# ── [4/5] Build ────────────────────────────────────────────────────────────────

step "[4/5] Building..."
echo ""

echo -e "  ${CYAN}🧹 Cleaning previous build assets...${NC}"
flutter clean

echo ""
echo -e "  ${CYAN}📦 Fetching dependencies...${NC}"
flutter pub get

echo ""
echo -e "  ${CYAN}🏗️  Building release .aab (obfuscated, no debug symbols in bundle)...${NC}"
DEBUG_SYMBOLS_DIR="$PROJECT_DIR/build/debug-symbols"
flutter build appbundle --release \
  --obfuscate \
  --split-debug-info="$DEBUG_SYMBOLS_DIR"

# ── [5/5] Post-build ───────────────────────────────────────────────────────────

step "[5/5] Post-build tasks..."
echo ""

AAB_PATH="$PROJECT_DIR/build/app/outputs/bundle/release/app-release.aab"
AAB_DIR="$(dirname "$AAB_PATH")"
DEBUG_SYMBOLS_ZIP="$AAB_DIR/debug-symbols-v${CURRENT_VERSION}.zip"

# Display .aab info
if [[ -f "$AAB_PATH" ]]; then
  AAB_SIZE=$(du -h "$AAB_PATH" | cut -f1)
  pass ".aab built: $(realpath "$AAB_PATH") (${AAB_SIZE})"
else
  fail ".aab not found at expected path: $AAB_PATH"
fi

# Zip debug symbols alongside .aab
echo ""
echo -e "  ${CYAN}📦 Zipping debug symbols...${NC}"
if [[ -d "$DEBUG_SYMBOLS_DIR" ]] && [[ -n "$(ls -A "$DEBUG_SYMBOLS_DIR" 2>/dev/null)" ]]; then
  (cd "$DEBUG_SYMBOLS_DIR" && zip -r "$DEBUG_SYMBOLS_ZIP" . -x "*.DS_Store") \
    && pass "Debug symbols zipped: $(realpath "$DEBUG_SYMBOLS_ZIP") ($(du -h "$DEBUG_SYMBOLS_ZIP" | cut -f1))" \
    || warn "Failed to zip debug symbols (non-fatal)"
else
  warn "Debug symbols directory is empty or missing — skipping zip"
fi

# Verify signing
echo ""
echo -e "  ${CYAN}🔑 Verifying signing key...${NC}"
echo ""
"$PROJECT_DIR/verify-signing-key.sh"

# Write last-prod-release-version.txt
echo ""
echo "$CURRENT_VERSION" > "$LAST_RELEASE_FILE"
pass "Recorded release version: $LAST_RELEASE_FILE"

# Create git tag
echo ""
if git rev-parse --git-dir > /dev/null 2>&1; then
  if git rev-parse "$GIT_TAG" > /dev/null 2>&1; then
    warn "Git tag '${GIT_TAG}' already exists — skipping tag creation"
  else
    git tag "$GIT_TAG"
    pass "Git tag created: ${GIT_TAG}"
    info "Push the tag with: git push origin ${GIT_TAG}"
  fi
else
  warn "Not a git repository — skipping tag creation"
fi

# ── Summary ────────────────────────────────────────────────────────────────────

echo ""
echo -e "${GREEN}══════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  🎉 Production release build complete!           ${NC}"
echo -e "${GREEN}══════════════════════════════════════════════════${NC}"
echo ""
echo -e "  ${BOLD}Version        :${NC}  ${GREEN}${CURRENT_VERSION}${NC}"
echo -e "  ${BOLD}Git tag        :${NC}  ${GIT_TAG}"
echo ""
echo -e "  ${BOLD}Upload to Google Play Console:${NC}"
echo -e "    📦  .aab            :  $(realpath "$AAB_PATH")"
if [[ -f "$DEBUG_SYMBOLS_ZIP" ]]; then
  echo -e "    🐛  Debug symbols  :  $(realpath "$DEBUG_SYMBOLS_ZIP")"
fi
echo ""
echo -e "  ${BOLD}Next steps:${NC}"
echo -e "    1. Commit last-prod-release-version.txt if not already staged"
echo -e "    2. Push the git tag: git push origin ${GIT_TAG}"
echo -e "    3. Upload .aab to Google Play Console → Production track"
if [[ -f "$DEBUG_SYMBOLS_ZIP" ]]; then
  echo -e "    4. Upload debug-symbols zip in Play Console → App bundle → Details"
fi
echo ""
