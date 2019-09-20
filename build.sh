#!/bin/sh

echo "Downloading the specified Ren'Py SDK..."
wget https://www.renpy.org/dl/$1/renpy-$1-sdk.tar.bz2
tar xf renpy-$1-sdk.tar-bz2
rm renpy-$1-sdk.tar.bz2
mv renpy-$1-sdk ../renpy

echo "Building the project..."
rm -rf game/README.html
../renpy/renpy.sh launcher distribute .
