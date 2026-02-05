#!/usr/bin/env bash

sdk_name=renpy-$1-sdk
echo "Downloading the specified SDK (${sdk_name})..."
wget -q https://www.renpy.org/dl/$1/${sdk_name}.tar.bz2

echo "Setting up the specified SDK (${sdk_name})..."
tar -xf ./${sdk_name}.tar.bz2
rm ./${sdk_name}.tar.bz2
mv ./${sdk_name} ../renpy
echo "Setup SDK version (${sdk_name})."

# Get the project version by using renpy's json-dump command
tmp="$(mktemp)"
project_dir="$2"
../renpy/renpy.sh --json-dump "$tmp" "$project_dir" quit >/dev/null
project_version="$(jq -r '.build.version // .config.version // empty' "$tmp")"
rm -f "$tmp"

# used for steam, web, rapt
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
build_platform() {
    case "$3" in
        pc|win|mac|linux|market)
            COMMAND=(../renpy/renpy.sh ../renpy/launcher distribute --package "$3" "$2")
            ;;
        web)
            install_lib "$1" web
            COMMAND=(../renpy/renpy.sh ../renpy/launcher web_build "$2")
            ;;
        android)
            install_lib "$1" rapt
            echo "${ANDROID_SDK_ROOT}" > ../renpy/rapt/sdk.txt
            COMMAND=(../renpy/renpy.sh ../renpy/launcher android_build "$2")
            ;;
        *)
            COMMAND=(../renpy/renpy.sh ../renpy/launcher distribute "$2")
            ;;
    esac

    echo "Building the project for platform '$3' at '$2'..."
    "${COMMAND[@]}"
}

# Moves compiled distribution files to a single, pre-defined location
#
# Args:
#   $1: Output folder
#
# Outputs:
#   Writes `dir` and `version` to $GITHUB_OUTPUT
collect_distributions() {
    local output_dir="$1"
    local built_dir="$(find . -maxdepth 1 -type d -name '*-dists' -print -quit || true)"

    mkdir -p "$output_dir"

    if [[ -n "$built_dir" ]]; then
        rsync -a --remove-source-files "$built_dir/" "$output_dir/"
        rmdir "$built_dir" 2>/dev/null || true
    fi

    if [[ -d "../renpy/rapt/bin/" ]]; then
        rsync -a -m --remove-source-files \
            --include='*/' \
            --include='*-release.apk' \
            --exclude='*' \
            ../renpy/rapt/bin/ "$output_dir/"
    fi

    echo "dir=$output_dir" >> $GITHUB_OUTPUT
    echo "version=$project_version" >> $GITHUB_OUTPUT
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

collect_distributions "$5"