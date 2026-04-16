#!/bin/bash
#SBATCH --job-name='medi_quant'
#SBATCH --output='medi_quant_.out'
#SBATCH --mem=8G
#SBATCH --ntasks=1
#SBATCH --time=168:00:00
#SBATCH --nodes=1
#SBATCH --partition=amilan
#SBATCH --qos=long


WORKDIR=$1
CONFIG=$2
FILENAME=$3
SOURCE=$4
OUTDIR=$5

cd $WORKDIR

mkdir -p data/raw

while IFS= read -r basename; do
    [ -z "$basename" ] && continue
    
    # MAGIC STRING REPLACEMENT: Change all '.' to '-' in the base name
    # e.g., 'sample.1.A' becomes 'sample-1-A'
    safe_basename="${basename//./-}"

    # Use the wildcard to find all matching files (R1, R2, etc.)
    for file in "$SOURCE/$basename"*; do
        
        # Skip if no file is actually found
        [ -e "$file" ] || continue
        
        # Extract just the filename (removes the /path/to/source_folder/ part)
        fname=$(basename "$file")
        
        # Swap the old base name out for the new safe one, leaving the .fastq.gz intact!
        new_fname="${fname/$basename/$safe_basename}"
        
        # create symlink
        ln -s  "$file" "data/raw/$new_fname"
        echo "Copied: $fname -> $new_fname"
        
    done
done < "$FILENAME"



module load "miniforge/24.11.3-0"
mamba activate medi

echo "Beginning of script"
date

nextflow run quant.nf --mapping --out_dir $OUTDIR -c $CONFIG \
             -profile slurm \
             -with-report \
             -with-trace \
             -with-timeline

## delete all symlinks
find data/raw -type l -delete

echo "End of script"
date
