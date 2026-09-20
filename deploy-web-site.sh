#!/bin/bash

SD=$(cd `dirname ${BASH_SOURCE[0]}`; pwd)
rsync --exclude upload.sh --delete-excluded -avz "$SD/web/" veryeasy.co.za:/var/www/the-time-app/

