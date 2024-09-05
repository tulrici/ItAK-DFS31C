#!/bin/bash

# Configuration file path
config_file="config.txt"

# Load configurations
if [ -f "$config_file" ]; then
    source "$config_file"
else
    # Default value if configuration file does not exist
    keepReleases=5
fi

# Function to save current configurations
save_config() {
    echo "keepReleases=$keepReleases" > "$config_file"
}

# Define base directories
releases_dir="project/current/releases"
release_dir="project/current/release"  # Directory for the actual 'current' directory, not just a symlink
shared_dir="project/shared"
dev_dir="project/dev"

# Ensure the required directories exist
mkdir -p "$releases_dir" "$release_dir" "$shared_dir" "$dev_dir"

# Function to update the 'current' directory to the latest release
update_current() {
    local new_release_path="$1"
    local release_name=$(basename "$new_release_path")

    # Check if current link exists and move it to releases before updating
    if [ -L "$release_dir/current" ]; then
        local old_release_path=$(readlink "$release_dir/current")
        local old_release_name=$(basename "$old_release_path")
        mv "$old_release_path" "$releases_dir/$old_release_name"
        echo "Moved old release $old_release_name to releases directory."
    fi

    # Update 'current' directory
    ln -sfn "$new_release_path" "$release_dir/current"
    echo "Current release set to: $release_name"
}

# Deployment logic
deploy() {
    local timestamp=$(date +"%Y%m%d%H%M%S")
    local new_release_dir="$release_dir/$timestamp"
    mkdir -p "$new_release_dir"
    find "$dev_dir" -type f -print0 | while IFS= read -r -d '' file; do
        local subdir=$(dirname "${file#$dev_dir/}")
        mkdir -p "$new_release_dir/$subdir"
        ln -s "$PWD/$file" "$new_release_dir/$subdir/$(basename "$file")"
    done
    update_current "$new_release_dir"
    echo "Deployment complete: $timestamp"
}

# Rollback logic
rollback() {
    local releases=($(ls -1tr "$releases_dir"))
    if [ ${#releases[@]} -eq 0 ]; then
        echo "Rollback not possible: Not enough releases."
        return 1
    fi
    local current_index=$(basename "$(readlink "$releases_dir/current")")
    for (( i=0; i<${#releases[@]}; i++ )); do
        if [[ "${releases[i]}" == "$current_index" && $i -gt 0 ]]; then
            update_current "${release_dir}/${releases[$i-1]}"
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
        save_config
        ;;
    \? )
        echo "Invalid option: -$OPTARG" >&2
        exit 1
        ;;
  esac
done

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