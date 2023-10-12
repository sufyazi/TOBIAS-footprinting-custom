#!/usr/bin/env xonsh

import subprocess
import pathlib
import csv
import os


# check whether argument is provided
if not $ARG1:
    print("Please provide the path to the bindetect output directory from the differential mode analysis")
    exit(1)

diff_bindetect_root = pathlib.Path($ARG1)

sample_folder_count = 0
file_count = 0

# find overview files in the sample directory
for matrix in diff_bindetect_root.rglob("*_overview.txt"):
    file_count += 1
    print(f"File: {matrix}. [File no: {file_count}]]")
    # extract motif_id from file name
    motif_id = os.path.splitext(os.path.basename(matrix))[0].replace("_overview", "")
    print(f"Motif: {motif_id}")
    # create motif directory in the target directory
    motif_dir = f"/scratch/users/ntu/suffiazi/outputs/extracted-tobias-tfbs-diffmode-BRCA/{motif_id}"
    if not os.path.exists(motif_dir):
        print("Motif directory does not exist. Creating directory...")
        os.makedirs(motif_dir)
    # create new file name
    new_file_name = f"{motif_id}_diffmode_TCGA-BRCA_fpscore_matrix.txt"
    new_file_path = os.path.join(motif_dir, new_file_name)
    # check if the output file already exists
    if os.path.exists(new_file_path):
        print(f"Output file {new_file_name} already exists. Skipping...")
        continue
    else:
        print("Output file does not exist. Proceeding with extraction...")
        print(f"Output file: {new_file_path}")          
        # Start the extraction process
        echo "Extracting TFBS matrix and dropping irrelevant columns..."
        # Use subprocess to run AWK to process the file and extract selected columns
        try:
            with open(new_file_path, "w") as outfile:
                subprocess.run(["awk", "-F", "\t", "BEGIN {OFS=\"\t\"} {print $1, $2, $3, $6, $5, $10, $11, $12, $13, $14}", matrix], stdout=outfile, text=True)
        except subprocess.CalledProcessError as e:
            print("An error occurred. Check logs.")
            print(e)
            break
        else:
            print("Extraction done!")

print("----------------------------------------\n")
print(f"Total files processed: {file_count}")
print("This script has finished running. Check output files and logs for errors.")