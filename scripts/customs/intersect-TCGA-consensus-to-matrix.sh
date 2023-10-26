#!/usr/bin/env bash
# shellcheck disable=SC1091

if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <tfbs_raw_matrix_dir> <consensus_peak_filepath> <output_dir>"
    exit 1
fi

set -e
# load conda environment
eval "$(conda shell.bash hook)"
conda activate bioinf

# assign arguments
TFBS_MATRIX_DIR=$1
CONSENSUS_FILE=$2
OUTDIR=$3


count=0

echo "Starting the filtering script using consensus peak file: $CONSENSUS_FILE"

for file in "$TFBS_MATRIX_DIR"/*.txt; do
    # increment count
    count=$((count + 1))
    motif_id=$(basename "$file" _tfbs_merged_matrix-brca.txt)
    echo "Processing $motif_id matrix...[FILE NO. $count]"

    # construct output file prefix
    output="${OUTDIR}/${motif_id}_BRCA-subtype-filtered-matrix"

    # check if output file already exists
    if [[ -f "${output}-stranded.txt" ]]; then
        echo "Output filtered matrix file for $motif_id already exists. Skipping..."
        continue
    else
        echo "Output matrix for $motif_id not found. Proceeding with filtering..."
        echo "Matrix file: $file"

        # run bedtools intersect to find the TFBSs of the motif that overlap with the consensus peaks
        if tail -n +2 "${file}" | cut -f 1-4 | sort -k1,1V -k2,2n | bedtools intersect -a - -b "${CONSENSUS_FILE}" -u -sorted -wa > "${output}-stranded.txt"; then
            echo "Successfully intersected $file with consensus peaks to create a filtered matrix."
        else
            echo "Failed to intersect $file with masking bed file. Check logs."
            exit 1
        fi
    fi
done
