#!/bin/bash

output_dir=$(pwd)/build/data/tilemaps

cd raw-assets/tilemaps

function build_tilemap() {
    input=$1
    output=$output_dir/$(echo -n $input |  sed -E 's/\.tmx/\.lua/g')
    echo "Generating [$output] from [$input]"
    tiled --export-map lua $input $output
}

echo "Building tilemaps..."

for file in `find -name "*.tmx"`; do
    build_tilemap $file
done

