# Arcadia-Science/metagenomics Usage

This page provides documentation on how to use the Arcadia-Science/metagenomics pipeline.

## Input specifications

This pipeline processes metagenomic reads in FASTQ format from either Illumina or Nanopore technologies. **Important note**: This pipeline separately processes Illumina or Nanopore metagenomes and does not perform hybrid assembly, polishing of Nanopore assemblies with Illumina reads, or scaffolding with Nanopore reads.

### Input samplesheet

For Nanopore reads, the pipeline takes as direct input a single fastq file and does not perform demultiplexing or basecalling, so it expects that those steps should be done prior to feeding into the pipeline and aggregating into a single fastq file.

The workflow takes a CSV samplesheet listing the sample names and paths to the fastq files as direct input. It does not take the path to the directory of the fastq files, you must list them in a samplesheet. The CSV must contain the columns:

`sample, fastq_1, fastq_2`
Neither the `sample` or `fastq*` columns may contain spaces, and the `fastq` columns contains the path(s) to your fastq file(s).

If you are inputting Illumina reads, the samplesheet looks like the following:

```
sample,fastq_1,fastq_2
comm_1,https://github.com/Arcadia-Science/test-datasets/raw/main/metagenomics/illumina/comm_1_subsampled_1.fq.gz,https://github.com/Arcadia-Science/test-datasets/raw/main/metagenomics/illumina/comm_1_subsampled_2.fq.gz
vir_1,https://github.com/Arcadia-Science/test-datasets/raw/main/metagenomics/illumina/vir_1_subsampled_1.fq.gz,https://github.com/Arcadia-Science/test-datasets/raw/main/metagenomics/illumina/vir_1_subsampled_2.fq.gz
```

If you are inputting Nanopore reads, the samplesheet looks like the following:

```
sample,fastq_1,fastq_2
om,https://github.com/Arcadia-Science/test-datasets/raw/main/metagenomics/ont/om_subset_reads.fq.gz,
el,https://github.com/Arcadia-Science/test-datasets/raw/main/metagenomics/ont/el_subset_reads.fq.gz,
```

Note that even for Nanopore reads which the input is in a single fastq file, still include the third column for `fastq_2` - the pipeline for processing Nanopore reads will ignore this and process your Nanopore reads that are in a single fastq file.

### Sourmash Databases

Additionally, you will need to provide a CSV containing the paths of sourmash databases and corresponding lineage files that you want to run against your samples. These files will need to be downloaded prior to running the workflow, and the CSV passed to the `--sourmash_dbs` parameter should look like:

```
database_path,lineage_path
https://github.com/Arcadia-Science/test-datasets/raw/main/metagenomics/sourmash_dbs/GCF_001457635.1.db.zip,https://github.com/Arcadia-Science/test-datasets/raw/main/metagenomics/sourmash_dbs/GCF_001457635.1.taxonomy.csv
https://github.com/Arcadia-Science/test-datasets/raw/main/metagenomics/sourmash_dbs/GCF_003697165.2.db.zip,https://github.com/Arcadia-Science/test-datasets/raw/main/metagenomics/sourmash_dbs/GCF_003697165.2.taxonomy.csv
```

### DIAMOND database

Finally, you will need to provide the path to an already prepared DIAMOND database of your choosing. For example, we prepared a DIAMOND database of the Uniprot uniref90 along with taxonomy information.

We first downloaded and prepared the Uniref90 proteins and necessary taxonomy files from NCBI with:

```
# uniref90 fasta
wget https://ftp.uniprot.org/pub/databases/uniprot/uniref/uniref90/uniref90.fasta.gz

# taxonomy files
wget https://ftp.ncbi.nlm.nih.gov/pub/taxonomy/taxdmp.zip
wget https://ftp.ncbi.nlm.nih.gov/pub/taxonomy/accession2taxid/prot.accession2taxid.FULL.gz

# unzip files
gunzip taxdmp.zip
tar -xzvf prot.accession2taxid.FULL.gz
```

And the DIAMOND database prepared with:

```
diamond makedb --in uniref90.fasta.gz --taxonmap prot.accession2taxid.FULL --taxonnodes taxdmp/nodes.dmp --taxonnames taxdmp/names.dmp -d 2023-04-26-uniref90.dmnd
```

