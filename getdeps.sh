#!/bin/bash

# Function to recursively read files and extract npm dependencies
read_files() {
    local file="$1"

    # Check if the file exists
    if [ -f "$file" ]; then
        # Extract npm dependencies using grep and regex
        dependencies=$(grep -Eo '"dependencies": ?\{[^}]+\}' "$file" | sed 's/"dependencies": //')

        # Check if dependencies exist
        if [ -n "$dependencies" ]; then
            echo "$dependencies" >> npm_dependencies.txt
        fi
    elif [ -d "$file" ]; then
        # If it's a directory, iterate over its contents
        for f in "$file"/*; do
            read_files "$f"
        done
    fi
}

# Check if directory path is provided as argument
if [ $# -ne 1 ]; then
    echo "Usage: $0 <directory>"
    exit 1
fi

directory="$1"

# Check if the directory exists
if [ ! -d "$directory" ]; then
    echo "Directory not found: $directory"
    exit 1
fi

# Start reading files from the specified directory recursively
read_files "$directory"

echo "NPM dependencies extracted and saved to npm_dependencies.txt"
