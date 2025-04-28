#!/bin/sh

sdk_name=renpy-$1-sdk
echo "Downloading the specified SDK (${sdk_name})..."
wget -q https://www.renpy.org/dl/$1/${sdk_name}.tar.bz2
clear

echo "Downloaded SDK version (${sdk_name})."
echo "Setting up the specified SDK (${sdk_name})..."
tar -xf ./${sdk_name}.tar.bz2
rm ./${sdk_name}.tar.bz2
mv ./${sdk_name} ../renpy

if [ $4 = "true" ]; then
    steam_lib_name=renpy-$1-steam
    echo "Downloading Steam lib (${steam_lib_name})..."
    wget -q https://www.renpy.org/dl/$1/${steam_lib_name}.zip
    clear

    echo "Downloaded Steam lib (${steam_lib_name})..."
    echo "Adding Steam lib to Renpy"
    unzip -qq ./${steam_lib_name} -d ${steam_lib_name}
    rsync -a ${steam_lib_name}/ ../renpy
    rm -rf ${steam_lib_name} ${steam_lib_name}.zip 
fi

# Note: This will be checked regardless of the version of Ren'Py. Caution is
# advised.
if [ -d "$2/old-game" ]; then
    echo "old-game directory detected."
    if [ -z "$(ls -A "$2/old-game")" ]; then
        echo "ERROR: old-game is empty. This will cause incompatibility issues."
        echo "For more information on how the old-game directory works and why"
        echo "this directory should not be empty, please refer to the documentation"
        echo "at: https://www.renpy.org/doc/html/build.html#old-game."
        exit 1
    fi
fi

if [[ -v $3[@] ]]; then
  for i in "${3[@]}"
    do
        if [[ $i == 'android' ]]; then
            COMMAND="../renpy/renpy.sh ../renpy/launcher android_build ./"
        else
            COMMAND="../renpy/renpy.sh ../renpy/launcher distribute --package $i $2"
        fi
        echo "Building $i"
        if $COMMAND; then
            built_dir=$(ls | grep '\-dists')
            echo dir=$built_dir >> $GITHUB_OUTPUT
            echo version=${built_dir%'-dists'} >> $GITHUB_OUTPUT
        else
            return 1
        fi
    done
else
    case $3 in
        pc|win|mac|linux|market|web)
            COMMAND="../renpy/renpy.sh ../renpy/launcher distribute --package $3 $2"
            ;;
        android)
            COMMAND="../renpy/renpy.sh ../renpy/launcher android_build ./"
            ;;
        *)
            COMMAND="../renpy/renpy.sh ../renpy/launcher distribute $2"
            ;;
    esac
    
    echo "Building the project at $2..."
    if $COMMAND; then
        built_dir=$(ls | grep '\-dists')
        echo dir=$built_dir >> $GITHUB_OUTPUT
        echo version=${built_dir%'-dists'} >> $GITHUB_OUTPUT
    else
        return 1
    fi
fi

