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
echo "🏗️ Building Release APK..."
# Pass any arguments provided to this script directly to the flutter build command (e.g. --split-per-abi)
flutter build apk --release "$@"

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

echo "============================================="
echo " 🎉 Deploying APK to HOST..."
echo "============================================="

tgt_dir="/var/www/the-time-app"
scp build/app/outputs/apk/release/app-release.apk ve:"$tgt_dir"/"app-release-$(date '+%-d-%B-%Y-%Hh%Mm%S' | tr '[:upper:]' '[:lower:]').apk" || {
	echo "Error" >&2
	exit 1
}

echo "============================================="
echo " 🎉 Deploy completed successfully!"
echo "============================================="

