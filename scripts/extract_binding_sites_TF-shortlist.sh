#!/bin/bash
#shellcheck disable=SC2016
# Check if the required arguments are provided
if [ $# -ne 3 ]; then
    echo "Usage: $0 <input_prefix_file> <target_directory> <output_dir>"
    exit 1
fi

# Read the input arguments
input_prefix=$1
target_dir=$2
output_dir=$3

# Loop through each prefix in the input file
while IFS= read -r prefix; do
    # Use find to search for files with the given prefix and .txt suffix
    find "$target_dir" -name "${prefix}_overview.txt" -type f -exec awk -v OFS='\t' '{print $1, $2, $3, $4, $5, $6}' {} \; >> "$output_dir"/"$prefix"_binding_sites-basal-UP.txt
done < "$input_prefix"
