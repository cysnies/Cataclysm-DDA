#!/bin/bash
set -exo pipefail

rm -rf web_bundle

# install tools for compiling language files
sudo apt update
sudo apt install gettext tree -y

BUNDLE_DIR=web_bundle
DATA_DIR=$BUNDLE_DIR/data
mkdir -p $DATA_DIR
cp -R data/{core,font,fontdata.json,json,mods,names,raw,motd,credits,title,help} $DATA_DIR/
cp -R gfx $BUNDLE_DIR/

# compile language files for zh_CN
mkdir -p lang/mo
bash lang/compile_mo.sh zh_CN

# copy lang folder to bundle dir
mkdir -p $BUNDLE_DIR/lang
cp -r lang/mo $BUNDLE_DIR/lang/

# Remove .DS_Store files.
find web_bundle -name ".DS_Store" -type f -exec rm {} \;

# Remove obsolete mods.
echo "Removing obsolete mods..."
for MOD_DIR in $DATA_DIR/mods/*/ ; do
    if jq -e '.[] | select(.type == "MOD_INFO") | .obsolete' "$MOD_DIR/modinfo.json" >/dev/null; then
        echo "$MOD_DIR is obsolete, excluding from web_bundle..."
        rm -rf $MOD_DIR
    fi
done

echo "Removing MA mod..."
rm -rf $DATA_DIR/mods/MA
echo "Removing Ultica_iso tileset..."
rm -rf $BUNDLE_DIR/gfx/Ultica_iso

$EMSDK/upstream/emscripten/tools/file_packager cataclysm-tiles.data --js-output=cataclysm-tiles.data.js --no-node --preload "$BUNDLE_DIR""@/" --lz4

mkdir -p build/
cp \
  build-data/web/index.html \
  cataclysm-tiles.{data,data.js,js,wasm} \
  data/font/Terminus.ttf \
  build
cp data/cataicon.ico build/favicon.ico
