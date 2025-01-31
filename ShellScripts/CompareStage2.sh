#!/bin/bash

#? STAGE 2: Compare all processed scripts and point out scripts with differences, compare disassemblies

# Directories
ORIGINAL_DIR="ARCHIVE/PC"                              # The directory with original PC scripts (flat structure)
INPUT_DIR="Reconstruct/Scripts"                        # The directory with scripts to compile (has subdirectories)
DISASSEMBLE_ORIGINAL_DIR="Reconstruct/Disassemble"     # The directory to store disassemblies from ORIGINAL_DIR
COMPILED_DIR="Reconstruct/Compiled-NoDebug"            # Where compiled scripts will be stored (preserves structure)
DISASSEMBLE_DECOMPILED_DIR="Reconstruct/Compare"       # The directory to store disassemblies from COMPILED_DIR (flat structure)

# Programs
UNLUAC=$HOME/Games/Bully/Programs/LUA/decompiler/unluac.jar     # Lua decompiler
LUAC=$HOME/Games/Bully/Programs/LUA/compiler/luac.exe           # Lua compiler

# Ensure required directories exist
mkdir -p "$COMPILED_DIR" "$DISASSEMBLE_ORIGINAL_DIR" "$DISASSEMBLE_DECOMPILED_DIR"

# Empty directories to start fresh
rm -rf "$COMPILED_DIR"/* "$DISASSEMBLE_ORIGINAL_DIR"/* "$DISASSEMBLE_DECOMPILED_DIR"/*

# Step 1: Disassemble original scripts
echo "Disassembling original scripts..."

for file in "$ORIGINAL_DIR"/*.lur; do
    filename=$(basename -- "$file" .lur)
    disassemble_file="$DISASSEMBLE_ORIGINAL_DIR/$filename.dis"
    java -jar "$UNLUAC" --disassemble --output "$disassemble_file" "$file"
    # Remove .linedefined entries
    sed -i '/\.linedefined/d' "$disassemble_file"
done

echo "Original scripts disassembled."

# Step 2: Compile and disassemble new scripts
echo "Compiling and disassembling new scripts..."

find "$INPUT_DIR" -type f -name "*.lua" | while read -r file; do
    filename=$(basename -- "$file" .lua)
    compiled_file="$COMPILED_DIR/${file#$INPUT_DIR/}"
    compiled_file="${compiled_file%.lua}.lur"
    disassembled_file="$DISASSEMBLE_DECOMPILED_DIR/$filename.dis"
    original_dis_file="$DISASSEMBLE_ORIGINAL_DIR/$filename.dis"

    # Ensure subdirectories exist
    mkdir -p "$(dirname "$compiled_file")"
    
    # Compile
    WINEDEBUG=-all wine "$LUAC" -s -o "$compiled_file" "$file"
    if [ $? -ne 0 ]; then
        echo "Compilation failed for $file"
        continue
    fi

    # Disassemble compiled file
    java -jar "$UNLUAC" --disassemble --output "$disassembled_file" "$compiled_file"
    if [ $? -ne 0 ]; then
        echo "Disassembly failed for $file"
        continue
    fi

    # Remove .linedefined entries
    sed -i '/\.linedefined/d' "$disassembled_file"

    # Compare disassemblies
    if [ -f "$original_dis_file" ]; then
        if ! diff -q "$original_dis_file" "$disassembled_file" > /dev/null; then
            echo "Differences found for $filename"
        fi
    else
        echo "Original disassembly missing for $filename"
    fi

done

echo "Comparison process completed!"
