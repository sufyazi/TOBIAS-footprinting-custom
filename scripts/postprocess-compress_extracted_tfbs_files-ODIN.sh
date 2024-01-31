#!/usr/bin/env bash

######## RUN ON ODIN ########

# check if argument is provided
if [ $# -ne 1 ]; then
	echo "No arguments provided. Please provide the path to the croo_root folder, input_peak folder to gather narrowPeak files to, merged_peak folder to save bed files to, output folder to save master_merged bed file to, and the path to the dataset list text file."	
	exit 1
fi

INP_DIRPATH=$1 #this needs to be the upper level directory path where MOTIF DIRS are located (the lz4 command when used with -r flag will recurse into each subdirectory and compress all files in each subdirectory)

# print the datasets
echo "Input directory path: ${INP_DIRPATH}"

# find the subdirectories of the input directory path and print them
readarray -t MOTIF_DIRS < <(find "${INP_DIRPATH}" -mindepth 1 -type d -printf '%f\n')
# echo "Motif directories: ${MOTIF_DIRS[@]}"
echo "Number of motif directories: ${#MOTIF_DIRS[@]}"

if find "${INP_DIRPATH}" -mindepth 1 -type d | xargs lz4 -mrv -9;
then
	echo "Compression of all files in all subdirectories of ${INP_DIRPATH} successful."
else
	echo "Compression of all files in all subdirectories of ${INP_DIRPATH} failed."
fi


