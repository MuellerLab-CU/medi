# RUN medi in alpine slurm HPC

This folder contains the configuration and job submission file to run medi in [Alpine server at CU](https://curc.readthedocs.io/en/latest/clusters/alpine/index.html).

## Prerequisite:

You should first clone this repo to the server workspace and
finish the installation and report generator compilation

## Database building:

There is a pre-compiled database archived (built in Apr 2026). Email shaoming.xiao@cuanschutz.edu for more information

If building from scratch in alpine:

1. Build food genome sequences and taxonomy 

```bash
sbatch download_db_submit.sh [THE PATH TO LOCAL MEDI FOLDER] nextflow.config
```

Tips:

- Configure `.Rprofile`: put your NCBI API key in bracket for downloading from NCBI

2. Build kraken database (We split the original kraken_build.nf into two due to max time limit of 7 days in alpine server)

```bash
sbatch build_kraken_submit.sh [THE PATH TO LOCAL MEDI FOLDER] nextflow.config
```

3. Build bracken database

```bash
sbatch build_bracken_submit.sh [THE PATH TO LOCAL MEDI FOLDER] nextflow.config
```

Tips:

- The building will take days, be patient
- In the future, the db size may go up, so please tweak the resources requested in `nextflow.config`.

##  Run your job in batches

```bash
sbatch quant_submit.sh [THE PATH TO LOCAL MEDI FOLDER] nextflow.config [SAMPLE NAME LIST] [RAW SEQUENCING DATA SOURCE FOLDER] [OUTPUT DIRECTORY]
```

Warning:

- The default batch size is 400, but the maximum job alpine allowed is 500, so add `--batchsize xx` to the nextflow code in quant_submit.sh if needed
- If sample name contains '.', it will be replaced with '-' since the pipeline is not happy with '.' and will truncate
