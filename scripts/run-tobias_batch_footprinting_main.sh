#!/usr/bin/env bash

# Check for correct number of arguments
if [ "$#" -ne 4 ]; then
    echo "Usage: $0 <gathered_input_root> <dataset_record> <run_number> <run_type>"
    exit 1
fi

gathered_input_root=$1
dataset_rec=$2
run_num=$3
# set run type
run_type=$4

# Set cores
cores=64

# Set peak file path based on run type
if [ "$run_type" == "union" ]; then
    PEAK_PATH="/home/users/ntu/suffiazi/tobias_input_peaks/merged_sample-specific_peaks"
elif [ "$run_type" == "master" ]; then
    peakfile="/scratch/users/ntu/suffiazi/inputs/peak_files/master_merged_peakset/ALL_master_merged_peakset-v4.5.bed"
else
    echo "Invalid run type. Please specify either <union> or <master>."
    exit 1
fi

echo "Gathered input root: $gathered_input_root"
echo "Dataset record: $dataset_rec"
echo "Run number: $run_num"

# Declare an associative array to store the dataset and experiment type pairs
declare -A dataset_dict

# Read the dataset record file and populate the associative array
while read -r dataset experiment; do
    dataset_dict["$dataset"]="$experiment"
done < "$dataset_rec"

# Print the dataset and experiment type pairs
for dataset in "${!dataset_dict[@]}"; do
    # get the path of the dataset in the gathered_input_root
    dataset_path=$(find "${gathered_input_root}" -maxdepth 1 -mindepth 1 -type d -name "${dataset}")
	# check if the dataset path is empty; if it is empty, skip
	if [ -z "${dataset_path}" ]; then
        echo "Dataset ${dataset} does not exist in input path. Skipping..."
		continue
	fi
    # assign the experiment type to a variable
    experiment_type="${dataset_dict[$dataset]}"
    echo "Dataset: $dataset Experiment Type: $experiment_type"

    # iterate through each sample
	for sample_dir in "${dataset_path}"/*; do
		# check if the file is a directory; if it is NOT a directory, skip
		if [ ! -d "${sample_dir}" ]; then
			continue
		else
            # get the sample name
			sample_name=$(basename "${sample_dir}")
            echo "Sample name: $sample_name"

            # if the run type is union, then find the merged peak file (sample-specific)
            if [ "$run_type" == "union" ]; then
                peakfile=$(find "${PEAK_PATH}" -type f -name "${dataset}_${sample_name}_*.bed")
                if [ -z "${peakfile}" ]; then
                    echo "Merged peak file for ${dataset}_${sample_name} does not exist. Skipping..."
                    continue
                else
                    echo "Merged peak file: $peakfile"
                fi
            fi

            # find input files and assign to variables
            # find the bam file
            readarray -t bam_files < <(find "${sample_dir}" -type f \( -name "*.trim.srt.nodup.no_chrM_MT.bam" -o -name "*.nodup.no_chrM_MT.bam" -o -name "*.rep-merged.bam" \))
            # check if the length of the bam_files array is more than 1; if yes, then filter for the one named .rep-merged.bam
            if [[ "${#bam_files[@]}" -gt 1 ]]; then
                bam=$(find "${sample_dir}" -type f -name "*.rep-merged.bam")
            else
                bam="${bam_files[0]}"
            fi
            echo "Bam file: $bam"
            # create the output directory
            mkdir -p "/home/users/ntu/suffiazi/scratch/outputs/tobias-outs/RUN-${run_num}-${run_type}/${dataset}_${sample_name}"

            # run the script
            qsub -v ANALYSIS_ID="$dataset",SAMPLE="$sample_name",EXP_TYPE="$experiment_type",RUN="$run_num",CORE="$cores",PEAKS="$peakfile",FILE="$bam",TYPES="$run_type" /home/users/ntu/suffiazi/scripts/footprinting-workflow-scripts/scripts/run_tobias_batch_aspire_main-submit.pbs
        fi
    done
done