#!/bin/bash

#? STAGE 2: Compare all processed scripts and point out scripts with differences, compare disassemblies

# Directories
ORIGINAL_DIR="DISASSEMBLED/PC"                    # The directory with original PC disassemblies (flat structure)
INPUT_DIR="Reconstruct/Scripts"                   # The directory with scripts to compile (has subdirectories)
COMPILED_DIR="Reconstruct/Compiled-NoDebug"       # Where compiled scripts will be stored (preserves structure)
DISASSEMBLED_DIR="Reconstruct/Compare"            # Where disassembled scripts will be stored (flat structure)

# Programs
UNLUAC=$HOME/Games/Bully/Programs/LUA/decompiler/unluac.jar     # Lua decompiler
LUAC=$HOME/Games/Bully/Programs/LUA/compiler/luac.exe           # Lua compiler

# Ensure required directories exist
mkdir -p "$COMPILED_DIR" "$DISASSEMBLED_DIR"

# Empty directories to start dumping new files
rm -rf "$COMPILED_DIR"/* "$DISASSEMBLED_DIR"/*

# Loop through all .lua files in INPUT_DIR recursively
find "$INPUT_DIR" -type f -name "*.lua" | while read -r file; do
    filename=$(basename -- "$file" .lua)                  # Get filename without path
    compiled_file="$COMPILED_DIR/${file#$INPUT_DIR/}"     # Preserve subdirectories
    compiled_file="${compiled_file%.lua}.lur"             # Change extension to .lur
    disassembled_file="$DISASSEMBLED_DIR/$filename.dis"   # Flatten structure for disassembled files
    original_file="$ORIGINAL_DIR/$filename.dis"           # Original disassembly file (now with .dis extension)

    # Ensure necessary subdirectories exist in compiled folder
    mkdir -p "$(dirname "$compiled_file")"

    # Step 1: Compile with stripped debug info
    WINEDEBUG=-all wine "$LUAC" -s -o "$compiled_file" "$file"
    if [ $? -ne 0 ]; then
        echo "Compilation failed for $file"
        continue
    fi

    # Step 2: Disassemble (store all in flat directory)
    java -jar "$UNLUAC" --disassemble --output "$disassembled_file" "$compiled_file"
    if [ $? -ne 0 ]; then
        echo "Disassembly failed for $file"
        continue
    fi

    # Remove .linedefined entries from disassembled file
    sed -i '/\.linedefined/d' "$disassembled_file"

    # Step 3: Compare with original (since both are in a flat structure)
    if [ -f "$original_file" ]; then
        if ! diff -q "$original_file" "$disassembled_file" > /dev/null; then
            echo "Differences found for $filename"
        fi
    else
        echo "Original disassembly missing for $filename"
    fi

done
