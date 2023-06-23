# Footprinting Workflow Scripts
This repository contains miscellaneous modular scripts that can be used to form workflows for footprinting analyses, both motif-guided (using TOBIAS) and *de novo* (using HINT-ATAC and STREME from MEME suite) on the HPC cluster, Gekko in NTU, Singapore. 

For running with TOBIAS in the motif-guided workflow, the combined filtered individual motifs in JASPAR format from several databases were compiled into one file using TOBIAS `FormatMotifs` tool.

```
TOBIAS FormatMotifs --input combined-filt-individual-motifs/* --task join --output ./joined_filt_combined_motifs.jaspar
```

