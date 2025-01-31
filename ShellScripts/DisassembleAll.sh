#!/bin/bash

#? Disassemble all scripts from both PC and Wii versions and preserve directory structure

# Directory containing the original files
INPUT_DIR="ARCHIVE"
# Directory where the disassembled files will be stored
OUTPUT_DIR="DISASSEMBLED"

# Path to desired decompiler
UNLUAC=$HOME/Games/Bully/Programs/LUA/decompiler/unluac.jar

# Ensure OUTPUT_DIR exists
mkdir -p "$OUTPUT_DIR"

# Empty directories to start dumping new files
rm -rf "$OUTPUT_DIR"/*

# Change to INPUT_DIR and collect directory structure
cd "$INPUT_DIR" || { echo "Failed to enter directory: $INPUT_DIR"; exit 1; }
find . -type d > ../dirs.tmp

# Change to OUTPUT_DIR and replicate folder structure
cd "../$OUTPUT_DIR" || { echo "Failed to enter directory: $OUTPUT_DIR"; exit 1; }
xargs mkdir -p < ../dirs.tmp

# Clean up temporary file
cd ..
rm -f dirs.tmp



# START DISASSEMBLY PROCESS!


# *** LUC FILES *** #

# Find all .luc files in the input directory and process each one
find "$INPUT_DIR" -type f -name "*.luc" | while read -r file; do

    # Extract the relative path of the file from the input directory
    relative_path="${file#$INPUT_DIR/}"

    # Construct the output file path, changing the extension from .luc to .dis
    output_file="$OUTPUT_DIR/${relative_path%.luc}.dis"

    # Execute decompiler for every file, check for errors
    echo "Processing file $file..."

    if ! java -jar "$UNLUAC" --disassemble "$file" --output "$output_file"; then

        echo "error processing file: $file"

        sleep 1
    fi
done


# *** LUR FILES *** #

# Find all .lur files in the input directory and process each one
find "$INPUT_DIR" -type f -name "*.lur" | while read -r file; do

    # Extract the relative path of the file from the input directory
    relative_path="${file#$INPUT_DIR/}"

    # Construct the output file path, changing the extension from .lur to .dis
    output_file="$OUTPUT_DIR/${relative_path%.lur}.dis"

    # Execute decompiler for every file, check for errors
    echo "Processing file $file..."

    if ! java -jar "$UNLUAC" --disassemble "$file" --output "$output_file"; then

        echo "error processing file: $file"

        sleep 1
    fi

    # Remove .linedefined entries
    sed -i '/\.linedefined/d' "$output_file"
done

echo "Processing completed!"
