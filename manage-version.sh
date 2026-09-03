#!/usr/bin/env bash
# manage-version.sh
# Inspect and update the app version in pubspec.yaml.
# The version in pubspec.yaml is the single source of truth; build.gradle.kts
# reads it via flutter.versionCode / flutter.versionName at build time.
#
# Usage:
#   ./manage-version.sh                # Show current version info
#   ./manage-version.sh set 1.2.0+3   # Set exact version
#   ./manage-version.sh bump patch     # Bump patch: 1.0.0+1 → 1.0.1+2
#   ./manage-version.sh bump minor     # Bump minor: 1.0.0+1 → 1.1.0+2
#   ./manage-version.sh bump major     # Bump major: 1.0.0+1 → 2.0.0+2

set -eo pipefail

# ── Setup ──────────────────────────────────────────────────────────────────────

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_DIR"

PUBSPEC="$PROJECT_DIR/pubspec.yaml"
LAST_RELEASE_FILE="$PROJECT_DIR/last-prod-release-version.txt"

# Colours
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Colour

pass()  { echo -e "  ${GREEN}✔${NC}  $1"; }
fail()  { echo -e "  ${RED}✗${NC}  $1"; exit 1; }
info()  { echo -e "  ${BLUE}ℹ${NC}  $1"; }
warn()  { echo -e "  ${YELLOW}⚠${NC}  $1"; }

# ── Helpers ────────────────────────────────────────────────────────────────────

# Read the current version string from pubspec.yaml
read_version() {
  grep -E '^version:' "$PUBSPEC" | sed 's/version:[[:space:]]*//' | tr -d '[:space:]'
}

# Validate that a version string matches X.Y.Z+N
validate_version() {
  local v="$1"
  if [[ ! "$v" =~ ^[0-9]+\.[0-9]+\.[0-9]+\+[0-9]+$ ]]; then
    fail "Invalid version format: '${v}'. Expected format: X.Y.Z+N (e.g. 1.2.3+4)"
  fi
}

# Write a new version string into pubspec.yaml
write_version() {
  local new_version="$1"
  # Use sed to replace the version line in-place
  sed -i "s/^version:.*$/version: ${new_version}/" "$PUBSPEC"
}

# ── Show mode ──────────────────────────────────────────────────────────────────

show_info() {
  echo ""
  echo -e "${BLUE}══════════════════════════════════════════════${NC}"
  echo -e "${BLUE}          📋 App Version Information          ${NC}"
  echo -e "${BLUE}══════════════════════════════════════════════${NC}"
  echo ""

  local current
  current=$(read_version)
  if [[ -z "$current" ]]; then
    fail "Could not read version from pubspec.yaml"
  fi

  local version_name="${current%%+*}"
  local version_code="${current##*+}"

  echo -e "  ${BOLD}Current version  :${NC}  ${GREEN}${current}${NC}"
  echo -e "  ${BOLD}  versionName    :${NC}  ${version_name}  (shown to users in Play Store)"
  echo -e "  ${BOLD}  versionCode    :${NC}  ${version_code}  (must be strictly increasing for Play Store)"
  echo ""

  if [[ -f "$LAST_RELEASE_FILE" ]]; then
    local last
    last=$(cat "$LAST_RELEASE_FILE" | tr -d '[:space:]')
    echo -e "  ${BOLD}Last prod release:${NC}  ${YELLOW}${last}${NC}"
    if [[ "$current" == "$last" ]]; then
      warn "Version is unchanged since last production release."
      warn "Bump the version before building for release."
    else
      local last_code="${last##*+}"
      local last_name="${last%%+*}"
      if [[ "$current" != "$last" ]]; then
        echo -e "  ${BOLD}Status           :${NC}  ${GREEN}✔ Version has been bumped${NC}  (${last_name}+${last_code} → ${version_name}+${version_code})"
      fi
    fi
  else
    echo -e "  ${BOLD}Last prod release:${NC}  ${YELLOW}(no previous release recorded)${NC}"
  fi

  echo ""
  echo -e "  ${CYAN}Usage:${NC}"
  echo "    ./manage-version.sh set 1.2.0+3   # Set exact version"
  echo "    ./manage-version.sh bump patch     # 1.0.0+1 → 1.0.1+2"
  echo "    ./manage-version.sh bump minor     # 1.0.0+1 → 1.1.0+2"
  echo "    ./manage-version.sh bump major     # 1.0.0+1 → 2.0.0+2"
  echo ""
}

