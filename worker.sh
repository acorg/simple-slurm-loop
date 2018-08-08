#!/bin/bash -e

#SBATCH -J worker
#SBATCH -A ACORG-SL2-CPU
#SBATCH -o worker-%A.out
#SBATCH -p skylake
#SBATCH --time=00:02:00

. common.sh

echo $RANDOM >> $RESULT_FILE
