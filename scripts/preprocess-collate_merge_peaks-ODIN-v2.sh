#!/usr/bin/env bash

######## RUN ON ODIN ########
############################################################################################################
# For TOBIAS, we need to merge individual peak files into a single peak file for each sample.

# The list of selected peak files per samples are:
# 1. bfilt.narrowPeak true rep
# 2. idr.conservative.narrowPeak true rep
# 3. idr.optimal.narrowPeak true rep
# 4. overlap.optimal.narrowPeak true rep
# 5. overlap.conservative.narrowPeak true rep

# let us gather the necessary files in one place first
# make sure that a copy of 'peak' folder for each sample of a dataset (use the flag --relative with rsync) has been transferred from the storage server to where this merging would be done.

# ensure that the structure in the peak_root folder below is as follows, with raw_peaks and merged_peaks as subfolders:
# peak_root
# ├── merged_peaks
# └── raw_peaks

# check if argument is provided
if [ $# -ne 5 ]; then
	echo "No arguments provided. Please provide the path to the croo_root folder, input_peak folder to gather narrowPeak files to, merged_peak folder to save bed files to, output folder to save master_merged bed file to, and the path to the dataset list text file."	
	exit 1
fi

croo_root=$1
input_peak_root=$2
merged_peak_root=$3
output_master_merged=$4
dataset_list=$5

# grab the basename of all the datasets listed in the dataset list text file
readarray -t datasets < "${dataset_list}"

# print the datasets
echo '[' "${datasets[@]}" ']'

# iterate through each dataset
for dataset in "${datasets[@]}"; do
	# get the path of the dataset in the croo_root
    dataset_path=$(find "${croo_root}" -maxdepth 1 -mindepth 1 -type d -name "${dataset}")
	# check if the dataset path is empty; if it is empty, skip
	if [ -z "${dataset_path}" ]; then
		continue
	fi
    # iterate through each sample
	for sample_dir in "${dataset_path}"/*; do
		# check if the file is a directory; if it is NOT a directory, skip
		if [ ! -d "${sample_dir}" ]; then
			continue
		else
			# print the current sample directory
            echo "Current sample directory: ${sample_dir}"
			# get the sample name
			sample_name=$(basename "${sample_dir}")
			# capture the sample number
			if [[ $sample_name =~ (sample[0-9]{1,3}) ]]; then
  				substring="${BASH_REMATCH[1]}"
  				echo "Substring: $substring of ${dataset}"
			fi
			# make a directory for the raw peaks
			mkdir -p "${input_peak_root}"/"${dataset}"/"${substring}"
            # initialize an array to store the peak files
			peak_files=()
			# find PEAK FILES for each dataset and transfer to the raw_peaks folder
			readarray -t peak_files < <(find "${dataset_path}/${sample_name}" -type f \( -name "idr.*_peak.narrowPeak.gz" -o -name "overlap.*_peak.narrowPeak.gz" \))
			# check the peak file array for each sample
			echo "Peak files of ${sample_name}:"
			printf '%s\n' "${peak_files[@]}"
			# copy the peak files to raw_peaks folder
			rsync -avhPz "${peak_files[@]}" "${input_peak_root}/${dataset}/${substring}/"

            # unzip the peak files
            if gunzip "${input_peak_root}/${dataset}/${substring}"/*.gz; then
                echo "Unzipped all peak files in ${input_peak_root}/${dataset}/${substring}"
            else
                echo "No peak files to unzip in ${input_peak_root}/${dataset}/${substring}"
            fi

			# create directory for merged peaks
			mkdir -p "${merged_peak_root}/${dataset}"

			# merge the peak files using bedtools
			ls "${input_peak_root}/${dataset}/${substring}"/
			if cat "${input_peak_root}/${dataset}/${substring}"/*.narrowPeak | sort -k1,1 -k2,2n | bedtools merge -i - > "${merged_peak_root}/${dataset}/${dataset}_${substring}_peaks_filtered.bed"; then
				echo "Merged all peak files in ${input_peak_root}/${dataset}/${substring}"
			else
				echo "Merge error occurred in ${input_peak_root}/${dataset}/${substring}. Please check."
			fi
		fi
	done

	# merge the filtered peaks for each dataset
	if cat "${merged_peak_root}/${dataset}"/*filtered.bed | sort -k1,1 -k2,2n | bedtools merge -i - > "${output_master_merged}/${dataset}_rep_merged_peakset.tmp"; then
		echo "Merged all filtered peaks for ${dataset}."
	else
		echo "Merge error occurred for ${dataset}. Please check."
	fi
done

# merge the tmp files into a master peakset file 
if cat "${output_master_merged}"/*rep_merged_peakset.tmp | sort -k1,1 -k2,2n | bedtools merge -i - > "${output_master_merged}/BRCA-master-peakset.bed"; then
	echo "Merged all tmp files into a master peakset file."
	# clean up the tmp files
	if find "${output_master_merged}" -name "*_rep_merged_peakset.tmp" -type f -delete; then
		echo "Cleaned up all tmp files."
		echo "Done!"
	else
		echo "Error occurred while cleaning up tmp files."
	fi
else
	echo "Merge error occurred for the tmp files. Please check."
fi
