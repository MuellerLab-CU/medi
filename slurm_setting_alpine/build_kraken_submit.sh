#!/bin/bash
#SBATCH --job-name='medi_kraken_build'
#SBATCH --output='medi_kraken_build.out'
#SBATCH --mem=8G
#SBATCH --ntasks=1
#SBATCH --time=168:00:00
#SBATCH --nodes=1
#SBATCH --partition=amilan
#SBATCH --qos=long


WORKDIR=$1
CONFIG=$2

cd $WORKDIR

module load "miniforge/24.11.3-0"
mamba activate medi

echo "Beginning of script"
date

nextflow run build_db_kraken.nf \
             -c $CONFIG \
             -profile slurm \
          ## --rebuild activate this if add_sequences, add_existing works but later steps failed
             -with-report \
             -with-trace \
             -with-timeline

echo "End of script"
date
