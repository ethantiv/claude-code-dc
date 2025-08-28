#!/bin/bash

# Base path for all projects
BASE_PATH="/Users/mirek/Projekty"

# List of target directories (relative to BASE_PATH)
TARGET_DIRS=(
    "/Roche/RIS-Navify-Data-Platform"
)

# Source directory
SOURCE_DIR=".devcontainer"

# Check if source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: Source directory '$SOURCE_DIR' does not exist"
    exit 1
fi

echo "Starting .devcontainer sync..."
echo "Source: $PWD/$SOURCE_DIR"
echo ""

# Process each target directory
for target_dir in "${TARGET_DIRS[@]}"; do
    full_path="${BASE_PATH}${target_dir}"
    
    echo "Processing: $full_path"
    
    # Check if target directory exists
    if [ ! -d "$full_path" ]; then
        echo "  Warning: Target directory does not exist, skipping"
        continue
    fi
    
    # Remove existing .devcontainer if it exists
    if [ -d "$full_path/.devcontainer" ]; then
        echo "  Removing existing .devcontainer..."
        rm -rf "$full_path/.devcontainer"
    fi
    
    # Copy .devcontainer directory
    echo "  Copying .devcontainer..."
    cp -r "$SOURCE_DIR" "$full_path/"
    
    if [ $? -eq 0 ]; then
        echo "  ✓ Successfully copied"
    else
        echo "  ✗ Failed to copy"
    fi
    
    echo ""
done

echo "Sync completed!"