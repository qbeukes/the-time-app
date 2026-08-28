#!/usr/bin/env bash
# verify-signing-key.sh
# Validates that the upload signing key is present, configured, and that
# the release .aab is signed with the correct key.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KEY_PROPERTIES="$SCRIPT_DIR/android/key.properties"
AAB_PATH="$SCRIPT_DIR/build/app/outputs/bundle/release/app-release.aab"

# --- Colours ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Colour

pass() { echo -e "  ${GREEN}✔${NC}  $1"; }
fail() { echo -e "  ${RED}✗${NC}  $1"; FAILED=1; }
info() { echo -e "  ${BLUE}ℹ${NC}  $1"; }
warn() { echo -e "  ${YELLOW}⚠${NC}  $1"; }

FAILED=0

echo ""
echo -e "${BLUE}══════════════════════════════════════════════${NC}"
echo -e "${BLUE}      Android Signing Key Verification        ${NC}"
echo -e "${BLUE}══════════════════════════════════════════════${NC}"
echo ""

# ── 1. Check key.properties exists ────────────────────────────────────────────
echo -e "${YELLOW}[1/4] Checking key.properties...${NC}"
if [[ -f "$KEY_PROPERTIES" ]]; then
  pass "key.properties found at android/key.properties"
else
  fail "key.properties NOT found at android/key.properties"
  echo ""
  echo "  Run the signing setup before verifying."
  exit 1
fi

# ── 2. Parse & validate key.properties values ─────────────────────────────────
echo ""
echo -e "${YELLOW}[2/4] Validating key.properties fields...${NC}"

get_prop() {
  grep -E "^${1}=" "$KEY_PROPERTIES" | cut -d'=' -f2- | tr -d '\r'
}

STORE_FILE=$(get_prop "storeFile")
KEY_ALIAS=$(get_prop "keyAlias")
STORE_PASSWORD=$(get_prop "storePassword")
KEY_PASSWORD=$(get_prop "keyPassword")

[[ -n "$STORE_FILE" ]]    && pass "storeFile     = $STORE_FILE"   || fail "storeFile is missing from key.properties"
[[ -n "$KEY_ALIAS" ]]     && pass "keyAlias      = $KEY_ALIAS"    || fail "keyAlias is missing from key.properties"
[[ -n "$STORE_PASSWORD" ]] && pass "storePassword = (set)"        || fail "storePassword is missing from key.properties"
[[ -n "$KEY_PASSWORD" ]]  && pass "keyPassword   = (set)"         || fail "keyPassword is missing from key.properties"

if [[ $FAILED -eq 1 ]]; then
  echo ""
  fail "key.properties is incomplete. Aborting."
  exit 1
fi

