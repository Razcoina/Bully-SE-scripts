#!/bin/bash

#? Compile all scripts and preserve folder structure

# MASTER directory - compiled lua files with debug data keep the name of the original file in them,
# changing difectory makes the name shorter, potentially saving space
MASTER="Reconstruct"

if [ -d "$MASTER" ]; then
    cd "$MASTER" || exit 1
else
    echo "Error: Directory $MASTER does not exist."
    exit 1
fi

# Directory containing the scripts
INPUT_DIR="Scripts"
# Directory where the compiled files will be stored
OUTPUT_DIR="Compiled-NoDebug"

# Path to desired compiler
LUAC=$HOME/Games/Bully/Programs/LUA/compiler/luac.exe

# Keep debug data - Set this to true
# Remove debug data - Set this to false
KEEP_DEBUG=false

# Change the location if debug is kept
if [ "$KEEP_DEBUG" = true ] ; then
    OUTPUT_DIR="Compiled"
fi

# Ensure output directory exists
mkdir -p "$OUTPUT_DIR"

# Empty directories to start dumping new files
rm -rf "$OUTPUT_DIR"/*

# Loop through all .lua files in INPUT_DIR, preserving folder structure
find "$INPUT_DIR" -type f -name "*.lua" | while read -r file; do
    # Get relative path
    relative_path="${file#$INPUT_DIR/}"
    output_file="$OUTPUT_DIR/${relative_path%.lua}.lur"
    
    # Ensure subdirectories exist in output
    mkdir -p "$(dirname "$output_file")"
    
    # Compile with or without debug info
    if [ "$KEEP_DEBUG" = true ]; then
        WINEDEBUG=-all wine "$LUAC" -o "$output_file" "$file"
    else
        WINEDEBUG=-all wine "$LUAC" -s -o "$output_file" "$file"
    fi
    
    # Check for errors
    if [ $? -ne 0 ]; then
        echo "Compilation failed for $file"
    fi

done

echo "Compilation process completed!"
