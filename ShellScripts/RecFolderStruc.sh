#!/bin/bash

# Directory containing the original structure
INPUT_DIR="ARCHIVE"
# Directory where the structure will be recreated
OUTPUT_DIR="DECOMPILED"

cd $INPUT_DIR

find . -type d > ../dirs.tmp

cd ../$OUTPUT_DIR

xargs mkdir -p < ../dirs.tmp

cd ..

rm dirs.tmp

tree -d

exit
