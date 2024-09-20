#!/bin/bash

work_dir=`pwd`
scripts_dir=$work_dir"/scripts"
output_dir=$work_dir"/build/data/gfx/"

cd raw-assets/gfx



function handle() {
    last_filename="<asdf>"
    last_time=0
    while read -r dir event filename; do
        time=$(date +%s)
        dt=$((time - last_time))

        if [ "$last_filename" != "$filename" ] || [ $dt -gt 0 ];  then
            if [ "$event" == "CREATE" ] || [ "$event" == "MODIFY" ]; then
                name=$(echo -n $filename | cut -d. -f1)
                out_dir=$output_dir$dir
                mkdir -p $out_dir
                aseprite -b $dir$filename --script-param filename=$out_dir$name'.lua' --script $scripts_dir/GameboyExport.lua
            fi

        fi

        last_filename=$filename
        last_time=$time

    done
}

# if [[ "$@" == "--now" ]]; then
echo "Building graphics..."
dir=raw-assets/gfx/
for filename in `find -name "*.png"`; do
    from=$dir$filename
    noext=$(echo -n $filename | awk -F".png" '{ print $1 }')
    to=$output_dir$noext.lua
    aseprite -b $filename --script-param filename=$to --script $scripts_dir/GameboyExport.lua

done
# else
    # inotifywait -m -r -e modify,create . | handle
# fi

cd -