# ── Set mode ───────────────────────────────────────────────────────────────────

do_set() {
  local new_version="$1"
  if [[ -z "$new_version" ]]; then
    fail "Usage: $0 set <version>  (e.g. $0 set 1.2.0+3)"
  fi

  validate_version "$new_version"

  local old_version
  old_version=$(read_version)

  echo ""
  echo -e "${BLUE}══════════════════════════════════════════════${NC}"
  echo -e "${BLUE}           ✏️  Setting App Version            ${NC}"
  echo -e "${BLUE}══════════════════════════════════════════════${NC}"
  echo ""
  echo -e "  ${BOLD}Old version :${NC}  ${YELLOW}${old_version}${NC}"
  echo -e "  ${BOLD}New version :${NC}  ${GREEN}${new_version}${NC}"
  echo ""

  write_version "$new_version"
  pass "pubspec.yaml updated → version: ${new_version}"
  echo ""
}

# ── Bump mode ──────────────────────────────────────────────────────────────────

do_bump() {
  local segment="$1"
  if [[ -z "$segment" ]]; then
    fail "Usage: $0 bump <major|minor|patch>"
  fi
  case "$segment" in
    major|minor|patch) ;;
    *) fail "Unknown bump segment '${segment}'. Use: major, minor, or patch" ;;
  esac

  local current
  current=$(read_version)
  validate_version "$current"

  local version_name="${current%%+*}"
  local version_code="${current##*+}"

  # Split versionName into parts
  IFS='.' read -r MAJOR MINOR PATCH <<< "$version_name"

  case "$segment" in
    major) MAJOR=$((MAJOR + 1)); MINOR=0; PATCH=0 ;;
    minor) MINOR=$((MINOR + 1)); PATCH=0 ;;
    patch) PATCH=$((PATCH + 1)) ;;
  esac

  local new_code=$((version_code + 1))
  local new_version="${MAJOR}.${MINOR}.${PATCH}+${new_code}"

  echo ""
  echo -e "${BLUE}══════════════════════════════════════════════${NC}"
  echo -e "${BLUE}          ⬆️  Bumping App Version (${segment})        ${NC}"
  echo -e "${BLUE}══════════════════════════════════════════════${NC}"
  echo ""
  echo -e "  ${BOLD}Old version :${NC}  ${YELLOW}${current}${NC}"
  echo -e "  ${BOLD}New version :${NC}  ${GREEN}${new_version}${NC}"
  echo ""

  write_version "$new_version"
  pass "pubspec.yaml updated → version: ${new_version}"
  info "versionCode incremented: ${version_code} → ${new_code}"
  echo ""
}

# ── Entry point ────────────────────────────────────────────────────────────────

COMMAND="${1:-}"

case "$COMMAND" in
  "")       show_info ;;
  set)      do_set "${2:-}" ;;
  bump)     do_bump "${2:-}" ;;
  -h|--help)
    echo ""
    echo "Usage: $0 [command] [args]"
    echo ""
    echo "Commands:"
    echo "  (none)            Show current version info"
    echo "  set <version>     Set exact version (e.g. 1.2.0+3)"
    echo "  bump major        Bump major version: 1.0.0+1 → 2.0.0+2"
    echo "  bump minor        Bump minor version: 1.0.0+1 → 1.1.0+2"
    echo "  bump patch        Bump patch version: 1.0.0+1 → 1.0.1+2"
    echo ""
    ;;
  *)
    fail "Unknown command: '${COMMAND}'. Run '$0 --help' for usage."
    ;;
esac
