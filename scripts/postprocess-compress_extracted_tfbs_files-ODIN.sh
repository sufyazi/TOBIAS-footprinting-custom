#!/usr/bin/env bash

######## RUN ON ODIN ########

# check if argument is provided
if [ $# -ne 2 ]; then
	echo "No arguments provided. Please provide the path to the upper level directory path where MOTIF DIRS are located (the lz4 command when used with -r flag will recurse into each subdirectory and compress all files in each subdirectory) as the first argument, and the mode (compress or validate) as the second argument."	
	exit 1
fi

INP_DIRPATH=$1 #this needs to be the upper level directory path where MOTIF DIRS are located (the lz4 command when used with -r flag will recurse into each subdirectory and compress all files in each subdirectory)

MODE=$2

# print the datasets
echo "Input directory path: ${INP_DIRPATH}"
echo "Mode: ${MODE}"

# check if the input directory path exists
if [ ! -d "${INP_DIRPATH}" ]; then
	echo "The input directory path does not exist."
	exit 1
fi

# find the subdirectories of the input directory path and print them
readarray -t MOTIF_DIRS < <(find "${INP_DIRPATH}" -mindepth 1 -type d -printf '%f\n')
# echo "Motif directories: ${MOTIF_DIRS[@]}"
echo "Number of motif directories: ${#MOTIF_DIRS[@]}"

if [ $MODE == "compress" ]; then
	counter=0
	# check if there are already compressed files in the subdirectories of the input directory path
	for MOTIF_DIR in "${MOTIF_DIRS[@]}"; do
		((counter++))
		echo $MOTIF_DIR "[motif directory number: $counter]"
		COMP_FILES=$(find "${INP_DIRPATH}/${MOTIF_DIR}" -mindepth 1 -type f -name "*.lz4" | wc -l)
		echo "Number of compressed files in ${MOTIF_DIR}: ${COMP_FILES}"
		if [ $COMP_FILES -eq 654 ]; then
			echo "There are already 654 compressed files in ${MOTIF_DIR}."
			echo "Skipping compression of files in ${MOTIF_DIR}."
		elif [ $COMP_FILES -eq 0 ]; then
			echo "There are no compressed files in ${MOTIF_DIR}."
			echo "Executing batch compression using lz4 for all files in ${MOTIF_DIR}."
			if lz4 -mrv -9 "${INP_DIRPATH}/${MOTIF_DIR}"; then
				echo "Compression of all files in all subdirectories of ${INP_DIRPATH} successful."
			else
				echo "Compression of all files in all subdirectories of ${INP_DIRPATH} failed."
			fi
		# if the number of compression files are more than 0 but less than 654
		elif [ $COMP_FILES -gt 0 ] && [ $COMP_FILES -lt 654 ]; then
			echo "The compression of files in ${MOTIF_DIR} are partially complete."
			echo "Looping through each file in ${MOTIF_DIR} to check if it is compressed."
			for FILE in $(find "${INP_DIRPATH}/${MOTIF_DIR}" -mindepth 1 -type f -name "*.txt"); do
				# check if FILE is empty
				if [ -z "${FILE}" ]; then
					echo "No .txt files found in ${MOTIF_DIR}. Aborting script..."
					exit 1
				fi
				# check if there is a compressed file with the same name as the file
				if [ -f "${FILE}.lz4" ]; then
					echo "$(basename "${FILE}") has been compressed."
					# check if the compressed file is valid
					echo "Validating the compressed file ${FILE}.lz4..." 
					if lz4 -t "${FILE}.lz4"; then
						echo "Validation of $(basename "${FILE}").lz4 successful."
					else
						echo "Validation of $(basename "${FILE}").lz4 failed."
					fi
				else
					# compress the file
					echo "$(basename "${FILE}") has not been compressed."
					echo "Compressing using lz4..."
					if lz4 -v -9 "${FILE}"; then
						echo "Compression of ${FILE} successful."
					else
						echo "Compression of ${FILE} failed."
					fi
				fi
			done
		fi
	done
	echo "Compression of all files in all subdirectories of ${INP_DIRPATH} complete."
elif [ $MODE == "validate" ]; then
	echo "Validating the compression of files in each subdirectory of ${INP_DIRPATH}."
	counter=0
	for MOTIF_DIR in "${MOTIF_DIRS[@]}"; do
		# increment counter
		((counter++))
		echo $MOTIF_DIR "[motif directory number: $counter]"
		echo "Validating the compressed files in ${MOTIF_DIR}..."
		for FILE in $(find "${INP_DIRPATH}/${MOTIF_DIR}" -mindepth 1 -type f -name "*.lz4"); do
			if lz4 -t "${FILE}"; then
				echo "Validation of $(basename "${FILE}") successful."
			else
				echo "Validation of $(basename "${FILE}") failed."
				exit 1
			fi
		done
	done
	echo "Validation of all compressed files complete."
else
	echo "Invalid mode. Please provide a valid mode (compress or validate)."
	exit 1
fi






