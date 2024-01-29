#!/usr/bin/env python3

import os
import sys
import pandas as pd
from modules.utilities import downcast_df

# check arguments 
if len(sys.argv) != 2:
    print("Usage: format-interconversion.py <input_file>")
    sys.exit(1)

# get arguments
inputfile = sys.argv[1]

# check if input file exists
if not os.path.isfile(inputfile):
    print("Input file does not exist.")
    sys.exit(1)

# check if input file is a tsv file
if not inputfile.endswith(".tsv"):
    if inputfile.endswith(".parquet"):
        print("Input file is a parquet file.")
        file_format = "parquet"
    else:
        print("Input file is not a tsv file nor a parquet file. Exiting...")
        sys.exit(1)
else:
    print("Input file is a tsv file.")
    file_format = "tsv"

# process input file
match file_format:
    case "tsv":
        # read tsv file
        print("Reading tsv file...")
        df = pd.read_csv(inputfile, sep="\t")
        # downcast dataframe
        print("Downcasting dataframe...")
        df = downcast_df(df)
        # get output file name
        outputfile = os.path.splitext(inputfile)[0] + ".parquet"
        # write parquet file
        print("Writing parquet file...")
        df.to_parquet(outputfile, engine='pyarrow', compression='lz4', index=False)
        print("Done.")
    case "parquet":
        print("Reading parquet file...")
        df = pd.read_parquet(inputfile, engine='pyarrow')
        # get output file name
        outputfile = os.path.splitext(inputfile)[0] + ".tsv"
        # write tsv file
        print("Writing tsv file...")
        df.to_csv(outputfile, sep="\t", index=False)
        print("Done.")



