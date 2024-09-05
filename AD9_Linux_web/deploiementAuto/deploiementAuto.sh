#!/bin/bash

keepReleases=5
releases_dir="project/current/releases"
shared_dir="project/shared"
current_link="project/current/release"

# Ensure necessary directories exist
mkdir -p "$releases_dir" "$shared_dir"

# Function to handle deployment
deploy() {
    local timestamp=$(date +"%Y%m%d%H%M%S")
    local new_release_dir="$releases_dir/$timestamp"
    mkdir -p "$new_release_dir"

    # Find and link all files from the shared directory
    find "$shared_dir" -type f -print0 | while IFS= read -r -d '' file; do  
        local subdir=$(dirname "${file#$shared_dir/}")
        mkdir -p "$new_release_dir/$subdir"
        ln -s "$PWD/$file" "$new_release_dir/$subdir/$(basename "$file")"
    done

    # Update current symlink to new release
    ln -sfn "$new_release_dir" "$current_link"
    echo "Deployment complete: $timestamp"
}

# Function to handle rollback
rollback() {
    # Read all directories in release, sorted by date (oldest to newest)
    local releases=($(ls -1t "$releases_dir"))
    # Find the index of the currently active release
    local current_index=$(basename $(readlink "$current_link"))

    for (( i=0; i<${#releases[@]}; i++ )); do
        if [[ "${releases[i]}" == "$current_index" && $i -gt 0 ]]; then
            # Set symlink to the previous release in the list
            ln -sfn "${releases_dir}/${releases[$i-1]}" "$current_link"
            echo "Rolled back to: ${releases[$i-1]}"
            return
        fi
    done

    echo "Rollback not possible: Current release is the oldest or not found."
}

# Read options
while getopts ":k:" opt; do
  case ${opt} in
    k )
        keepReleases=$OPTARG
        ;;
    \? )
        echo "Invalid option: -$OPTARG" >&2
        exit 1
        ;;
  esac
done

# Shift off the options and the -- that were processed by getopts.
shift $((OPTIND-1))

# Process commands
case "$1" in
    deploy)
        deploy
        ;;
    rollback)
        rollback
        ;;
    *)
        echo "Usage: $0 {deploy|rollback} [-k number_of_releases]"
        exit 1
        ;;
esac

# Cleanup old releases
cd "$releases_dir"
ls -1 | sort -r | tail -n +$((keepReleases + 1)) | xargs -r rm -rf
echo "Old releases cleaned up, keeping the last $keepReleases."