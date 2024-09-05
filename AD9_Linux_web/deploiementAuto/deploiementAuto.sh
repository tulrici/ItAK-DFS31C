#!/bin/bash

keepReleases=5

mkdir -p project/current/releases
mkdir -p project/shared

# Read options
while getopts ":k:" opt; do
  case ${opt} in
    k )
        keepReleases=$OPTARG
        ;;
    deploy )
        # Deploy the project
        ;;
    rollback )
        # Rollback the project
        ;;
  esac
done

timestamp=$(date +"%Y%m%d%H%M%S")
mkdir project/current/release/${timestamp}

cd project/current/release
# List directories, sort them in reverse order, skip the newest based on keepReleases count, and remove the older ones
ls -1 |                       # List all items in the directory, one per line
sort -r |                     # Sort the list in reverse order (newest first)
tail -n +$((keepReleases + 1)) |  # Skip the first 'keepReleases' items, listing only older ones
xargs -I {} rm -rf {}         # For each listed item, delete it recursively and forcefully


# Find all files in the shared directory, create symbolic links in the release folder
find "project/shared" -type f -print0 | while IFS= read -r -d '' file; do  
  # Create the corresponding directory structure in the release folder, if it doesn't exist
  mkdir -p "project/current/release"
  
  # Create a symbolic link in the new directory, pointing to the original file
  ln -s "$PWD/$file" "$PWD/project/current/release/$(basename "$file")"
done
