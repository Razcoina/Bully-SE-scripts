# Bully: Scholarship Edition Lua Script Decompilation
## This is a work in progress, not all scripts are included and most that are have not been tested!

This project aims to fully decompile all Lua scripts from Bully: Scholarship Edition for PC. The goal is to provide clean, readable, and editable Lua scripts for modding, troubleshooting, and understanding the game's inner workings.
> This was made by analysing and comparing the scripts from this version with a leaked pre-released debug version of the game for the Nintendo Wii.

## Decompilation process
1) Decompiled every script using [unluac](https://sourceforge.net/projects/unluac/).
2) Compared all files by name to identify files with the exact same contents.
3) Edit the files that are different, while adding, changing or removing chunks that don't match the scripts for the PC version. Function calls to `print`, `assert` and `DebugPrint` are left commented.
5) Compile all modified files and strip debug information.
6) Decompile again and compare the result to the scripts from the PC version. If the files are the same, the process is complete for the file; if not, there are things that are different in the 2 files.
