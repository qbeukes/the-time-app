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

# Rename compiled Flutter index.html to app.html for iframe embedding
mv "$SD/web/app/index.html" "$SD/web/app/app.html"

# Create outer container index.html that frames app.html at max-width 550px
cat << 'EOF' > "$SD/web/app/index.html"
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, viewport-fit=cover">
  <title>The Time App</title>
  <link rel="icon" type="image/png" href="favicon.png" />
  <style>
    html, body {
      margin: 0;
      padding: 0;
      width: 100%;
      height: 100%;
      background-color: #050810;
      display: flex;
      justify-content: center;
      align-items: center;
      overflow: hidden;
    }
    iframe {
      width: 100%;
      max-width: 550px;
      height: 100%;
      border: none;
      box-shadow: 0 0 50px rgba(0, 0, 0, 0.8);
    }
  </style>
</head>
<body>
  <iframe src="app.html"></iframe>
</body>
</html>
EOF

echo "============================================="
echo " 🎉 Web application module built successfully!"
echo "    - Destination: web/app/"
echo "    - Shell index: web/app/index.html (550px centered iframe)"
echo "    - Flutter app: web/app/app.html"
echo "    - Domain Target: time-app.veryeasy.co.za"
echo "============================================="
