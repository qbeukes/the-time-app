#!/bin/bash

SD=$(cd `dirname ${BASH_SOURCE[0]}`; pwd)
rsync --exclude /flutter-index.html --delete-excluded -avz "$SD/web/" veryeasy.co.za:/var/www/time-app/

