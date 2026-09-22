#!/bin/bash
set -e

SD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SD"

echo "============================================="
echo " 🚀 Building Flutter Web Application Module..."
echo "============================================="

if [ ! -f "$SD/web/flutter-index.html" ]; then
    echo "Error: web/flutter-index.html not found!"
    exit 1
fi

# Swap in Flutter HTML template for compilation
cp "$SD/web/flutter-index.html" "$SD/web/index.html"

# Run flutter build web with base href / (for dedicated domain time-app.veryeasy.co.za)
flutter build web --release --base-href "/"

# Clean up temporary web/index.html
rm -f "$SD/web/index.html"

# Refresh web/app directory
mkdir -p "$SD/web/app"
rm -rf "$SD/web/app"/*

# Copy built Flutter web app files into web/app/
cp -r "$SD/build/web"/* "$SD/web/app/"

# Clean up non-app subdirectories copied from build/web
rm -rf "$SD/web/app/site" "$SD/web/app/app" "$SD/web/app/flutter-index.html"

echo "============================================="
echo " 🎉 Web application module built successfully!"
echo "    - Destination: web/app/"
echo "    - Domain Target: time-app.veryeasy.co.za"
echo "============================================="
