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
file_count = 0

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
                # find overview files in the sample directory
                files = glob.glob(f"{sample_dir}/**/*_overview.txt", recursive=True)
                if not files:
                    print(f"Overview files are non-existent in the {sample_dir} directory. Skipping...")
                    continue
                else:
                    for file in files:
                        file_count += 1
                        print(f"File: {file}. [File no: {file_count}]]")
                        # extract motif_id from file name
                        motif_id = os.path.splitext(os.path.basename(file))[0].replace("_overview", "")
                        print(f"Motif: {motif_id}")
                        # create motif directory in the target directory
                        motif_dir = f"/home/users/ntu/suffiazi/scratch/outputs/extracted-tobias-tfbs/{motif_id}"
                        if not os.path.exists(motif_dir):
                            print("Motif directory does not exist. Creating directory...")
                            os.makedirs(motif_dir)
                        # create new file name
                        new_file_name = f"{analysis_id}_{sample_id}_{motif_id}_binding-sites.txt"
                        new_file_path = os.path.join(motif_dir, new_file_name)
                        # check if the output file already exists
                        if os.path.exists(new_file_path):
                            print(f"Output file {new_file_name} already exists. Skipping...")
                            continue
                        else:
                            print("Output file does not exist. Proceeding with extraction...")
                            print(f"Output file: {new_file_path}")
                        
                            # Start the extraction process
                            echo "Extracting binding sites..."
                            # Use subprocess to run AWK to process the file and extract selected columns
                            try:
                                with open(new_file_path, "w") as outfile:
                                    subprocess.run(["awk", "-F", "\t", "BEGIN {OFS=\"\t\"} {print $1, $2, $3, $6, $5, $10}", file], stdout=outfile, text=True)
                            except subprocess.CalledProcessError as e:
                                print("An error occurred. Check logs.")
                                print(e)
                                break
                            else:
                                print("Extraction done!")
    else:
        print(f"Analysis directory {analysis_id} does not exist. Skipping...")
        continue
print("----------------------------------------\n")
print(f"Total analysis directories processed: {len(id_list)}")
print(f"Total sample subdirectories processed: {sample_folder_count}")
print(f"Total files processed: {file_count}")
print("This script has finished running. Check output files and logs for errors.")