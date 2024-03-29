#!/usr/bin/env bash
# shellcheck disable=SC2199

#### Run this script to submit the job to the cluster ####
#### This script is only used to merge the bam files of all samples under a specific dataset for a specific analysis ####

# check if the number of arguments is correct
if [ "$#" -ne 2 ]; then
	echo "Usage: bash bam_merge_rep_aspire-version <input_bam_root> <dataset_list>"
	exit 1
fi

gathered_bam_root=$1
dataset_list=$2

# grab the basename of all the datasets listed in the dataset list text file
readarray -t datasets < "${dataset_list}"

# print the datasets
echo '[' "${datasets[@]}" ']'

# iterate through each dataset
for dataset in "${datasets[@]}"; do
	
	# get the path of the dataset in the gathered_input_root
    dataset_path=$(find "${gathered_bam_root}" -maxdepth 1 -mindepth 1 -type d -name "${dataset}")
	echo "Dataset path: ${dataset_path}"
	# check if the dataset path is empty; if it is empty, skip
	if [ -z "${dataset_path}" ]; then
		echo "Dataset path is non-existent. Skipping..."
		continue
	fi

	# initialize an array to store the bam files
	bam_files=()

    # iterate through each sample
	for sample_dir in "${dataset_path}"/*; do
		# check if the file is a directory; if it is NOT a directory, skip
		if [ ! -d "${sample_dir}" ]; then
			echo "${sample_dir} is not a directory. Skipping..."
			continue
		else
			# get the sample name
			sample_name=$(basename "${sample_dir}")
			echo "Current directory: ${sample_name} of ${dataset}"

			# find the bam files and store the paths in an array
			readarray -t temp_arr < <(find "${sample_dir}" -type f \( -name "*.trim.srt.nodup.no_chrM_MT.bam" -o -name "*.nodup.no_chrM_MT.bam" -o -name "*srt.nodup.rep-merged.bam" \))

			# check the bam file array for each sample
			echo "Bam files of ${dataset}_${sample_name}:" "${temp_arr[@]}"
			echo "Appending the bam files to the dataset file array..."
			
			# add the bam files to the dataset bam_files array
			bam_files+=("${temp_arr[@]}")
			
		fi
	done

	echo "Total number of bam files for ${dataset}:" "${#bam_files[@]}"
	echo "Merging the bam files..."
	bam_files_str="${bam_files[*]}"
	qsub -v BAM="${bam_files_str}",DATA="${dataset}" -N "${dataset}"-bam-merge /home/users/ntu/suffiazi/scripts/footprinting-workflow-scripts/scripts/customs/preprocess-bam_merge_reps_aspire-diffmode.pbs
done			
echo "Queue submission completed."
