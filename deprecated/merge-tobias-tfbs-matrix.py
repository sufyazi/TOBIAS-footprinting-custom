#!/usr/bin/env python3

import os
import glob
import polars as pl

# Specify the parent directory
parent_directory = "/home/msazizan/cargospace/tobias-analysis-outputs/tobias-tfbs-subset"

# Get a list of immediate subdirectories (one level deep)
subdirectories = [d for d in os.listdir(parent_directory) if os.path.isdir(os.path.join(parent_directory, d))]

# Loop through the subdirectories
for subdir in subdirectories:
    subdirectory_path = os.path.join(parent_directory, subdir)
    print(f"Subdirectory path: {subdirectory_path}")
    print(f"Directory name: {subdir}")

    # Create an empty dict to store DataFrames
    dataframes = {}
    # Create an empty list to store sample names
    sample_names = []

    # Loop through TSV files recursively in the directory
    for tsv_file in glob.iglob(os.path.join(subdirectory_path, '*.txt')):
        # Extract the filename from the path and split by underscore, and get only the first 2 elements
        sample_name = os.path.basename(tsv_file).split('_')[:2]

        # Extract the numeric part from the sample name (assumes format 'sampleXX')
        numeric_part = sample_name[1][6:]

        # Ensure the numeric part is two digits by adding leading zero if needed
        if len(numeric_part) == 1:
            numeric_part = '0' + numeric_part

        # Replace the numeric part with the two-digit version and add 'sample' prefix
        sample_name[1] = 'sample' + numeric_part

        # Join the sample name and append the sample name to the list
        sample_names.append('_'.join(sample_name))

        # Read TSV file into a DataFrame, rename the last column, and append to the dictionary
        df = pl.read_csv(tsv_file, separator = "\t")
        new_column_name = '_'.join(sample_name) + '_fp_score'
        df = df.rename({df.columns[-1]: new_column_name})
        dataframes['_'.join(sample_name)] = df

    # Sort the dataframes dictionary by keys (after 3.7 dictionaries can be sorted)
    sorted_dataframes = {k: dataframes[k] for k in sorted(dataframes.keys())}

    # Merge all DataFrames in the list while preserving common columns
    if sorted_dataframes:
        # Convert the dictionary to a list of DataFrames
        sorted_dataframes_list = list(sorted_dataframes.values())
        
        # Start with the first DataFrame in the list
        merged_df = sorted_dataframes_list[0]

        # Merge with all other Dataframes in the list 
        for df in sorted_dataframes_list[1:]:
            merged_df = merged_df.join(df, on=['TFBS_chr', 'TFBS_start', 'TFBS_end', 'TFBS_strand', 'TFBS_score'])
    
    print(merged_df)

     # check if the merged dataframe file exists
    if os.path.exists(f'/home/msazizan/cargospace/tobias-analysis-outputs/tobias-tfbs-subset-summary-files/{subdir}_tfbs_subset_merged_matrix.txt'):    
        print(f"File {subdir}_tfbs_subset_merged_matrix.txt already exists. Skipping...")
        continue
    else:
        # Write the merged DataFrame to a file
        print(f"Writing merged dataframe to file: {subdir}_tfbs_subset_merged_matrix.txt")
        merged_df.write_csv(f'/home/msazizan/cargospace/tobias-analysis-outputs/tobias-tfbs-subset-summary-files/{subdir}_tfbs_subset_merged_matrix.txt', separator ='\t')



