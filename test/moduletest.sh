#!/usr/bin/env bash
# shellcheck disable=SC1091
# shellcheck disable=SC2153
# This script is used to run the job on the NSCC cluster.

#PBS -N moduletest
#PBS -l select=1:ncpus=1:mem=10GB
#PBS -l walltime=4:00:00
#PBS -j oe
#PBS -P 12003580
#PBS -q normal

eval "$(conda shell.bash hook)"
if conda activate /home/users/ntu/suffiazi/apps/mambaforge/envs/tobias-footprinting;
then
	echo "Module load successful"
else
	echo "Module load failed"
fi

echo "Testing loaded environment..."
if TOBIAS -h;
then
	echo "TOBIAS loaded successfully"
else
	echo "TOBIAS failed to load"
fi

