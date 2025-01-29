#!/bin/bash

#? Compare all processed scripts and point out scripts with differences

# Directories
ORIGINAL_DIR="DECOMPILED/PC"                      # The directory with original PC scripts (flat structure)
INPUT_DIR="Reconstruct/Scripts"                   # The directory with scripts to compile (has subdirectories)
COMPILED_DIR="Reconstruct/Compiled-NoDebug"       # Where compiled scripts will be stored (preserves structure)
DECOMPILED_DIR="Reconstruct/Compare"              # Where decompiled scripts will be stored (flat structure)

# Programs
UNLUAC=$HOME/Games/Bully/Programs/LUA/decompiler/unluac.jar     # Lua decompiler
LUAC=$HOME/Games/Bully/Programs/LUA/compiler/luac.exe           # Lua compiler

# Ensure required directories exist
mkdir -p "$COMPILED_DIR" "$DECOMPILED_DIR"

# Empty directories to start dumping new files
rm -rf "$COMPILED_DIR"/* "$DECOMPILED_DIR"/*

# Loop through all .lua files in INPUT_DIR recursively
find "$INPUT_DIR" -type f -name "*.lua" | while read -r file; do
    filename=$(basename -- "$file" .lua)                # Get filename without path
    compiled_file="$COMPILED_DIR/${file#$INPUT_DIR/}"   # Preserve subdirectories
    compiled_file="${compiled_file%.lua}.lur"           # Change extension to .lur
    decompiled_file="$DECOMPILED_DIR/$filename.lua"     # Flatten structure for decompiled files
    original_file="$ORIGINAL_DIR/$filename.lua"         # Original file is in a flat directory

    # Ensure necessary subdirectories exist in compiled folder
    mkdir -p "$(dirname "$compiled_file")"

    # Step 1: Compile with stripped debug info
    WINEDEBUG=-all wine "$LUAC" -s -o "$compiled_file" "$file"
    if [ $? -ne 0 ]; then
        echo "Compilation failed for $file"
        continue
    fi

    # Step 2: Decompile (store all in flat directory)
    java -jar "$UNLUAC" --output "$decompiled_file" "$compiled_file"
    if [ $? -ne 0 ]; then
        echo "Decompilation failed for $file"
        continue
    fi

    # Step 3: Compare with original (since both are in a flat structure)
    if [ -f "$original_file" ]; then
        if ! diff -q "$original_file" "$decompiled_file" > /dev/null; then
            echo "Differences found for $filename"
        fi
    else
        echo "Original file missing for $filename"
    fi

done
