
# Bully: Scholarship Edition Lua Script Decompilation

This project aims to fully decompile all Lua scripts from Bully: Scholarship Edition for PC. The goal is to provide clean, readable, and editable Lua scripts for modding, troubleshooting, and understanding the game's inner workings.
> This was made by analysing and comparing the scripts from this version with a leaked pre-release debug version of the game for the Nintendo Wii.

## Installation

1) Download the source code, compile and strip the debug data from the script. If you are on Linux, you can use the script in `ShellScripts/CompileAll.sh`
2) Backup your game files (in case anything something goes wrong)
3) Open the game files and search for the folder `Scripts` and use a tool like [IMG Factory](https://www.gtagarage.com/mods/show.php?id=27155) to open `Scripts.img`
4) Replace all files inside withthe scripts you compiled
5) Rebuild the archive
6) Play the game!
7) 
## Decompilation process
1) Decompiled every script using [unluac](https://sourceforge.net/projects/unluac/).
2) Compared all files by name to identify files with the exact same contents.
3) Edit the files that are different, while adding, changing or removing chunks that don't match the scripts for the PC version. Function calls to `print`, `assert` and `DebugPrint` are left commented.
5) Compile all modified files and strip debug information.
6) Decompile again and compare the result to the scripts from the PC version. If the files are the same, the bytecode should be compared to find changes that are harder to find; if not, there are things that are different in the 2 files.
7) Disassemble all modified files and compare with disassemblies from the PC version. If the files are the same, the process is complete; if not, try to figure out what changes should be made to ensure 100% fidelity.

All scripts compile to exactly the same as the originals, except for `.linedefined` fields, which are basically fields in the decompiled file that tell in which line a function starts in the original source code. This means nothing to the logic and function of the game.

## Folder structure

All game scripts are in the folder `scripts`

#### ShellScripts

This folder does not contain game files. A folder containing scripts used as tools to automate repetitive tasks

#### Ambient

In-game errands

#### AreaScripts

Scripts related to the map, there is one for each game AreaScripts

#### chap1-6

Main mission scripts, divided by chapters. There are only 5 chapters in the game, but that was not the case at some point during development. Some scripts are out of place in these folders

#### classes

Dispite the name, contains only Gym class, part of Photography class, and dodgeball game

#### Library

Library scripts, used for various purposes

#### POI

Random events throughout the map, such as conversation spots and others

#### Punishment

Related to punishment mini-games

#### secnd

Secondary missions, classes and mini-games

#### Test

Testing scripts

#### Test/Missions

Scripts to start every mission
## Authors

- [@Razcoina](https://github.com/Razcoina)
- [@nixkiez](https://github.com/nixkiez)
