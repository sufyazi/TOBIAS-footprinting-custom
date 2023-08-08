#!/usr/bin/env bash
# This script is used to run the job on the NSCC cluster.

#PBS -N extract-tfbs-tobias-output
#PBS -l select=1:ncpus=12:mem=32GB
#PBS -l walltime=4:00:00
#PBS -j oe
#PBS -P personal
#PBS -q normal


# Define the input file and new file directory
file=$FILE_INP
new_file_dir=$FILE_OUT

# Start the extraction process
echo "Extracting binding sites..."

# Use AWK to process the file and extract selected columns
if awk -F'\t' 'BEGIN {OFS="\t"} {
    print $1, $2, $3, $6, $5, $10
}' "$file" > "$new_file_dir"; then
    echo "Extraction done!"
else
    echo "An error occurred. Check logs."
fi


