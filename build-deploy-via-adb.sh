#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Navigate to the project directory where the script is located
SD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SD"

"$SD/build-apk.sh"
"$SD/deploy-via-adb.sh"

