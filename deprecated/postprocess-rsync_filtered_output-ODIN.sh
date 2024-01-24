#!/usr/bin/env bash

if rsync -havPz "/home/msazizan/cargospace/tobias-bam-input/" suffiazi@aspire2antu.nscc.sg:/home/users/ntu/suffiazi/scratch/inputs/tobias-bam-input/; then
	echo "Datasets have been transferred to Aspire."
	echo "Input bam file collation, merging,and transfer to remote server have been completed."
else
	echo "Dataset transfer was interrupted."
fi
