#!/usr/bin/env bash

sdk_version="$1"
project_dir="$2"
targets="$3"
add_steam_lib="$4"
output_dir="$5"

sdk_name="renpy-$sdk_version-sdk"
renpy_dir="../renpy"
renpy_sh="$renpy_dir/renpy.sh"
renpy_launcher="$renpy_dir/launcher"

echo "Downloading the specified SDK (${sdk_name})..."
wget -q "https://www.renpy.org/dl/$sdk_version/${sdk_name}.tar.bz2"

echo "Setting up the specified SDK (${sdk_name})..."
tar -xf ./${sdk_name}.tar.bz2
rm ./${sdk_name}.tar.bz2
mv ./${sdk_name} "$renpy_dir"
echo "Setup SDK version (${sdk_name})."

# Get the project version by using renpy's json-dump command
tmp="$(mktemp)"
"$renpy_sh" --json-dump "$tmp" "$project_dir" quit >/dev/null
project_version="$(jq -r '.build.version // .config.version // empty' "$tmp")"
rm -f "$tmp"

# used for steam, web, rapt
install_lib() {
    local lib="$1"
    local name="renpy-$sdk_version-$lib"

    echo "Downloading '${lib}' lib (${name})..."
    wget -q "https://www.renpy.org/dl/${sdk_version}/${name}.zip"

    echo "Adding '${lib}' lib to Renpy..."
    unzip -qq "./${name}.zip" -d "${name}"
    rsync -a "${name}/" "$renpy_dir"
    rm -rf "${name}" "${name}.zip"
    echo "Added '${lib}' lib (${name})..."
}

# Builds a Ren'Py distribution for a target platform
#
# Args:
#   $1: Target platform (pc|win|mac|linux|market|web|android). Default: All.
#
# Outputs:
#   Writes `dir` and `version` to $GITHUB_OUTPUT on success
build_platform() {
    local target="$1"
    local COMMAND=("$renpy_sh" "$renpy_launcher")

    case "$target" in
        pc|win|mac|linux|market)
            COMMAND+=(distribute --package "$target" "$project_dir")
            ;;
        web)
            install_lib web
            COMMAND+=(web_build "$project_dir")
            ;;
        android)
            install_lib rapt
            echo "${ANDROID_SDK_ROOT}" > $renpy_dir/rapt/sdk.txt
            COMMAND+=(android_build "$project_dir")
            ;;
        *)
            COMMAND+=(distribute "$project_dir")
            ;;
    esac

    echo "Building the project for platform '$target' at '$project_dir'..."
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

    if [[ -d "$renpy_dir/rapt/bin/" ]]; then
        rsync -a -m --remove-source-files \
            --include='*/' \
            --include='*-release.apk' \
            --exclude='*' \
            "$renpy_dir/rapt/bin/" "$output_dir/"
    fi

    echo "dir=$output_dir" >> $GITHUB_OUTPUT
    echo "version=$project_version" >> $GITHUB_OUTPUT
}

if [ "$add_steam_lib" = "true" ]; then
    install_lib steam
fi

# Note: This will be checked regardless of the version of Ren'Py. Caution is advised.
if [ -d "$project_dir/old-game" ]; then
    echo "old-game directory detected."
    if [ -z "$(ls -A "$project_dir/old-game")" ]; then
        echo "ERROR: old-game is empty. This will cause incompatibility issues."
        echo "For more information on how the old-game directory works and why"
        echo "this directory should not be empty, please refer to the documentation"
        echo "at: https://www.renpy.org/doc/html/build.html#old-game."
        exit 1
    fi
fi

# Split $targets into an array of target platforms
[[ -n ${targets} ]] && read -r -a target_platforms <<<"$targets" || target_platforms=("all")

# Build for listed platforms
for i in "${target_platforms[@]}"; do
    build_platform "$i"
done

collect_distributions "$output_dir"