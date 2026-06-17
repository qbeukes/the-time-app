tgt_dir="/var/www/the-time-app"
scp build/app/outputs/apk/release/app-release.apk ve:"$tgt_dir"/"app-release-$(date '+%-d-%B-%Y-%Hh%Mm%S' | tr '[:upper:]' '[:lower:]').apk"
