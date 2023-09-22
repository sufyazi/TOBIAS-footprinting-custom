#!/usr/bin/env python3
import os
import polars as pl

# Define the target directory containing the Parquet files
target_directory = '/data/bank/booth/msazizan/tobias-analysis-outputs/parquet-tfbs-matrices-tcga-brca'

# Create an output directory for BED files
output_directory = '/data/bank/booth/msazizan/tobias-analysis-outputs/tobias-tfbs-subset-matrices-datashop/reco/v0/prod/brca_tfbs_bedfiles'
os.makedirs(output_directory, exist_ok=True)

# List all files in the target directory
file_list = os.listdir(target_directory)

count = 0

# Iterate over each file in the target directory
for file_name in file_list:
    # Check if the file is a Parquet file
    if file_name.endswith('.parquet'):
        # Build the full file path
        file_path = os.path.join(target_directory, file_name)

        # Read the Parquet file into an Arrow table
        arrow_table = pl.read_parquet(file_path)

        # Select the first four columns
        selected_columns = arrow_table.select(["TFBS_chr", "TFBS_start", "TFBS_end", "TFBS_strand"])

        # Define the output BED file path
        bed_file_path = os.path.join(output_directory, file_name.replace('.parquet', '.bed'))

        # Save the selected columns as a tab-delimited BED file
        selected_columns.write_csv(bed_file_path, separator='\t', has_header=False)

        print(f"Processed {file_name} and saved as {bed_file_path}")


