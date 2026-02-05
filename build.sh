#!/usr/bin/env bash

sdk_name=renpy-$1-sdk
echo "Downloading the specified SDK (${sdk_name})..."
wget -q https://www.renpy.org/dl/$1/${sdk_name}.tar.bz2

echo "Setting up the specified SDK (${sdk_name})..."
tar -xf ./${sdk_name}.tar.bz2
rm ./${sdk_name}.tar.bz2
mv ./${sdk_name} ../renpy
echo "Setup SDK version (${sdk_name})."

# used for steam and web
install_lib() {
    version="$1"
    lib="$2"
    name="renpy-$version-$lib"

    echo "Downloading '${lib}' lib (${name})..."
    wget -q "https://www.renpy.org/dl/${version}/${name}.zip"

    echo "Adding '${lib}' lib to Renpy..."
    unzip -qq "./${name}.zip" -d "${name}"
    rsync -a "${name}/" ../renpy
    rm -rf "${name}" "${name}.zip"
    echo "Added '${lib}' lib (${name})..."
}

# Builds a Ren'Py distribution for a target platform
#
# Args:
#   $1: Version
#   $2: Project path
#   $3: Target platform (pc|win|mac|linux|market|web|android). Default: All.
#
# Outputs:
#   Writes `dir` and `version` to $GITHUB_OUTPUT on success
#
# Returns:
#   0 on success; non-zero on failure.
build_platform() {
    case $3 in
        pc|win|mac|linux|market)
            COMMAND="../renpy/renpy.sh ../renpy/launcher distribute --package $3 $2"
            ;;
        web)
            install_lib "$1" web
            COMMAND="../renpy/renpy.sh ../renpy/launcher web_build $2"
            ;;
        android)
            COMMAND="../renpy/renpy.sh ../renpy/launcher android_build $2"
            ;;
        *)
            COMMAND="../renpy/renpy.sh ../renpy/launcher distribute $2"
            ;;
    esac
    
    echo "Building the project for platform '$3' at '$2'..."
    if $COMMAND; then
        built_dir=$(ls | grep '\-dists')
        echo dir=$built_dir >> $GITHUB_OUTPUT
        echo version=${built_dir%'-dists'} >> $GITHUB_OUTPUT
    else
        return 1
    fi
}

if [ $4 = "true" ]; then
    install_lib "$1" steam
fi

# Note: This will be checked regardless of the version of Ren'Py. Caution is advised.
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

# Split $3 into an array of target platforms
[[ -n ${3-} ]] && read -r -a target_platforms <<<"$3" || target_platforms=("all")

# Build for listed platforms
for i in "${target_platforms[@]}"; do
    build_platform "$1" "$2" "$i"
done
