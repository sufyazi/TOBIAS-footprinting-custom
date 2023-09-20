#!/usr/bin/env bash

tobias_out_root=$1
run_list=$2

# grab the run listed in the run list text file and put it in an array
readarray -t runs < "${run_list}"

# loop through the array for each run directory in the tobias_out_root 
for run in "${runs[@]}"; do
    echo "Current run directory: ${run}"
    # get the path of the sample directory in the run directory
    readarray -t sample_dir < <(find "${tobias_out_root}/${run}" -maxdepth 1 -mindepth 1 -type d -name "*sample*")

    # check if the sample directory is empty; if it is empty, skip
    if [ -z "${sample_dir[0]}" ]; then
        echo "Sample directory is non-existent in the ${run} directory. Skipping..."
        continue
    else
        # check elements in the array
        # print the first element
        echo "Sample directory count: " "${#sample_dir[@]}"
        for ((i=0; i<${#sample_dir[@]}; i++)); do
            echo "Sample directory $((i+1)): " "${sample_dir[i]}"
            # get the basename of the sample directory
            sample_dir_name=$(basename "${sample_dir[i]}")
            # get the analysis ID from the basename
            analysis_id=$(echo "${sample_dir_name}" | cut -d'_' -f1)
            # get the sample ID from the basename
            sample_id=$(echo "${sample_dir_name}" | cut -d'_' -f2)
            echo "Analysis ID: ${analysis_id}" "Sample ID: ${sample_id}"
            # create copy directory
            mkdir -p /home/users/ntu/suffiazi/scratch/outputs/filtered-tobias/"${analysis_id}"/"${analysis_id}"_"${sample_id}"/
            # find specific files in the sample directory and put them in an array
            # submit the job to the cluster
            echo "Submitting job to the cluster..."
            qsub -v SAMP_DIR="${sample_dir[i]}",ANAL_ID="${analysis_id}",SAMP_ID="${sample_id}" /home/users/ntu/suffiazi/scripts/footprinting-workflow-scripts/scripts/postprocess-filter_tobias_output.pbs
        done
    fi
done

echo "All jobs submitted."