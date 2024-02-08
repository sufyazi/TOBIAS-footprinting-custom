#!/usr/bin/env bash

TARGET_DIR=$1

if [ -z "$TARGET_DIR" ]; then
  echo "Usage: $0 <target-dir>"
  exit 1
fi

counter=0
for dir in "$TARGET_DIR"/*; do
	if [ -d "$dir" ]; then
		((counter++))
		num_files=$(find "$dir" -mindepth 1 -maxdepth 1 -type f | wc -l)
		# get basename of the directory
		base_dir=$(basename "$dir")
		echo "Number of files in $base_dir: $num_files [directory number: $counter]"

		if [ "$num_files" -eq 1308 ]; then
			echo "Completed archiving $base_dir"
			echo "Finding .txt files in $base_dir..."
			# find and delete all .txt files in the directory
			if find "$dir" -mindepth 1 -maxdepth 1 -type f -name "*.txt" -delete; then
				echo "Deleted all .txt files in $base_dir."
			else
				echo "Failed to delete .txt files in $base_dir. Check logs."
				exit 1
			fi
		else 
			if [ "$num_files" -eq 654 ]; then
				# check if there are any .txt files in the directory
				if [ -n "$(find "$dir" -mindepth 1 -maxdepth 1 -type f -name "*.txt")" ]; then
					echo "Archiving $base_dir has not been done yet. Skipping..."
				else
					echo "Completed archiving $base_dir and the original tsv files have been deleted. Skipping..."
				fi
			else
				echo "Archiving $base_dir is in progress. Skipping..."
			fi
		fi
	fi
done

