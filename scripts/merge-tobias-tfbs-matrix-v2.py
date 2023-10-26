#!/usr/bin/env python3

import os
import sys
import glob
import polars as pl

# arguments to supply: parent_directory, process_flag, path_to_ID_list_file (optional when process_flag is set to "all")

try:
    process_flag = sys.argv[2]
except IndexError:
    print("ERROR: Missing second argument <process_flag>.")
    print("Usage: merge-tobias-tfbs-matrix-v2.py <parent_directory> <process_flag [`all` | `subset`]> [<path_to_ID_list_file [optional when `all` is set]>]")
    sys.exit(1)
else:
    if process_flag not in ["all", "subset"]:
        print("ERROR: Invalid second argument <process_flag>.")
        print("Usage: merge-tobias-tfbs-matrix-v2.py <parent_directory> <process_flag [`all` | `subset`]> [<path_to_ID_list_file [optional when `all` is set]>]")
        sys.exit(1)
    else:
        # check the validity of parent directory path
        if not os.path.exists(sys.argv[1]):
            print(f"ERROR: Directory {sys.argv[1]} does not exist.")
            sys.exit(1)
        else:
            parent_directory = sys.argv[1]
            print(f"Target directory: {parent_directory}")
        # check third argument if process_flag is set to "subset"
        if process_flag == "subset":
            try:
                id_list_file = sys.argv[3]
            except IndexError:
                print("ERROR: Missing third argument <path_to_ID_file> as <process_flag> is set to `subset`.")
                print("Usage: merge-tobias-tfbs-matrix-v2.py <parent_directory> <process_flag [`all` | `subset`]> <path_to_ID_file [optional when `all` is set]>")
                sys.exit(1)
            else:
                if not os.path.exists(id_list_file):
                    print(f"File {id_list_file} does not exist.")
                    sys.exit(1)
                else:
                    # Read the ID list file into a list
                    with open(id_list_file, 'r') as f:
                        id_list = f.read().splitlines()
                        print(f"ID list: {id_list}")
                        

# Get a list of immediate subdirectories (one level deep)
subdirectories = [d for d in os.listdir(parent_directory) if os.path.isdir(os.path.join(parent_directory, d))]
print(f"Number of subdirectories: {len(subdirectories)}")

# Loop through the subdirectories
for subdir in subdirectories:
    
    # check if the merged dataframe file exists
    if os.path.exists(f'/home/msazizan/cargospace/tobias-analysis-outputs/tobias-tfbs-matrices-tcga/{subdir}_tfbs_merged_matrix-brca.txt'):    
        print(f"File {subdir}_tfbs_merged_matrix-brca.txt already exists. Skipping {subdir}...")
        continue
    else:
        print(f"File {subdir}_tfbs_merged_matrix-brca.txt does not exist. Proceeding...")
    
        # Create an empty dict to store DataFrames
        dataframes = {}
        # Construct the path to the subdirectory
        subdirectory_path = os.path.join(parent_directory, subdir)
        print(f"Subdirectory path: {subdirectory_path}")
        print(f"Directory name: {subdir}")
    
        # if process_flag is set to "subset", loop through the id_list
        if process_flag == "subset":
            # Construct an empty list to store TSV file lists from different IDs
            list_of_tsv_file_lists = []
            for ids in id_list:
                # Get a list of TSV files in the subdirectory
                tsv_file_list = glob.glob(os.path.join(subdirectory_path, f'{ids}*.txt'))
                # Append the list of TSV files to the list of TSV file lists
                list_of_tsv_file_lists.append(tsv_file_list)
            # Flatten the list of TSV file lists
            tsv_files = [item for sublist in list_of_tsv_file_lists for item in sublist]
            # print(f"TSV files: {tsv_files}")
            print(f"Number of TSV files: {len(tsv_files)}")
        elif process_flag == "all":
            # Loop through TSV files recursively in the subdirectory
            tsv_files = glob.iglob(os.path.join(subdirectory_path, '*.txt'))
            ### Note: glob.iglob() returns an iterator, which will be exhausted after the first iteration so make sure not to use it more than once
        
        # Loop through TSV files recursively in the subdirectory
        for tsv in tsv_files:
            # print(f"TSV file: {tsv}")
            # Extract the filename from the path and split by underscore, and get only the first 2 elements
            sample_name = os.path.basename(tsv).split('_')[:2]       
            # print(f"Sample name: {sample_name}")
            # Extract the numeric part from the sample name (assumes format 'sampleXX')
            numeric_part = sample_name[1][6:]
            # Ensure the numeric part is two digits by adding leading zero if needed
            if len(numeric_part) == 1:
                numeric_part = '0' + numeric_part
            # Replace the numeric part with the two-digit version and add 'sample' prefix
            sample_name[1] = 'sample' + numeric_part
            print(f"Sample name: {sample_name}")
            
            # Read TSV file into a DataFrame, rename the last column, and append to the dictionary
            df = pl.read_csv(tsv, separator = "\t", infer_schema_length = 10000)
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
    
        # Write the merged DataFrame to a file
        print(f"Writing merged dataframe to file: {subdir}_tfbs_merged_matrix-brca.txt")
        merged_df.write_csv(f'/home/msazizan/cargospace/tobias-analysis-outputs/tobias-tfbs-matrices-tcga/{subdir}_tfbs_merged_matrix-brca.txt', separator ='\t')



