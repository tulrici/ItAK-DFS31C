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
shared_dir="project/shared"
current_link="project/current/release"

# Ensure the required directories exist
mkdir -p "$releases_dir" "$shared_dir"

# Function to update the 'current' symbolic link
update_current() {
    ln -sfn "$1" "$current_link"
    echo "Current release set to: $(basename $1)"

    # Clean any existing symbolic links in the shared directory
    find "$shared_dir" -type l -exec rm {} \;
    # Create a new symbolic link in shared directory pointing to the new current
    ln -s "$1" "$shared_dir/current_release"
}

# Deployment logic
deploy() {
    local timestamp=$(date +"%Y%m%d%H%M%S")
    local new_release_dir="$releases_dir/$timestamp"
    mkdir -p "$new_release_dir"
    find "$shared_dir" -type f -print0 | while IFS= read -r -d '' file; do
        local subdir=$(dirname "${file#$shared_dir/}")
        mkdir -p "$new_release_dir/$subdir"
        ln -s "$PWD/$file" "$new_release_dir/$subdir/$(basename "$file")"
    done
    update_current "$new_release_dir"
    echo "Deployment complete: $timestamp"
}

# Rollback logic
rollback() {
    local releases=($(ls -1tr "$releases_dir"))
    if [ ${#releases[@]} -lt 2 ]; then
        echo "Rollback not possible: Not enough releases."
        return 1
    fi
    local current_index=$(basename "$(readlink "$current_link")")
    for (( i=0; i<${#releases[@]}; i++ )); do
        if [[ "${releases[i]}" == "$current_index" && $i -gt 0 ]]; then
            update_current "${releases_dir}/${releases[$i-1]}"
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