#!/bin/bash

# Define cache and wallpaper directories
CACHE_DIR="/tmp/wallpaper_cache"
WALLPAPER_DIR="$HOME/Pictures/Wallpapers"

# Make sure the cache directory exists
mkdir -p "$CACHE_DIR"

# Get the cached image path
get_cached_image_path() {
    local original_path="$1"
    local file_name
    file_name=$(basename "$original_path")
    echo "${CACHE_DIR}/${file_name}"
}

# Scale and cache the image
scale_and_cache_image() {
    local original_path="$1"
    local width="$2"
    local height="$3"
    local cached_image_path
    cached_image_path=$(get_cached_image_path "$original_path")

    # If the image is already cached, return its path
    if [ -f "$cached_image_path" ]; then
        echo "$cached_image_path"
        return 0
    fi

    # If the image isn't cached, scale it using convert (ImageMagick)
    convert "$original_path" -resize "${width}x${height}" "$cached_image_path"
    if [ $? -eq 0 ]; then
        echo "$cached_image_path"
    else
        echo "Error scaling image: $original_path" >&2
        echo "$original_path"
    fi
}

# Get wallpapers from the specified directory
get_wallpapers_from_folder() {
    local wallpapers=()
    local unique_basenames=()

    while IFS= read -r -d '' file; do
        local base_name
        base_name=$(basename "$file" | sed 's/\.[^.]*$//')

        if [[ ! " ${unique_basenames[@]} " =~ " ${base_name} " ]]; then
            unique_basenames+=("$base_name")
            wallpapers+=("$file")
        fi
    done < <(find "$WALLPAPER_DIR" -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" \) -print0)

    # Sort the wallpapers alphabetically
    IFS=$'\n' sorted_wallpapers=($(sort <<<"${wallpapers[*]}"))
    unset IFS

    echo "${sorted_wallpapers[@]}"
}

# Main function to process all wallpapers
main() {
    local width=100
    local height=100

    # Get wallpapers from the folder
    wallpapers=$(get_wallpapers_from_folder)

    # Process each wallpaper
    for wallpaper in $wallpapers; do
        scale_and_cache_image "$wallpaper" "$width" "$height"
    done
}

# If 3 arguments are provided, process a single image with the specified size
if [ $# -eq 3 ]; then
    scale_and_cache_image "$1" "$2" "$3"
    exit 0
fi

# If no arguments are provided, process all wallpapers
if [ $# -eq 0 ]; then
    main
fi
