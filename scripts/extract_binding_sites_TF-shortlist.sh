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
    # check if the output file exists
    if [ -f "$output_dir"/"$prefix"_binding_sites-basal-UP.txt ]; then
        echo "Output file ${output_dir}/${prefix}_binding_sites-basal-UP.txt already exists. Skipping..."
        continue
    else
        echo "Processing $prefix..."
        # Use find to search for files with the given prefix and .txt suffix
        find "$target_dir" -name "${prefix}_overview.txt" -type f -exec awk -v OFS='\t' '{print $1, $2, $3, $4, $5, $6}' {} \; >> "$output_dir"/"$prefix"_binding_sites-basal-UP.txt && awk -v OFS='\t' '{print $1, $2, $3, $4}' "$output_dir"/"$prefix"_binding_sites-basal-UP.txt | tail -n +2 | sort -k1,1V -k2,2n >> "$output_dir"/"$prefix"_binding_sites-basal-UP_4col.bed
    fi
done < "$input_prefix"
