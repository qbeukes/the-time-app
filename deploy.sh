scp build/app/outputs/apk/release/app-release.apk ve:/var/www/veryeasy/time/"app-release-$(date '+%-d-%B-%Y-%Hh%Mm%S' | tr '[:upper:]' '[:lower:]').apk"
