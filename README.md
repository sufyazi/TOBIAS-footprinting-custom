# Footprinting Workflow Scripts

This repository contains miscellaneous modular scripts that can be used to form workflows for footprinting analyses, both motif-guided (using TOBIAS) and *de novo* (using HINT-ATAC and STREME from MEME suite) on the NSCC computing cluster, Aspire in Singapore.

For running with TOBIAS in the motif-guided workflow, the combined filtered individual motifs in JASPAR format from several databases were compiled into one file using TOBIAS `FormatMotifs` tool.

```bash
TOBIAS FormatMotifs --input combined-filt-individual-motifs/* --task join --output ./joined_filt_combined_motifs.jaspar
```

## Motif-guided workflow using TOBIAS

1. Preprocessing of raw ATAC-seq data

    (a) run `preprocess-bam_input_transfer-ODIN.sh` to gather all the sample-specific bam files from each dataset in one place. Run this on Odin, where the raw bam outputs from the pipeline are stored. This script would merge technical replicate bams per sample (if they exist). This script would also create a corresponding index file for each bam file and then transfer them to NSCC server via `rsync` for further processing.

    (b) run `preprocess-collate_merge_peaks-ODIN.sh` to merge all the sample-specific raw peak files from all datasets into one file. This creates a consensus/master peakset for TOBIAS footprinting.

2. Motif-guided footprinting workflow

    (a) run `run-tobias_batch_footprinting_main.sh` script on the terminal to submit individual footprinting job with `run-tobias_batch_footprinting_main.pbs` to the scheduler.

3. Post-processing of raw footprint data from TOBIAS

    (a) run `postprocess-filter_tobias_output.sh` directly on the terminal to submit jobs (with the companion `.pbs` script) that filter the raw output directory to keep only the most important raw output files. This script will loop through the target tobias-out directory to grab only raw files we want to keep.

    (b) run `postprocess-extract_tobias_tfbs.xsh` to submit jobs (with the companion `.pbs` script) that would extract the TFBS scores of each TF motif from the raw output file of individual samples and gather them into one master directory per TF motif. This is a Xonsh script so make sure you run it on a Xonsh-aware interpreter.

    (c) run `postprocess-merge_tfbs_to_mastermtrx.py` to merge the TFBS scores from all samples into a big matrix per motif. The number of output files should match the number of motifs analysed.

    (d) run `postprocess-rsync_filtered_output-ODIN.sh` to transfer the TFBS score big matrices from Aspire to Odin for persistent storage.
    
    (e) run `postprocess-tsv_to_parquet.py` conversion on Odin using Polars to ease downstream analysis.
