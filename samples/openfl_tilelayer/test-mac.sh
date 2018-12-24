#!/bin/bash

# cd to the script's directory so we can run it from anywhere
cd "$(dirname "$0")"

rm -Rf ./bin/macos/bin/SWFTY

openfl build mac -v

FILE=bin/macos/debug/bin/SWFTY.app/Contents/MacOS/SWFTY
if [ -f $FILE ]; then
    ./$FILE $@
else
    echo "File not found"
fi