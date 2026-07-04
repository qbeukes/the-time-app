#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

SD=$(cd `dirname ${BASH_SOURCE[0]}`; pwd)
source "/opt/shared/common.sh" || exit 35

echo "============================================="
echo " 🎉 Deploying APK to HOST..."
echo "============================================="

tgt_dir="/var/www/the-time-app"
apk_file="$SD/build/app/outputs/apk/release/app-release.apk"

scp "$apk_file" ve:"$tgt_dir"/"app-release-$(date '+%-d-%B-%Y-%Hh%Mm%S' | tr '[:upper:]' '[:lower:]').apk" || fail "Error deploying"

echo "============================================="
echo " 🎉 Deploy completed successfully!"
echo "============================================="

