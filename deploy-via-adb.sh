#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

SD=$(cd `dirname ${BASH_SOURCE[0]}`; pwd)
source "/opt/shared/common.sh" || exit 35

echo "============================================="
echo " 🎉 Deploying APK via ADB..."
echo "============================================="

apk_file=build/app/outputs/apk/release/app-release.apk
adb install "$apk_file" || fail  "Failed to deploy." 

echo "============================================="
echo " 🎉 Deploy completed successfully!"
echo "============================================="

