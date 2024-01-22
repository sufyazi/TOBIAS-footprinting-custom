#!/usr/bin/env python3

import os
import sys
import glob
# import polars as pl

# arguments to supply: input_directory, output_directory, process_flag, path_to_dataset_ID_list_file (optional when process_flag is set to "all")

try:
    process_flag = sys.argv[3]
except IndexError:
    print("ERROR: Missing second argument <process_flag>.")
    print("Usage: merge-tobias-tfbs-matrix-v2.py <parent_directory> <process_flag [`all` | `subset`]> [<path_to_ID_list_file>; set only if 'subset' is set to `process_flag`]")
    sys.exit(1)
else:
    # check the validity of input directory path
    if not os.path.exists(sys.argv[1]):
        print(f"ERROR: Input directory {sys.argv[1]} does not exist.")
        sys.exit(1)
    input_directory = sys.argv[1]
    print(f"Input root directory: {input_directory}")
    
    # check the validity of output directory path
    if not os.path.exists(sys.argv[2]):
        print(f"ERROR: Output directory {sys.argv[2]} does not exist.")
        sys.exit(1)
    output_directory = sys.argv[2]
    print(f"Output directory: {output_directory}")
    
    # check the validity of process_flag
    if process_flag not in ["all", "subset"]:
        print("ERROR: Invalid second argument <process_flag>.")
        print("Usage: merge-tobias-tfbs-matrix-v2.py <parent_directory> <process_flag [`all` | `subset`]> [<path_to_ID_list_file [optional when `all` is set]>]")
        sys.exit(1)
    else:
        # check third argument if process_flag is set to "subset"
        if process_flag == "subset":
            try:
                id_list_file = sys.argv[4]
                print(f"ID list filepath: {id_list_file}")
            except IndexError:
                print("ERROR: Missing third argument <path_to_ID_file> as <process_flag> is set to `subset`.")
                print("Usage: merge-tobias-tfbs-matrix-v2.py <parent_directory> <process_flag [`all` | `subset`]> <path_to_ID_file [optional when `all` is set]>")
                sys.exit(1)
        else:
            id_list_file = None
        
        # check if the ID list file exists
        if id_list_file:
            if not os.path.exists(id_list_file):
                print(f"File {id_list_file} does not exist.")
                sys.exit(1)
            
            # Read the ID list file into a list
            with open(id_list_file, 'r') as f:
                id_list = f.read().splitlines()
            print(f"ID list: {id_list}")
            print(f"Number of IDs: {len(id_list)}")
            
        # Print message that the checks are complete
        print("Parameter checks complete. Proceeding...")
        

        # elif process_flag == "all":
        #     try:
        #         id_list_file = sys.argv[3]
        #     except IndexError:
        #         print("INFO: No third argument <path_to_ID_file> supplied as <process_flag> is set to `all`.")
        #         print("INFO: All TSV files in the subdirectories will be processed.")
        #         id_list_file = None
        #     else:
        #         if not os.path.exists(id_list_file):
        #             print(f"File {id_list_file} does not exist.")
        #             sys.exit(1)
        #         # Print message that the checks are complete
        #         print("Parameter checks complete. Proceeding...")


# Get a list of immediate subdirectories (one level deep)
motif_dir = [d for d in os.listdir(input_directory) if os.path.isdir(os.path.join(input_directory, d))]
print(f"Number of subdirectories: {len(motif_dir)}")

# Start counter
counter = 0
# Loop through the subdirectories
for motif in motif_dir:
    # Increment counter
    counter += 1
    # check if the merged dataframe file exists
    if os.path.exists(f'{output_directory}/{motif}_tfbs_merged_matrix.txt'):    
        print(f"File of {motif} TFBS merged matrix already exists. Skipping {motif}...")
        continue
    else:
        print(f"File of {motif} TFBS merged matrix does not exist. Proceeding...")
        # Create an empty dict to store DataFrames
        dataframes = {}
        # Construct the path to the subdirectory
        motif_dirpath = os.path.join(input_directory, motif)
        # print(f"Motif directory path: {motif_dirpath}")
        print(f"Directory name [no. {counter}]: {motif}")

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
                numeric_part = '0' + numeric_part
            # Replace the numeric part with the two-digit version and add 'sample' prefix
            sample_name[1] = 'sample' + numeric_part
            print(f"New sample ID: {sample_name}")
            
            # # Read TSV file into a DataFrame, rename the last column, and append to the dictionary
            # df = pl.read_csv(tsv, separator = "\t", infer_schema_length = 10000)
            # new_column_name = '_'.join(sample_name) + '_fp_score'
            # df = df.rename({df.columns[-1]: new_column_name})
            # dataframes['_'.join(sample_name)] = df
        
        # # Sort the dataframes dictionary by keys (after 3.7 dictionaries can be sorted)
        # sorted_dataframes = {k: dataframes[k] for k in sorted(dataframes.keys())}

        # # Merge all DataFrames in the list while preserving common columns
        # if sorted_dataframes:
        #     # Convert the dictionary to a list of DataFrames
        #     sorted_dataframes_list = list(sorted_dataframes.values())
        
        #     # Start with the first DataFrame in the list
        #     merged_df = sorted_dataframes_list[0]

        #     # Merge with all other Dataframes in the list 
        #     for df in sorted_dataframes_list[1:]:
        #         merged_df = merged_df.join(df, on=['TFBS_chr', 'TFBS_start', 'TFBS_end', 'TFBS_strand', 'TFBS_score'])
    
        # print(merged_df)
    
        # Write the merged DataFrame to a file
        # print(f"Writing merged dataframe to file: {motif}_tfbs_merged_matrix-brca.txt")
        # merged_df.write_csv(f'/home/msazizan/cargospace/tobias-analysis-outputs/tobias-tfbs-matrices-tcga/{motif}_tfbs_merged_matrix-brca.txt', separator ='\t')