You can create a DIAMOND database from any set of input proteins with `makedb` and then specify the output columns that are appropriate. By default the `qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore` DIAMOND columns are output with any provided input DIAMOND database. With the above Uniprot uniref90 database that has taxonomy information as well, we use the columns `qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore qlen slen staxids sscinames stitle`. You can check out the [DIAMOND documentation](https://github.com/bbuchfink/diamond/wiki) for more information on preparing databases and column output options.

## Running the pipeline

A typical command for running the pipeline looks like:
` nextflow run Arcadia-Science/metagenomics --input <SAMPLESHEET.csv> --outdir <OUTDIR> --platform <illumina|nanopore> --sourmash_dbs sourmash_dbs.csv -profile docker`

This will launch the pipeline with the `docker` configuration profile. See below for more information about profiles. The options for `--platform` are either `illumina` or `nanopore` depending on your sequencing file input. Therefore, you cannot run both Illumina and Nanopore sequencing files in the same run - instead submit separate runs. The pipeline will create the following files and directories in your working directory:

```
work                # Directory containing the nextflow working files
<OUTDIR>            # Finished results in specified location (defined with --outdir)
.nextflow_log       # Log file from Nextflow
# Other nextflow hidden files, eg. history of pipeline runs and old logs.
```

### Updating the pipeline

When you run the above command, Nextflow automatically pulls the pipeline code from GitHub and stores it as a cached version. When running the pipeline after this, it will always use the cached version if available - even if the pipeline has been updated since. To make sure you are running the latest version of the pipeline, regularly update the cached version with:
`nextflow pull Arcadia-Science/metagenomics`

## Pipeline arguments

Below lists several arguments to configure core parts of how Nextflow is run and pipeline-specific arguments you can modify.

### Core Nextflow arguments

These options are part of Nextflow and use a single hyphen.

#### `-profile`

Use this parameter to choose a configuration profile. Profiles can give configuration presets for different compute environments. Several generic profiles are bundled with the pipeline which instruct the pieline to use software packaged using different methods (Docker, Singularity, Conda, etc.) When using Biocontainers, most of the software packaging methods pull Docker containers from quay.io except for Singularity which directly downloads Singularity images via https hosted by the Galaxy project and Conda which downloads and installs software locally from Bioconda.

We highly recommend the user of Docker or Singularity containers for full pipeline reproducibility, and have personally tested using Docker containers extensively within Arcadia. Other generic profiles besides the above listed are available, but they are untested and you can use at your own discretion.

If `-profile` is not specified, the pipeline will run locally and expect all software to be installed and available on the `PATH` which is not recommended.

- `docker`
  - A generic configuration profile to be used with Docker
- `singularity`
  - A generic configuration profile to be used with Singularity
- `conda`
  - A generic configuration profile to be used with Conda. Please only use Conda as a last resort, such as when it is not possible to run with Docker, Singularity, or the other preset configurations.
- `test`, `test_full`
  - Profiles with a complete configuration for automated testing. This includes links to test data and need no other parameters

#### `-resume`

Specify this when restarting the pipeline from a previously failed run, updated part of the pipeline, or additional samples. Nextflow will use cached results from any pipeline steps where the inputs are the same, continuing from where it got to previously. For the input to be considered the same, not only the names of the files must be identical but all the files' contents as well.

#### `-c`

Specify the path to a specific config file.

#### Running in the background

Nextflow handles job submissions and supervises running jobs. The Nextflow process must run until the pipeline is finished. The Nextflow `-bg` flag launches Nextflow in the background, detached from your terminal so that the workflow does not stop if you log out of your session. The logs are saved to a file. Alternatively you can use `screen`/`tmux` or a similar tool to create a detached session which you can log back into at a later time.

### Pipeline-specific arguments

#### `--platform`

This argument is required and you must input either `illumina` or `nanopore` depending on your input sequencing files. Therefore a combination of Illumina and Nanopore sequencing files **CANNOT** be run in the same submission - instead submit two jobs differentiating between the two file types.

#### `--sourmash_dbs`

This argument is required and you must download the sourmash databases and lineage CSVs prior to running the workflow. You can find several pre-prepared sourmash databases at [https://sourmash.readthedocs.io/en/latest/databases.html](https://sourmash.readthedocs.io/en/latest/databases.html). You must download and use the same kmer size for each database, and we use `k31` as a default kmer size throughout the workflow. Once you have these downloaded, prepare the CSV as shown above.

#### `--diamond_db`

This argument is required and you must download and/or prepare a DIAMOND database prior to running the workflow. This database must be of proteins as the workflow runs `diamond blastp` against all predicted proteins from generated assemblies.

#### `--diamond_columns`

By default the workflow directs DIAMOND to output the `diamond blastp` results with columns `qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore` however you can modify this with additional or fewer column options that DIAMOND allows.
