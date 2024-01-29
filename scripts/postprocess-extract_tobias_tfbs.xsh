#!/usr/bin/env xonsh

import os
import glob
import csv
import subprocess

# check whether argument is provided
if not $ARG1 or not $ARG2:
    print("Please provide the path to the filtered root directory and the path to the txt file containing list of dataset IDs to extract.")
    exit(1)

filtered_root = $ARG1
with open($ARG2, 'r') as f:
    id_list = f.read().splitlines()

sample_folder_count = 0

for analysis_id in id_list:
    analysis_path = os.path.join(filtered_root, analysis_id)
    if os.path.isdir(analysis_path):
        print(f"Current analysis directory: {analysis_path}")
        # find sample directories in the analysis directory
        sample_dirs = [sample_dir for sample_dir in glob.glob(f"{analysis_path}/*sample*") if os.path.isdir(sample_dir)]
        if not sample_dirs:
            print(f"Sample directory is non-existent in the {analysis_id} directory. Skipping...")
            continue
        else:
            print(f"Sample directories: {sample_dirs}")
            print(f"Sample directory total: {len(sample_dirs)}")
            for i, sample_dir in enumerate(sample_dirs):
                sample_folder_count += 1
                print(f"Sample directory {i+1}: {sample_dir}")
                sample_dir_name = os.path.basename(sample_dir)
                sample_id = sample_dir_name.split('_')[1]
                print(f"Analysis & sample ID: {analysis_id}_{sample_id}")
                if sample_folder_count % 70 == 0:
                    echo "Sleeping for 50 minutes..."
                    sleep 50m
                    # run bash script to extract binding sites
                    subprocess.run(f"qsub -v SAMPLEDIR={sample_dir} /home/users/ntu/suffiazi/scripts/footprinting-workflow-scripts/scripts/postprocess-extract_tobias_tfbs.pbs", shell=True, check=True)
                    print(f"Current sample directory count: {sample_folder_count}")
                else:
                    # run bash script to extract binding sites
                    subprocess.run(f"qsub -v SAMPLEDIR={sample_dir} /home/users/ntu/suffiazi/scripts/footprinting-workflow-scripts/scripts/postprocess-extract_tobias_tfbs.pbs", shell=True, check=True)
                    print(f"Current sample directory count: {sample_folder_count}")   
    else:
        print(f"Analysis directory {analysis_id} does not exist. Skipping...")
        continue
print("----------------------------------------\n")
print(f"Total analysis directories processed: {len(id_list)}")
print(f"Total sample subdirectories submitted for processing: {sample_folder_count}")
print("This script has finished running. Check output files and logs for errors.")