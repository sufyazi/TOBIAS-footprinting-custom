#!/usr/bin/env bash

# Check if the correct number of arguments were provided
if [[ "$#" -ne 2 ]]
then
  echo -e "Usage: $0 [--dry-run|--live-run] <analysis_id_list.txt>\n"
  exit 1
fi

# Set the source directory to traverse
SOURCE_DIR="/home/users/ntu/suffiazi/scratch/outputs/extracted-tobias-tfbs"

# Check if the --dry-run option is provided
if [[ "$1" == "--dry-run" ]]
then
  RUN="$1"
  echo "Current run parameter: $RUN"
  echo -e "Running in dry mode\n"
else
  RUN="--live-run"
  echo "Current run parameter: $RUN"
  echo -e "Running in live mode\n"
fi

# Process the analysis_id_list.txt file
DATASET_LIST="$2" #ensure that the input is the analysis_id_list.txt file

# Initialize counters
COUNTER_DIR=0

cd "$SOURCE_DIR" || exit 1

for DIREC in ./*; do
    # Increment the counter
    ((COUNTER_DIR++))

    echo "Copying files from directory no. $COUNTER_DIR..."
    echo "Directory: $DIREC"

    # Find associated files
    # Loop through the id list
    while read -r ANALYSIS_ID; do
        echo "Analysis ID: $ANALYSIS_ID"
        echo "$DIREC"
        # Find associated files
        mapfile -t FILES < <(find "$DIREC" -name "$ANALYSIS_ID*.txt" -type f)

        # Check the found files
        echo "Found files:" "${FILES[@]}"
        echo "Number of files found: ${#FILES[@]}"
        echo ""

        # transfer
        echo "Transferring files..."
        if [[ "$RUN" == "--dry-run" ]]
        then
          rsync -haPvz --dry-run --relative "${FILES[@]}" "/home/users/ntu/suffiazi/scratch/outputs/extracted-tobias-tfbs-subset/"
        else
          rsync -haPvz --relative "${FILES[@]}" "/home/users/ntu/suffiazi/scratch/outputs/extracted-tobias-tfbs-subset/"
        fi

    done < "$DATASET_LIST"
done