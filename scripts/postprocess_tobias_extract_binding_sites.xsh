#!/usr/bin/env xonsh

import os
import glob
import csv

# check whether argument is provided
if not $ARG1:
    print("Please provide the path to the filtered root directory.")
    exit(1)

filtered_root = $ARG1

folders_list = []
sample_folder_count = 0

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
            print(f"Sample directory total: {len(sample_dirs)}")

            for i, sample_dir in enumerate(sample_dirs):
                # check sample_folder_sum modulo to prevent overloading
                sample_folder_count += 1
                if sample_folder_count % 50 == 0:
                    print(f"Total sample subdirectories processed: {sample_folder_count}")
                    print(f"Current sample directory: {sample_dir}")
                    
                    print("Sleeping for 30 minutes...")
                    print("")
                    # sleep for 15 minutes
                    sleep 15m

                # continue with the rest of the script
                print(f"Sample directory {i+1}: {sample_dir}")
                sample_dir_name = os.path.basename(sample_dir)
                sample_id = sample_dir_name.split('_')[1]
                print(f"Analysis ID: {analysis_id}")
                print(f"Sample ID: {sample_id}")
                # find overview files in the sample directory
                files = glob.glob(f"{sample_dir}/**/*_overview.txt", recursive=True)
                if not files:
                    print(f"Overview files are non-existent in the {sample_dir} directory. Skipping...")
                    continue
                else:
                    for file in files:
                        print(f"File: {file}")
                        # extract motif_id from file name
                        motif_id = os.path.splitext(os.path.basename(file))[0].replace("_overview", "")
                        print(f"Motif: {motif_id}")
                        # create motif directory in the target directory
                        motif_dir = f"/home/users/ntu/suffiazi/scratch/outputs/extracted-tobias-tfbs/{motif_id}"
                        if not os.path.exists(motif_dir):
                            print("Motif directory does not exist. Creating directory...")
                            os.makedirs(motif_dir)
                        analysis_dir_name = os.path.basename(analysis_id)
                        new_file_name = f"{analysis_dir_name}_{sample_id}_{motif_id}_binding-sites.txt"
                        new_file_dir = os.path.join(motif_dir, new_file_name)

                        # check if the output file already exists
                        if os.path.exists(new_file_dir):
                            print(f"Output file {new_file_name} already exists. Skipping...")
                            continue
                        else:
                            print("Output file does not exist. Proceeding with extraction...")
                            print(f"Analysis & sample ID: {analysis_dir_name}_{sample_id}")
                            print(f"Output file: {new_file_dir}")

                            # run bash script to extract binding sites
                            subprocess.run(f"qsub -v FILE_INP={file},FILE_OUT={new_file_dir} /home/msazizan/hyperspace/footprinting-workflow-scripts/scripts/postprocess_tobias_extract_main.sh", shell=True, check=True)
                
                            # try:
                            #     # start the extraction process
                            #     print("Extracting binding sites...")
                            #     # use Python's csv module to extract the binding sites
                            #     with open(file, 'r') as infile, open(new_file_dir, 'w', newline='') as outfile:
                            #         reader = csv.reader(infile, delimiter='\t')
                            #         writer = csv.writer(outfile, delimiter='\t')
                            #         # no need to use next(header) if the header is required in the output
                            #         for row in reader:
                            #             # Process the row as needed, e.g., select specific columns
                            #             writer.writerow([row[0], row[1], row[2], row[5], row[4], row[9]])
                            #     print("Extraction done!")
                            #     print("")
                            # except Exception as e:
                            #     print(f"An error occurred. Check logs. Error: {e}")
                            #     print("")
                            #     continue
                            # finally:
                            #     print("Anyways, moving on to the next file...")
                            #     print("")

print("This script has finished running. Check output files and logs for errors.")
print(f"Total analysis directories processed: {len(folders_list)}")
print(f"Total sample subdirectories processed: {sample_folder_count}")
