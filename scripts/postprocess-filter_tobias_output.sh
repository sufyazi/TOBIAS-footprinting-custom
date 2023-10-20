#!/usr/bin/env bash

tobias_out_root=$1
run_list=$2

# grab the run listed in the run list text file and put it in an array
readarray -t runs < "${run_list}"

# loop through the array for each run directory in the tobias_out_root 
for run in "${runs[@]}"; do
    echo "Current run directory: ${run}"
    # construct search path
    search_path="${tobias_out_root}/${run}"
    # get the path of the data directory in the run directory
    readarray -t data_dir < <(find "${search_path}" -maxdepth 1 -mindepth 1 -type d)

    # check if the data directory is empty; if it is empty, skip
    if [ -z "${data_dir[0]}" ]; then
        echo "Dataset directory is non-existent in the ${run} directory. Skipping..."
        continue
    else
        for dataset in "${data_dir[@]}"; do
            echo "Current dataset directory: ${dataset}"
            echo "Submitting job to the cluster..."
            qsub -v DATAPATH="${dataset}" /home/users/ntu/suffiazi/scripts/footprinting-workflow-scripts/scripts/postprocess-filter_tobias_output.pbs
        done
    fi
done

echo "All jobs submitted."