# Resolve storeFile path — Gradle's file() resolves relative to the module dir (android/app/)
ANDROID_APP_DIR="$SCRIPT_DIR/android/app"
ANDROID_DIR="$SCRIPT_DIR/android"
if [[ "$STORE_FILE" = /* ]]; then
  KEYSTORE_PATH="$STORE_FILE"
elif [[ -f "$ANDROID_APP_DIR/$STORE_FILE" ]]; then
  KEYSTORE_PATH="$ANDROID_APP_DIR/$STORE_FILE"
else
  # Fallback: relative to android/ (e.g. if storeFile=app/upload-keystore.jks)
  KEYSTORE_PATH="$ANDROID_DIR/$STORE_FILE"
fi


# ── 3. Validate the keystore file ─────────────────────────────────────────────
echo ""
echo -e "${YELLOW}[3/4] Validating keystore file...${NC}"

if [[ -f "$KEYSTORE_PATH" ]]; then
  pass "Keystore file found at $KEYSTORE_PATH"
else
  fail "Keystore file NOT found at $KEYSTORE_PATH"
  exit 1
fi

# Check we can read the keystore with the given password
KEYTOOL_OUTPUT=$(keytool -list \
  -keystore "$KEYSTORE_PATH" \
  -alias "$KEY_ALIAS" \
  -storepass "$STORE_PASSWORD" 2>&1) && KEYTOOL_OK=0 || KEYTOOL_OK=1

if [[ $KEYTOOL_OK -eq 0 ]]; then
  pass "Keystore unlocked successfully with provided storePassword"
  CERT_FINGERPRINT=$(echo "$KEYTOOL_OUTPUT" | grep -E "SHA.?256" | awk '{print $NF}')
  if [[ -n "$CERT_FINGERPRINT" ]]; then
    info "Certificate SHA-256 fingerprint:"
    echo "         $CERT_FINGERPRINT"
  fi
else
  fail "Failed to unlock keystore. Wrong password or corrupted file."
  echo "  keytool output: $KEYTOOL_OUTPUT"
  FAILED=1
fi

# Verify the alias is accessible with the key password
keytool -list \
  -keystore "$KEYSTORE_PATH" \
  -alias "$KEY_ALIAS" \
  -storepass "$STORE_PASSWORD" \
  -keypass "$KEY_PASSWORD" > /dev/null 2>&1 \
  && pass "Key alias '$KEY_ALIAS' is accessible with provided keyPassword" \
  || { fail "Key alias '$KEY_ALIAS' not accessible — wrong keyPassword or alias"; FAILED=1; }

# ── 4. Validate .aab signing (if bundle exists) ───────────────────────────────
echo ""
echo -e "${YELLOW}[4/4] Validating .aab signing...${NC}"

if [[ ! -f "$AAB_PATH" ]]; then
  warn "app-release.aab not found at:"
  warn "  $AAB_PATH"
  warn "Run 'flutter build appbundle' first, then re-run this script."
else
  pass ".aab found at build/app/outputs/bundle/release/app-release.aab"

  # .aab is a ZIP; extract META-INF to read the JAR-style signature block
  TMPDIR_AAB=$(mktemp -d)

  unzip -q "$AAB_PATH" "META-INF/*" -d "$TMPDIR_AAB" 2>/dev/null || true

  META_INF_DIR="$TMPDIR_AAB/META-INF"
  CERT_FILE=$(find "$META_INF_DIR" \( -name "*.RSA" -o -name "*.DSA" -o -name "*.EC" \) 2>/dev/null | head -n 1)

  if [[ -n "$CERT_FILE" ]]; then
    # keytool -printcert wraps long fingerprints across two lines; join them.
    # Format: "         SHA256: AA:BB:CC:\n43:6E:..." — we grab both lines and strip whitespace.
    set +o pipefail
    PRINTCERT_OUT=$(keytool -printcert -file "$CERT_FILE" 2>/dev/null)
    AAB_FINGERPRINT=$(echo "$PRINTCERT_OUT" \
      | grep -A1 -E "SHA.?256" \
      | tr -d ' \n' \
      | grep -oE '[0-9A-Fa-f]{2}(:[0-9A-Fa-f]{2})+')

    KS_FINGERPRINT=$(keytool -list -v \
      -keystore "$KEYSTORE_PATH" \
      -alias "$KEY_ALIAS" \
      -storepass "$STORE_PASSWORD" 2>/dev/null \
      | grep -A1 -E "SHA.?256" \
      | tr -d ' \n' \
      | grep -oE '[0-9A-Fa-f]{2}(:[0-9A-Fa-f]{2})+')
    set -o pipefail

    info ".aab certificate SHA-256:"
    echo "         ${AAB_FINGERPRINT:-(empty)}"
    info "Keystore certificate SHA-256:"
    echo "         ${KS_FINGERPRINT:-(empty)}"

    if [[ -n "$AAB_FINGERPRINT" && "$AAB_FINGERPRINT" == "$KS_FINGERPRINT" ]]; then
      pass ".aab is signed with the correct upload key ✓"
    elif [[ -z "$AAB_FINGERPRINT" ]]; then
      fail "Could not extract certificate fingerprint from .aab."
      FAILED=1
    else
      fail ".aab fingerprint does NOT match keystore fingerprint!"
      fail "The bundle may have been signed with a different key."
      FAILED=1
    fi
  else
    warn "No JAR signature block found in META-INF."
    info "The .aab may use only APK Signature Scheme v2/v3 (not verifiable via keytool)."
    info "To verify: use 'apksigner verify --print-certs' on an APK extracted from the .aab."
  fi

  rm -rf "$TMPDIR_AAB"
fi



# ── Summary ───────────────────────────────────────────────────────────────────
echo ""
echo -e "${BLUE}══════════════════════════════════════════════${NC}"
if [[ $FAILED -eq 0 ]]; then
  echo -e "${GREEN}  All checks passed! Signing key is valid.${NC}"
else
  echo -e "${RED}  One or more checks FAILED. See above for details.${NC}"
fi
echo -e "${BLUE}══════════════════════════════════════════════${NC}"
echo ""

exit $FAILED
