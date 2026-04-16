#!/bin/bash
#SBATCH --job-name='medi_db_download'
#SBATCH --output='medi_db_download.out'
#SBATCH --mem=8G
#SBATCH --ntasks=1
#SBATCH --time=24:00:00
#SBATCH --nodes=1
#SBATCH --partition=amilan
#SBATCH --qos=normal


WORKDIR=$1
CONFIG=$2

cd $WORKDIR

module load "miniforge/24.11.3-0"
mamba activate medi

echo "Beginning of script"
date

nextflow run database.nf \
             -c $CONFIG \
             -profile slurm \
     #activate this if job fails       -resume \
             -with-report \
             -with-trace \
             -with-timeline

echo "End of script"
date
