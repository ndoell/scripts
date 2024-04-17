#!/usr/local/bin/bash

# Function to recursively read files and extract npm dependencies and devDependencies
read_files() {
    local file="$1"

    # Check if the file exists
    if [ -f "$file" ]; then
        # Extract npm dependencies and devDependencies using grep and regex
        grep -Eo '"(dependencies|devDependencies)": ?\{[^}]+\}' "$file" | while read -r line; do
            # Remove the keys 'dependencies' or 'devDependencies' for cleaner output
            echo "$line" | sed -E 's/"(dependencies|devDependencies)": //' >> "$temp_file"
        done
    elif [ -d "$file" ]; then
        # If it's a directory, iterate over its contents
        for f in "$file"/*; do
            read_files "$f"
        done
    fi
}

# Check if enough arguments are provided
if [ $# -ne 2 ]; then
    echo "Usage: $0 <search_directory> <output_directory>"
    exit 1
fi

search_dir="$1"
output_dir="$2"
temp_file="temp_deps.txt"

# Check if the search directory exists
if [ ! -d "$search_dir" ]; then
    echo "Search directory not found: $search_dir"
    exit 1
fi

# Check if the output directory exists, create it if not
if [ ! -d "$output_dir" ]; then
    mkdir -p "$output_dir"
    if [ $? -ne 0 ]; then
        echo "Failed to create output directory: $output_dir"
        exit 1
    fi
fi

# Clear temp file before use
> "$temp_file"

# Start reading files from the specified directory recursively
read_files "$search_dir"

# Sort and remove duplicates before writing to the final output file
sort -u "$temp_file" > "$output_dir/npm_dependencies.loot"

# Remove temporary file
rm "$temp_file"

echo "Unique NPM dependencies and devDependencies extracted and saved to $output_dir/npm_dependencies.loot"
