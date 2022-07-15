#!/bin/sh

cd snapshots || exit 2

if [ -d archive.3 ]; then
    rm -rf archive.3
fi
if [ -d archive.2 ]; then
    mv archive.2 archive.3
fi
if [ -d archive ]; then
    mv archive archive.2
fi
mkdir archive
find . -type f -name "2*.jpg" -maxdepth 1 | xargs -I '{}' -n 1  mv '{}' archive/


