#!/usr/bin/env bash

# Check if the correct number of arguments were provided
if [[ "$#" -ne 2 ]]
then
  echo -e "Usage: $0 [--dry-run|--live-run] <analysis_id_list.txt>\n"
  exit 1
fi

RUNMODE="$1"
echo "Current run parameter: $RUNMODE"

ID_LIST="$2" #ensure that the input is the analysis_id_list.txt file
echo "Analysis ID list: $ID_LIST"

qsub -v RUN="$RUNMODE",ID="$ID_LIST" /home/users/ntu/suffiazi/scripts/footprinting-workflow-scripts/scripts/postprocess-rsync_filtered_output.pbs