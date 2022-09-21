# Nextflow Implementation of the Blanco-Melo Lab Steady State (RNA-seq) Pipeline

### Usage

#### Slurm-Specific Usage Requirements
##### Primary Run Settings

If you are using Linux, this will install nextflow to your home directory. As such, to run Nextflow, you will need add your user home directory to your PATH. Use the following command to set your home directory to your PATH as a variable so you can still access other paths on your cluster without conflict:

    $export PATH=~:$PATH

Secondly, edit the appropriate config file, e.g. `conf/slurm_grch38.config`, to ensure the proper paths are set for genome reference files and other executables (look for all mentions of `COMPLETE_*`). Variable names should hopefully be self-explanatory. An example run with the required arguments is as follows:

```
    $ nextflow run main.nf -profile slurm_grch38 --workdir '</nextflow/work/temp/>'  --outdir '</my/project/>' --email <john.doe@themailplace.com> --sras '</dir/to/sras/*>'
    
```

Directory paths for sras/fastqs must be enclosed in quotes. Notice the name of the configuration file. It's generally a good idea to keep separate configuration files for samples using different reference genomes, and different organisms. The pipeline runs ***paired-end by default***. The --singleEnd flag must be added for all single-end data. While most nascent data is single-end, Groovy configurations make paired-end processing an easier default.

If anything went wrong, you don't need to restart the pipeline from scratch. Instead...

    $ nextflow run main.nf -profile slurm_grch38 -resume
    
To see a full list of options and pipeline version, enter:
    
    $ nextflow run main.nf -profile slurm_grch38 --help

##### Python Package Requirements

***IMPORTANT: For individual users, we highly recommend installing all python packages in a virtual environment***

This pipeline requires a number of optional python packages for qc and analysis. These packages are already installed within a shared directory. You can configure the environment by running the following commands:

```
WD=/fh/scratch/delete30/blancomelo_d/RNAseq_pipeline
module load Python/3.8.2-GCCcore-9.3.0 nextflow
alias java=${WD}/opt/jdk-18.0.2.1/bin/java
export PATH=${WD}/opt/jdk-18.0.2.1/bin:$PATH
export JAVA_HOME=${WD}/opt/jdk-18.0.2.1/
export EBROOTJAVA=${WD}/opt/jdk-18.0.2.1/
export PATH=$PATH:${WD}/opt/STAR-2.7.10a/bin/Linux_x86_64_static
for d in $WD/opt; do export PATH="$PATH:$d"; done
for d in $WD/opt/*; do export PATH="$PATH:$d"; done
for d in $WD/opt/*/bin; do export PATH="$PATH:$d"; done
for d in $WD/opt/python_packages/*/bin; do export PATH="$PATH:$d"; done
for d in ${WD}/opt/python_packages/*; do export PYTHONPATH="$PYTHONPATH:$d"; done
```

##### Running Nextflow Using an sbatch script

The best way to run Nextflow is using an sbatch script using the same command specified above. It's advisable to execute the workflow at least in a `screen` session, so you can log out of your cluster and check the progress and any errors in standard output more easily. Nextflow does a great job at keeping logs of every transaction, anyway, should you lose access to the console. The memory requirements do not exceed 8GB, so you do not need to request more RAM than this. SRAs must be downloaded prior to running the pipeline.

Example commands to be used on Fred Hutch Rhino node are listed below. 
```
# To download and analyze SE RNAseq
SRR=SRR19572981
sbatch  -N 1 -n 1 -c 16 \
        --job-name="nextflow_se" \
        --error=./%x_%j.err --output=./%x_%j.out \
        --wrap="nextflow ${WD}/RNAseq_NextFlow/main.nf -profile rhino_hg38 --sras $SRR --singleEnd --count"

# To download and analyze PE RNAseq
SRR=SRR19795679
sbatch  -N 1 -n 1 -c 16 \
        --job-name="nextflow_pe" \
        --error=./%x_%j.err --output=./%x_%j.out \
        --wrap="nextflow ${WD}/RNAseq_NextFlow/main.nf -profile rhino_hg38 --sras $SRR --count"
```

## Arguments

**Required Arguments**

| Arugment  | Usage                            | Description                                                          |
|-----------|----------------------------------|----------------------------------------------------------------------|
| -profile  | \<base,slurm\>                    | Configuration profile to use.                                       |
| --fastqs  | \</project/\*\_{R1,R2}\*.fastq.gz\> | Directory pattern for fastq files (gzipped).                      |
| --sras    | \</project/\*.sra\>              | Directory pattern for sra files.                                     |
| --workdir | \</project/tmp/\>                | Nextflow working directory where all intermediate files are saved.   |
| --email   | \<EMAIL\>                        | Where to send workflow report email.                                 |

**Save Options**

| Arguments  | Usage         | Description                                               |
|------------|---------------|-----------------------------------------------------------|
| --outdir   | \</project/\> | Specifies where to save the output from the nextflow run. |
| --savefq   |               | Compresses and saves raw fastq reads.                     |
| --saveTrim |               | Compresses and saves trimmed fastq reads.                 |
| --saveAll  |               | Compresses and saves all fastq reads.                     |
| --skipBAM  |               | Skips saving BAM files (only save CRAM). Default=False    |
| --savebw   |               | Save normalized BigWig files for UCSC genome broswer.     |
| --savebg   |               | Saves concatenated pos/neg bedGraph file.                 |

**Input File Options**

| Arguments    | Usage       | Description                                                                  |
|--------------|-------------|------------------------------------------------------------------------------|
| --singleEnd  |             | Specifies that the input files are not paired reads (default is paired-end). |
| --flip       |             | Reverse complements each strand. Necessary for some library preps.           |
| --flipR2     |             | Reverse complements R2 only (will not work in singleEnd mode).               |

**Performance Options**

| Arguments       | Usage       | Description                                             |
|-----------------|-------------|---------------------------------------------------------|
| --threadfqdump  |             | Runs multi-threading for fastq-dump for sra processing. |

**QC Options**

| Arguments       | Usage       | Description                                             |
|-----------------|-------------|---------------------------------------------------------|
| --skipMultiQC   |             | Skip running MultiQC.                                   |
| --skipRSeQC     |             | Skip running RSeQC.                                     |

**Analysis Options**

| Arguments       | Usage       | Description                                                                         |
|-----------------|-------------|-------------------------------------------------------------------------------------|
| --count       |               | Count reads (FPKM normalized) over RefSeq gene file. ***Should not be used as stand-alone analysis! Only to be used as a quick first pass.*** |

### Credits

* Qing Yang <qyang@fredhutch.org>

