#!/bin/bash
set -exo pipefail

emsdk install 3.1.51
emsdk activate 3.1.51

# make -j`nproc` NATIVE=emscripten BACKTRACE=0 TILES=1 TESTS=0 RUNTESTS=0 RELEASE=1 cataclysm-tiles.js

make -j`nproc` NATIVE=emscripten BACKTRACE=0 TILES=1 TESTS=0 RUNTESTS=0 RELEASE=1 cataclysm-tiles.js \
    EMCCFLAGS="-s INITIAL_MEMORY=1073741824 -s MAXIMUM_MEMORY=2147483648"
