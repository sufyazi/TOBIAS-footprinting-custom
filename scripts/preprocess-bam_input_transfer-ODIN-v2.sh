#!/usr/bin/env bash

#####################################----RUN THIS ON ODIN----###############################################
############################################################################################################

# BIGWIGS ARE NOT NEEDED FOR TOBIAS ANALYSIS
# for bams, we will use the dedup.bam files

# check if argument is provided
if [ $# -ne 2 ]; then
	echo "No arguments provided. Please provide the path to the croo_root folder and the path to the dataset list text file."	
	exit 1
fi

# set -e
# # load conda environment
# eval "$(conda shell.bash hook)"
# conda activate bioinf

croo_root=$1
dataset_list=$2

# grab the basename of all the datasets listed in the dataset list text file
readarray -t datasets < "${dataset_list}"

# print the datasets
echo '[' "${datasets[@]}" ']'

# iterate through each dataset
for dataset in "${datasets[@]}"; do
	# get the path of the dataset in the croo_root
    dataset_path=$(find "${croo_root}" -maxdepth 1 -mindepth 1 -type d -name "${dataset}")
	echo "Dataset path: ${dataset_path}"
	# check if the dataset path is empty; if it is empty, skip
	if [ -z "${dataset_path}" ]; then
		echo "Dataset path is non-existent. Skipping..."
		continue
	fi
    # iterate through each sample
	for sample_dir in "${dataset_path}"/*; do
		# check if the file is a directory; if it is NOT a directory, skip
		if [ ! -d "${sample_dir}" ]; then
			echo "${sample_dir} is not a directory. Skipping..."
			continue
		else
			# get the sample name
			sample_name=$(basename "${sample_dir}")

			# capture the sample number
			if [[ $sample_name =~ (sample[0-9]{1,3}) ]]; then
  				substring="${BASH_REMATCH[1]}"
  				echo "Current directory: ${substring} of ${dataset}"
			fi

			# make a directory for the raw bam files
			mkdir -p /home/msazizan/cargospace/tobias-bam-input/"${dataset}"/"${substring}"

			# check whether there are replicated files for each sample; in other words, if there are more than 1 bam file for each sample, then merge the bam files
			# initialize an array to store the bam files as best practice as readarray appends to an existing array
			bam_files=()
			# save the bam files to an array
			readarray -t bam_files < <(find "${dataset_path}/${sample_name}" -type f \( -name "*.trim.srt.nodup.no_chrM_MT.bam" -o -name "*.nodup.no_chrM_MT.bam" \))
			# check the bam file array for each sample
			echo "Bam files of ${sample_name}:"
			printf '%s\n' "${bam_files[@]}"
			echo "Total number of sample bam files: ${#bam_files[@]}"
			if [ "${#bam_files[@]}" -gt 1 ]; then
				echo "Multiple bam files have been found for ${sample_name}."
				# Check if there is a merged bam file already
				if [ -f "/home/msazizan/cargospace/tobias-bam-input/${dataset}/${substring}/${sample_name}.trim.srt.nodup.rep-merged.bam" ]; then
					echo "Merged bam file already exists. Checking if there is an index file..."
					if [ -f "/home/msazizan/cargospace/tobias-bam-input/${dataset}/${substring}/${sample_name}.trim.srt.nodup.rep-merged.bam.bai" ]; then
						echo "Index file already exists."
					else
						echo "Index file does not exist. Indexing..."
						if samtools index -@ 8 "/home/msazizan/cargospace/tobias-bam-input/${dataset}/${substring}/${sample_name}.trim.srt.nodup.rep-merged.bam" "/home/msazizan/cargospace/tobias-bam-input/${dataset}/${substring}/${sample_name}.trim.srt.nodup.rep-merged.bam.bai"; then
							echo "Merged bam file has been indexed."
						else
							echo "Index file has NOT been generated for ${sample_name}. One of the commands has failed."
							continue
						fi
					fi
				else
					echo "Merging the bam files..."
					# merge the bam files
					if samtools merge -@ 8 -o "/home/msazizan/cargospace/tobias-bam-input/${dataset}/${substring}/${sample_name}.trim.srt.nodup.rep-merged.bam" "${bam_files[@]}"; then
						echo "Replicated bam files have been merged. Checking if there is an index file..."
						if [ -f "/home/msazizan/cargospace/tobias-bam-input/${dataset}/${substring}/${sample_name}.trim.srt.nodup.rep-merged.bam.bai" ]; then
							echo "Index file already exists. Transferring to remote server..."
						else
							# index the merged bam file
							if samtools index -@ 8 "/home/msazizan/cargospace/tobias-bam-input/${dataset}/${substring}/${sample_name}.trim.srt.nodup.rep-merged.bam" "/home/msazizan/cargospace/tobias-bam-input/${dataset}/${substring}/${sample_name}.trim.srt.nodup.rep-merged.bam.bai"; then
								echo "Replicated sorted bam files have been merged and indexed."
							else
								echo "Index file has NOT been generated for ${sample_name}. One of the commands has failed."
								continue
							fi
						fi
					else
						echo "Replicated sorted bam files of ${sample_name} failed to be merged due to samtools error. Skipping..."
						continue
					fi
				fi
			else
				echo "There are no replicated sorted bam files for ${sample_name}. Copying the bam file..."
				# copy the bam files to created folder
				if rsync -avPhz "${bam_files[@]}" "/home/msazizan/cargospace/tobias-bam-input/${dataset}/${substring}/"; then
					# check if there is an index file
					if find "/home/msazizan/cargospace/tobias-bam-input/${dataset}/${substring}" -name "*.bam.bai" -print -quit | grep -q .; then
						echo "Index file already exists."
					else
						echo "Index file does not exist. Indexing..."
						# find bam file 
						bam_file=$(find "/home/msazizan/cargospace/tobias-bam-input/${dataset}/${substring}" -name "*.bam" -type f)
						# generate an index file
						if samtools index -@ 8 "$bam_file"; then
							echo "The index file has been generated."
						else
							echo "Index file has NOT been generated for ${sample_name}. One of the commands has failed."
							continue
						fi

					fi
				else
					echo "Replicated sorted bam files of ${sample_name} failed to be copied due to rsync error."
					continue
				fi
			fi
		fi
	done
done

# transfer the sample dir to remote server
# eval "$(ssh-agent -s)"
# ssh-add ~/.ssh/nscc_id_rsa
# if rsync -havPz "/home/msazizan/cargospace/tobias-bam-input/" suffiazi@aspire2antu.nscc.sg:/home/users/ntu/suffiazi/scratch/inputs/tobias-bam-input/; then
# 	echo "Datasets have been transferred to Aspire."
# 	echo "Input bam file collation, merging,and transfer to remote server have been completed."
# else
# 	echo "Dataset transfer was interrupted."
# fi


