# Footprinting Workflow Scripts

This repository contains miscellaneous modular scripts that can be used to form workflows for footprinting analyses, both motif-guided (using TOBIAS) and *de novo* (using HINT-ATAC and STREME from MEME suite) on the HPC cluster, Gekko in NTU, Singapore.

For running with TOBIAS in the motif-guided workflow, the combined filtered individual motifs in JASPAR format from several databases were compiled into one file using TOBIAS `FormatMotifs` tool.

```bash
TOBIAS FormatMotifs --input combined-filt-individual-motifs/* --task join --output ./joined_filt_combined_motifs.jaspar
```

1. Preprocessing of raw ATAC-seq data
    (a) run `gather_peak_files_per-dataset_tobias_v2` to gather all the raw peak files from each dataset in one place. Run this on Odin, where the raw outputs from the pipeline are stored.
    (b) run `merge_peak_files_per-dataset_tobias_v2` to merge all the sample-specific raw peak files from each dataset into one file. Run this on Odin, where the raw outputs from step (a) are stored.
    (c) run `merge_peak_files_all_tobias_v2` to merge all the sample-specific raw peak files from all datasets into one file. Run this on Odin, where the raw outputs from step (b) are stored. For now, we have a merged master set from BLUEPRINT.
    (d) run `gather_bam_files_per-dataset_tobias_v3` to gather all the raw bam files from each dataset in one place. Run this on Odin, where the raw outputs from the pipeline are stored.
    (e) run `bam_merge_rep_files_v2` to merge all the replicated bam files if there are replicates. Additionally, a corresponding merged bigwig file is generated. Run this on Odin, where the outputs from step (d) are stored.