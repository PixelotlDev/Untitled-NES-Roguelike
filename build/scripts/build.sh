#!/usr/bin/env sh
set -e

# build failed, clean up any leftover files and quit
function failed {
    echo ""
    echo "---Build failed---"

    if test -f build/main.o; then
        rm build/main.o
    fi

    if test -f build/
    NES-Roguelike.nes.backup; then
        mv build/NES-Roguelike.nes.backup build/NES-Roguelike.nes
    fi

    if test -f build/info/map.txt.backup; then
        mv build/info/map.txt.backup build/info/map.txt
    fi

    if test -f build/info/labels.txt.backup; then
        mv build/info/labels.txt.backup build/info/labels.txt
    fi

    if test -f build/info/NES-Roguelike.dbg.backup; then
        mv build/info/NES-Roguelike.dbg.backup build/info/NES-Roguelike.dbg
    fi

    exit
}

# we do this first, despite the fact that it would be more convenient code-wise to insert the following rename in between these cd's,
# because we want to stay in the same directory the whole build - switching around can make using functions unpredictable
cd ..
cd ..

# --setup--
echo "Setting up..."

# create info and info/nes directories if they don't exist
if ! test -d "build/info/nes"; then
    mkdir build/info/
    mkdir build/info/nes/
fi

# rename current build files if they exist, so we can bring them back if the new build fails
if test -f build/NES-Roguelike.nes; then
    mv build/NES-Roguelike.nes build/NES-Roguelike.nes.backup
fi

if test -f build/info/map.txt; then
    mv build/info/map.txt build/info/map.txt.backup
fi

if test -f build/info/labels.txt; then
    mv build/info/labels.txt build/info/labels.txt.backup
fi

if test -f build/info/NES-Roguelike.dbg; then
    mv build/info/NES-Roguelike.dbg build/info/NES-Roguelike.dbg.backup
fi

echo "Setup complete"
echo ""

# --compile--
echo "Compiling..."

# compile our code, and if that fails, run the failed function
if ca65 src/main.asm -g -o build/main.o ; then
    echo "Compiling complete"
    echo ""
else
    failed
fi

# --link--
echo "Linking..."

if ld65 -o build/NES-Roguelike.nes -C src/linker.cfg build/main.o -m build/info/map.txt -Ln build/info/labels.txt --dbgfile build/info/NES-Roguelike.dbg ; then
    echo "Linking complete"
    echo ""
else
    failed
fi

echo "Cleaning up..."

# remove the .o file, we only needed that for the linking
rm build/main.o

# remove all of our backup files, we don't need them anymore
if test -f build/NES-Roguelike.nes.backup; then
    rm build/NES-Roguelike.nes.backup
fi

if test -f build/info/map.txt.backup; then
    rm build/info/map.txt.backup
fi

if test -f build/info/labels.txt.backup; then
    rm build/info/labels.txt.backup
fi

if test -f build/info/NES-Roguelike.dbg.backup; then
    rm build/info/NES-Roguelike.dbg.backup
fi

python build/scripts/fceux_symbols.py

echo "Cleanup complete"
echo ""
echo "Build complete"
