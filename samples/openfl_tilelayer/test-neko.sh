#!/bin/bash

# cd to the script's directory so we can run it from anywhere
cd "$(dirname "$0")"

rm -Rf ./bin/neko/bin/SWFTY

openfl build neko -v

FILE=bin/neko/release/bin/SWFTY.app/Contents/MacOS/SWFTY
if [ -f $FILE ]; then
    ./$FILE $@
else
    echo "File not found"
fi