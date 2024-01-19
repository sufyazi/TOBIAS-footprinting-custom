#!/usr/bin/env python3

import os
import sys
import glob
import time
import pandas as pd
from modules.utilities import downcast_df

# check arguments 
if len(sys.argv) != 2:
    print("Usage: convert_tsv_to_parquet.py <input_file_directory>")
    sys.exit(1)

# get arguments
input_directory = sys.argv[1]

# Loop through TSV files recursively in the subdirectory
tsv_files = glob.iglob(os.path.join(input_directory, '**', '*.txt'), recursive=True)

start_time = time.time()
count = 0
for tsv in tsv_files:
    count += 1
    print(f"[File no. {count}] Processing {tsv}...")
    filepath_noext, _ = os.path.splitext(tsv)
    
    # construct the output file name
    output_file = f'{filepath_noext}.parquet'
    print(f"Output file: {output_file}")

    # read the TSV file into a DataFrame
    df = pd.read_csv(tsv, sep = "\t")
    # print(f"DataFrame: {df}")

    # downcast the DataFrame
    df = downcast_df(df)

    # convert the DataFrame to Parquet
    df.to_parquet(output_file, engine='pyarrow', compression='lz4', index=False)
    print(f"File no. {count} compressed into parquet has been created.")

end_time = time.time()
print(f"Total time taken: {end_time - start_time} seconds.")
print("Done.")



