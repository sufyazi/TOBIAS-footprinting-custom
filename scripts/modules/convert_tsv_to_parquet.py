#!/usr/bin/env python3

import os
import sys
import glob
import polars as pl

# check arguments 
if len(sys.argv) != 3:
    print("Usage: convert_tsv_to_parquet.py <parent_directory> <output_directory>")
    sys.exit(1)

# get arguments
parent_directory = sys.argv[1]
output_directory = sys.argv[2]

# Loop through TSV files recursively in the subdirectory
tsv_files = glob.iglob(os.path.join(parent_directory, '*.txt'))

for tsv in tsv_files:
    print(f"Processing {tsv}...")
    basename_tsv = os.path.basename(tsv)
    basename_noext = os.path.splitext(basename_tsv)[0]
    
    # construct the output file name
    output_file = os.path.join(output_directory, f'{basename_noext}_brca.parquet')
    
    # read the TSV file into a DataFrame
    df = pl.read_csv(tsv, separator = "\t", infer_schema_length = 10000)
    print(f"DataFrame: {df}")
    # convert the DataFrame to Parquet
    df.write_parquet(output_file)
    print(f"File '{basename_noext}.parquet' has been created.")





