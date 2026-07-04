#!/bin/bash


SD=$(cd `dirname $0`; pwd)
source "/opt/shared/common.sh" || exit 35

echo "============================================="
echo " 🎉 Deploying APK via ADB..."
echo "============================================="

apk_file=build/app/outputs/apk/release/app-release.apk
adb install "$apk_file" || {
	echo "Failed to deploy." >&2
	exit 1
}

echo "============================================="
echo " 🎉 Deploy completed successfully!"
echo "============================================="

