#!/bin/bash

# Array to store files without the type declaration
files_without_type=()

# Loop through all .tf files in the current directory
for file in *.tf; do
    # Check if the file contains the type declaration
    if ! grep -q 'type = string' "$file"; then
        # If not, add the file to the array
        files_without_type+=("$file")
    fi
done

# Check if there are any files without the type declaration
if [ ${#files_without_type[@]} -eq 0 ]; then
    echo "All .tf files have the type declaration."
else
    echo "The following .tf files do not have the type declaration:"
    printf '%s\n' "${files_without_type[@]}"
fi
