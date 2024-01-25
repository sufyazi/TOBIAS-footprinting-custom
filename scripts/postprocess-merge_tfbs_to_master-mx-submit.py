#!/usr/bin/env python3

import os
import sys
import time
import subprocess
# arguments to supply: input_directory, output_directory, process_flag, path_to_dataset_ID_list_file (optional when process_flag is set to "all")

try:
    process_flag = sys.argv[3]
except IndexError:
    print("ERROR: Missing second argument <process_flag>.")
    print("Usage: postprocess-merge_tfbs_to_master-mx.py <input_directory> <output_directory> <process_flag [`all` | `subset`]> [<path_to_ID_list_file>; set only if 'subset' is set as `process_flag`]")
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
        print("Usage: postprocess-merge_tfbs_to_master-mx.py <input_directory> <output_directory> <process_flag [`all` | `subset`]> [<path_to_ID_list_file>; set only if 'subset' is set as `process_flag`]")
        sys.exit(1)
    else:
        # check third argument if process_flag is set to "subset"
        if process_flag == "subset":
            try:
                id_list_file = sys.argv[4]
                print(f"ID list filepath: {id_list_file}")
            except IndexError:
                print("ERROR: Missing third argument <path_to_ID_file> as <process_flag> is set to `subset`")
                print("Usage: postprocess-merge_tfbs_to_master-mx.py <input_directory> <output_directory> <process_flag [`all` | `subset`]> [<path_to_ID_list_file>; set only if 'subset' is set as `process_flag`]")
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


# Get a list of immediate subdirectories (one level deep)
motif_dir = [d for d in os.listdir(input_directory) if os.path.isdir(os.path.join(input_directory, d))]
print(f"Number of subdirectories: {len(motif_dir)}")

# Loop through the subdirectories
for counter, motif in enumerate(motif_dir, start=1):

    if counter == 20:
        print("Current job count has reached 20. Submission limiter will henceforth be applied to 10 jobs per 15 minutes.")
    
    # check if the current counter is a multiple of 10
    if counter > 20 and counter % 10 == 0:
        # check if the merged dataframe file exists
        if os.path.exists(f'{output_directory}/{motif}_tfbs_merged_matrix-full.parquet'):    
            print(f"File no. {counter} of {motif} TFBS merged matrix already exists. Skipping {motif}...")
            continue
        else:
            print("Counter is at the limiter mark. Sleeping for 15 minutes...")
            time.sleep(900)
            print("15 minutes have passed. Resuming submission...")
    
    # submit job to cluster
    # check if the merged dataframe file exists
    if os.path.exists(f'{output_directory}/{motif}_tfbs_merged_matrix-full.parquet'):    
        print(f"File no. {counter} of {motif} TFBS merged matrix already exists. Skipping {motif}...")
        continue
    else:
        print(f"File of {motif} TFBS merged matrix does not exist. Proceeding...")
        print(f"Processing {motif}...")
        if id_list_file:
            # submit job to cluster
            command = f"qsub -v INP_DIR={input_directory},OUT_DIR={output_directory},FLAG={process_flag},MOT={motif},MOT_CNT={counter},MOT_LIST={id_list_file} /home/users/ntu/suffiazi/scripts/footprinting-workflow-scripts/scripts/postprocess-merge_tfbs_to_master-mx-submit.pbs"
            print(f"Command to submit: {command}")
            subprocess.run(command, shell=True, check=True)
            print(f"Submitted job for motif {motif} [no. {counter}].")
        else:
            # submit job to cluster
            command = f"qsub -v INP_DIR={input_directory},OUT_DIR={output_directory},FLAG={process_flag},MOT={motif},MOT_CNT={counter} /home/users/ntu/suffiazi/scripts/footprinting-workflow-scripts/scripts/postprocess-merge_tfbs_to_master-mx-submit.pbs"
            print(f"Command to submit: {command}")
            subprocess.run(command, shell=True, check=True)
            print(f"Submitted job for motif {motif} [no. {counter}].")

print("All jobs submitted. Exiting submission script...")
    





