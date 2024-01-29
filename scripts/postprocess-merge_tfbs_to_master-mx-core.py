#!/usr/bin/env python3

import os
import sys
import time
import glob
import polars as pl
from modules.utilities import downcast_df

input_directory = sys.argv[1]
output_directory = sys.argv[2]
process_flag = sys.argv[3]
motif = sys.argv[4]
motif_counter = sys.argv[5]
try:
    id_list = sys.argv[6]
except IndexError:
    id_list = None


# Create an empty dict to store DataFrames
dataframes = {}

# Construct the path to the subdirectory
motif_dirpath = os.path.join(input_directory, motif)
# print(f"Motif directory path: {motif_dirpath}")
print(f"Motif name [no. {motif_counter}]: {motif}")

# if process_flag is set to "subset", loop through the id_list
if process_flag == "subset":
    # Construct an empty list to store TSV file lists from different IDs
    list_of_tsv_file_lists = []
    for ids in id_list:
        # Get a list of TSV files in the subdirectory
        tsv_file_list = glob.glob(os.path.join(motif_dirpath, f'{ids}*.txt'))
        # Append the list of TSV files to the list of TSV file lists
        list_of_tsv_file_lists.append(tsv_file_list)
    # Flatten the list of TSV file lists
    tsv_files = [item for sublist in list_of_tsv_file_lists for item in sublist]
    print(f"Number of TSV files in total: {len(tsv_files)}")
elif process_flag == "all":
    # Loop through TSV files recursively in the subdirectory
    tsv_files = glob.iglob(os.path.join(motif_dirpath, '*.txt'))
    ### Note: glob.iglob() returns an iterator, which will be exhausted after the first iteration so make sure not to use it more than once

# initialize counter
inner_counter = 0
# start timer
start_time = time.time()
# Loop through TSV files recursively in the subdirectory
for tsv in tsv_files:
    # Increment counter
    inner_counter += 1
    print(f"TSV file [no. {inner_counter}]: {tsv}")
    # Extract the filename from the path and split by underscore, and get only the first 2 elements
    sample_name = os.path.basename(tsv).split('_')[:2]
    print(f"Old sample ID: {sample_name}")
    # Extract the numeric part from the sample name (assumes format 'sampleXX')
    numeric_part = sample_name[1][6:]
    # Ensure the numeric part is two digits by adding leading zero if needed
    if len(numeric_part) == 1:
        numeric_part = '00' + numeric_part
    elif len(numeric_part) == 2:
        numeric_part = '0' + numeric_part
    # Replace the numeric part with the three-digit version and add 'sample' prefix
    sample_name[1] = 'sample' + numeric_part
    print(f"New sample ID: {sample_name}")
    
    # Read TSV file into a DataFrame, rename the last column, and append to the dictionary
    df = pl.read_csv(tsv, separator = "\t", infer_schema_length = 10000)
    new_column_name = '_'.join(sample_name) + '_fp_score'
    df = df.rename({df.columns[-1]: new_column_name})
    # print a few dfs
    if inner_counter < 5:
        print(df)
    
    # Add the DataFrame to the dictionary
    dataframes['_'.join(sample_name)] = df

print(f"Finished reading all TSV files for {motif}.")
print(f"Number of DataFrames in the motif dictionary: {len(dataframes)}")

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

# convert the polars DataFrame to pandas DataFrame
merged_df_pd = merged_df.to_pandas(use_pyarrow_extension_array=True)

# downcast the DataFrame
merged_df_pd = downcast_df(merged_df_pd)

# construct the output file name
output_file = f'{output_directory}/{motif}_tfbs_merged_matrix-full.parquet'

# convert the DataFrame to Parquet
merged_df_pd.to_parquet(output_file, engine='pyarrow', compression='lz4', index=False)
print(f"Data of merged motif no. {motif_counter} has been compressed into Parquet format.")

# end timer
end_time = time.time()
duration = end_time - start_time
minutes, seconds = divmod(duration, 60)
print(f"Total time taken to process motif {motif}: {minutes} minute(s) and {seconds} second(s).")



