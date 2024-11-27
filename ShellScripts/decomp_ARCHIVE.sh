#!/bin/bash

# Directory containing the original files
INPUT_DIR="ARCHIVE"
# Directory where the decompiled files will be stored
OUTPUT_DIR="DECOMPILED"


# *** LUC FILES *** #

# Find all .luc files in the input directory and process each one
find "$INPUT_DIR" -type f -name "*.luc" | while read -r file; do

    # Extract the relative path of the file from the input directory
    relative_path="${file#$INPUT_DIR/}"

    # Construct the output file path, changing the extension from .luc to .lua
    output_file="$OUTPUT_DIR/${relative_path%.luc}.lua"

    # Execute decompiler for every file, check for errors
    echo "Processing file $file..."

    if ! java -jar unluac.jar "$file" --output "$output_file"; then

        echo "error processing file: $file"

        sleep 1
    fi
done


# *** LUR FILES *** #

# Find all .lur files in the input directory and process each one
find "$INPUT_DIR" -type f -name "*.lur" | while read -r file; do

    # Extract the relative path of the file from the input directory
    relative_path="${file#$INPUT_DIR/}"

    # Construct the output file path, changing the extension from .lur to .lua
    output_file="$OUTPUT_DIR/${relative_path%.lur}.lua"

    # Execute decompiler for every file, check for errors
    echo "Processing file $file..."

    if ! java -jar unluac.jar "$file" --output "$output_file"; then

        echo "error processing file: $file"

        sleep 1
    fi
done

echo "Processing completed!"
