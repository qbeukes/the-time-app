#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Navigate to the project directory where the script is located
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_DIR"

echo "============================================="
echo " 🚀 Starting Flutter APK Release Build"
echo "============================================="

# 1. Check if Flutter SDK is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Error: 'flutter' command not found. Please install Flutter and make sure it is in your PATH."
    exit 1
fi

# 2. Clean previous build caches to avoid stale assets
echo "🧹 Cleaning previous build assets..."
flutter clean

# 3. Fetch dependencies
echo "📦 Fetching dependencies (flutter pub get)..."
flutter pub get

# 4. Build the release APK
echo "🏗️ Building Release APK (obfuscated, debug symbols extracted)..."
# --obfuscate strips Dart symbol names; --split-debug-info extracts debug symbols
# for separate upload. Pass any extra arguments (e.g. --split-per-abi) after these.
DEBUG_SYMBOLS_DIR="$PROJECT_DIR/build/debug-symbols"
flutter build apk --release \
    --obfuscate \
    --split-debug-info="$DEBUG_SYMBOLS_DIR" \
    "$@"

echo "============================================="
echo " 🎉 Build completed successfully!"
echo "============================================="

# 5. Output built APK details
APK_DIR="build/app/outputs/flutter-apk"
if [ -d "$APK_DIR" ]; then
    echo "📂 Output Directory: $(realpath "$APK_DIR")"
    echo "📦 Generated APKs:"
    find "$APK_DIR" -maxdepth 1 -name "*.apk" -type f | while read -r apk; do
        echo "  - $(basename "$apk") ($(du -h "$apk" | cut -f1))"
    done
else
    echo "⚠️ Warning: Output directory not found. Please check build logs."
fi

# 6. Zip debug symbols alongside APK output
if [ -d "$DEBUG_SYMBOLS_DIR" ] && [ -n "$(ls -A "$DEBUG_SYMBOLS_DIR" 2>/dev/null)" ]; then
    CURRENT_VERSION=$(grep -E '^version:' "$PROJECT_DIR/pubspec.yaml" | sed 's/version:[[:space:]]*//' | tr -d '[:space:]')
    DEBUG_SYMBOLS_ZIP="$APK_DIR/debug-symbols-v${CURRENT_VERSION}.zip"
    echo "📦 Zipping debug symbols..."
    (cd "$DEBUG_SYMBOLS_DIR" && zip -r "$DEBUG_SYMBOLS_ZIP" . -x "*.DS_Store") > /dev/null
    echo "  🐛 Debug symbols: $(realpath "$DEBUG_SYMBOLS_ZIP") ($(du -h "$DEBUG_SYMBOLS_ZIP" | cut -f1))"
fi
