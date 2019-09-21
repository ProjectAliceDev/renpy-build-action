#!/bin/sh

sdk_name=renpy-$1-sdk
echo "Downloading the specified SDK (${sdk_name})..."
wget https://www.renpy.org/dl/$1/${sdk_name}.tar.bz2
clear

echo "Downloaded SDK version (${sdk_name})."
echo "Setting up the specified SDK (${sdk_name})..."
tar -xf ./${sdk_name}.tar.bz2
rm ./${sdk_name}.tar.bz2
mv ./${sdk_name} ../renpy

if [ -z "$2" ]; then
  echo "Building the project at $2..."
  ../renpy/renpy.sh ../renpy/launcher distribute $2

else
  echo "Building the project at root..."
  ../renpy/renpy.sh ../renpy/launcher distribute .

fi

built_dir=$(ls | grep '\-dists')
echo ::set-output name=dir::$built_dir
echo ::set-output name=version::${built_dir%'-dists'}
