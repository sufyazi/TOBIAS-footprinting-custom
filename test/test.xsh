#!/usr/bin/env xonsh

import os
import glob
import csv
import subprocess

file = "/scratch/users/ntu/suffiazi/outputs/filtered-tobias/PU24GB8/PU24GB8_sample1/overview_files/AHR_AHR_HUMAN.H11MO.0.B_overview.txt"
new_file_path = "/home/users/ntu/suffiazi/scripts/footprinting-workflow-scripts/test/extracted.txt"
try:
    with open(new_file_path, "w") as new_file:
        subprocess.run(["awk", "-F", "\t", "BEGIN {OFS=\"\t\"} {print $1, $2, $3, $6, $5, $10}", file], stdout=new_file, text=True)
except subprocess.CalledProcessError as e:
    print("An error occurred. Check logs.")
    print(e)
else:
    print("Extraction done!")