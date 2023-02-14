# Arcadia-Science/metagenomics Output

This page describes the output files and report produced by the pipeline. The directories listed below are created in the results directory after the pipeline has finished.
**This page is an active work in progress as the workflow is in development**

## Pipeline Overview

This pipeline takes in metagenomic reads, performs QC, assembly, and subsequent mapping of reads back to the resulting assemblies. Steps downstream of assembly and mapping are identical for processing data from both sequencing types.

### Illumina-Specific Outputs

Read QC and adapter trimming is performed with `fastp`, and assembly performed with `metaspades`. Reads are mapped back to the assembly with `bowtie2`.

### Nanopore-Specific Outputs

Read statistics are output with `NanoStat`. Adapter trimming is performed with `porechop_ABI`, the successor to the popular adapter trimming software `porechop`. Assembly is performed with `flye` using the `--meta` option. Reads are mapped to the assembly with `minimap2` to then polish with `racon` and get differential coverage statistics.

### General Outputs

Assemblies are QCed with `QUAST` for general statistics. Depth of reads mapping back to the resulting assembly is calculated with `jgisummarizebamcontigs` from `metabat2`.
