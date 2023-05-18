# Arcadia-Science/metagenomics

[![Nextflow](https://img.shields.io/badge/nextflow%20DSL2-%E2%89%A522.10.1-23aa62.svg)](https://www.nextflow.io/)
[![run with conda](http://img.shields.io/badge/run%20with-conda-3EB049?labelColor=000000&logo=anaconda)](https://docs.conda.io/en/latest/)
[![run with docker](https://img.shields.io/badge/run%20with-docker-0db7ed?labelColor=000000&logo=docker)](https://www.docker.com/)
[![run with singularity](https://img.shields.io/badge/run%20with-singularity-1d355c.svg?labelColor=000000)](https://sylabs.io/docs/)
[![Launch on Nextflow Tower](https://img.shields.io/badge/Launch%20%F0%9F%9A%80-Nextflow%20Tower-%234256e7)](https://tower.nf/launch?pipeline=https://github.com/Arcadia-Science/metagenomics)

## Introduction

**Arcadia-Science/metagenomics** is a pipeline for profiling metagenomes obtained through either Illumina or Nanopore technologies.

The pipeline is built using [Nextflow](https://www.nextflow.io), a workflow tool to run tasks across multiple compute infrastructures in a very portable manner. It uses Docker/Singularity containers making installation trivial and results highly reproducible. The [Nextflow DSL2](https://www.nextflow.io/docs/latest/dsl2.html) implementation of this pipeline uses one container per process which makes it much easier to maintain and update software dependencies. Where possible, these processes have been submitted to and installed from [nf-core/modules](https://github.com/nf-core/modules) in order to make them available to all nf-core pipelines, and to everyone within the Nextflow community!

## Pipeline Summary

This pipeline performs common QC, processing, and profiling steps of metagenomes obtained through either Illumina or Nanopore technologies. The pipeline consists of two separate workflows for processing the Illumina and Nanopore data and producing assemblies. **Therefore Illumina or Nanopore samples are processed separately, as this pipeline does not handle hybrid assembly or polishing with short reads.** Downstream steps for summarizing the composition of metagenomes are mostly identical for the two technologies. You can find more information about how the pipeline operates in the [`docs`](docs/usage.md).

## Quick Start

1. Install [`Nextflow`](https://www.nextflow.io/docs/latest/getstarted.html#installation) (`>=22.10.1`)

2. Install [`Docker`](https://docs.docker.com/engine/installation/), [`Singularity`](https://www.sylabs.io/guides/3.0/user-guide/) (you can follow [this tutorial](https://singularity-tutorial.github.io/01-installation/)), or [`Conda`](https://conda.io/miniconda.html). You can use conda to install Nextflow itself but use it for managing software within pipelines as a last resort. We recommend using `Docker` if possible as this has been tested most frequently. See the nf-core [docs](https://nf-co.re/usage/configuration#basic-configuration-profiles)) for more information.

3. Download the pipeline and test it on the minimal datasets for Illumina and Nanopore:

   ```bash
   nextflow run Arcadia-Science/metagenomics -profile test_illumina,YOURPROFILE --outdir <OUTDIR>
   ```

   ```bash
   nextflow run Arcadia-Science/metagenomics -profile test_nanopore,YOURPROFILE --outdir <OUTDIR>
   ```

Note that some form of configuration will be needed so that Nextflow knows how to fetch the required software. This is usually done in the form of a config profile (`YOURPROFILE` in the example command above). You can chain multiple config profiles in a comma-separated string.

> - The pipeline comes with several config profiles, but we recommend using `docker` when possible, such as `-profile test,docker`.
> - Please check [nf-core/configs](https://github.com/nf-core/configs#documentation) to see if a custom config file to run nf-core pipelines already exists for your institute. If so, you can simply use `-profile <institute>` in your command. This will enable either `docker` or `singularity` and set the appropriate execution settings for your local compute environment.
> - If you are using `singularity`, please use the [`nf-core download`](https://nf-co.re/tools/#downloading-pipelines-for-offline-use) command to download images first, before running the pipeline. Setting the [`NXF_SINGULARITY_CACHEDIR` or `singularity.cacheDir`](https://www.nextflow.io/docs/latest/singularity.html?#singularity-docker-hub) Nextflow options enables you to store and re-use the images from a central location for future pipeline runs.
> - If you are using `conda`, it is highly recommended to use the [`NXF_CONDA_CACHEDIR` or `conda.cacheDir`](https://www.nextflow.io/docs/latest/conda.html) settings to store the environments in a central location for future pipeline runs.

4. Start running your own analysis!

Prior to running the workflow on your samples, you will need to prepare and download databases for `sourmash` and `DIAMOND`. There are a number of [already prepared `sourmash` databases](https://sourmash.readthedocs.io/en/latest/databases.html) available, and you can checkout the [`DIAMOND` documentation](https://github.com/bbuchfink/diamond/wiki) for creating a database compatible with `diamond blastp` used in the workflow. See the [usage documentation](docs/usage.md) for more information on how to prepare these databases.

```bash
nextflow run Arcadia-Science/metagenomics --input samplesheet.csv --outdir <OUTDIR> --platform <illumina|nanopore> --sourmash_dbs sourmash_dbs_paths.csv --diamond_db prepared_diamond_db.dmnd -profile <docker/singularity/conda/institute>
```

You can find more information about how to format your input samplesheet CSV and providing the paths to pre-downloaded `sourmash` and `DIAMOND` database files in `docs/usage.md`.

## Citations

The `nf-core` template was used as a guideline for putting this workflow together. You can cite the `nf-core` publication as follows:

> **The nf-core framework for community-curated bioinformatics pipelines.**
>
> Philip Ewels, Alexander Peltzer, Sven Fillinger, Harshil Patel, Johannes Alneberg, Andreas Wilm, Maxime Ulysse Garcia, Paolo Di Tommaso & Sven Nahnsen.
>
> _Nat Biotechnol._ 2020 Feb 13. doi: [10.1038/s41587-020-0439-x](https://dx.doi.org/10.1038/s41587-020-0439-x).
> An extensive list of references for the tools used by the pipeline can be found in the [`CITATIONS.md`](CITATIONS.md) file.
