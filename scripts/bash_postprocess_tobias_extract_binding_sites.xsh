#!/usr/bin/env xonsh

import os
import glob

filtered_root = $ARGS[1]

folders_list = []
sample_folder_sum = 0

for analysis_id in glob.glob(f"{filtered_root}/*"):
    if os.path.isdir(analysis_id):
        folders_list.append(analysis_id)

        print(f"Current analysis directory: {analysis_id}")
        sample_dirs = [sample_dir for sample_dir in glob.glob(f"{analysis_id}/*sample*") if os.path.isdir(sample_dir)]
        
        if not sample_dirs:
            print(f"Sample directory is non-existent in the {analysis_id} directory. Skipping...")
            continue
        else:
            print(f"Sample directories: {sample_dirs}")
            print(f"Sample directory count: {len(sample_dirs)}")
            sample_folder_sum += len(sample_dirs)

            for i, sample_dir in enumerate(sample_dirs):
                print(f"Sample directory {i+1}: {sample_dir}")
                sample_dir_name = os.path.basename(sample_dir)
                sample_id = sample_dir_name.split('_')[1]
                print(f"Analysis ID: {analysis_id}")
                print(f"Sample ID: {sample_id}")

                files = glob.glob(f"{sample_dir}/**/*_overview.txt", recursive=True)
                if not files:
                    print(f"Overview files are non-existent in the {sample_dir} directory. Skipping...")
                    continue
                else:
                    for file in files:
                        print(f"File: {file}")
                        motif_id = os.path.splitext(os.path.basename(file))[0]
                        print(f"Motif: {motif_id}")

                        motif_dir = f"/home/users/ntu/suffiazi/scratch/outputs/extracted-tobias-tfbs/{motif_id}"
                        if not os.path.exists(motif_dir):
                            print("Motif directory does not exist. Creating directory...")
                            print(f"os.makedirs({motif_dir})")

                        analysis_dir_name = os.path.basename(analysis_id)
                        new_file_name = f"{analysis_dir_name}_{sample_id}_{motif_id}_binding_sites.txt"
                        print(f"Analysis ID: {analysis_dir_name}")
                        print(f"Sample ID: {sample_id}")
                        print(f"New file name: {new_file_name}")

print("Extraction done!")
print(f"Total analysis directories processed: {len(folders_list)}")
print(f"Total sample subdirectories processed: {sample_folder_sum}")
