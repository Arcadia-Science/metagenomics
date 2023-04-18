# Arcadia-Science/metagenomics Output

This page describes the output files and report produced by the pipeline. The directories listed below are created in the results directory after the pipeline has finished.
**This page is an active work in progress as the workflow is in development**

## Pipeline Overview

This pipeline takes in metagenomic samples produced from either Illumina or Nanopore technologies and performs common QC, processing, and profiling steps. **Important note**: This pipeline separately processes Illumina or Nanopore metagenomes and does not perform hybrid assembly, polishing of Nanopore assemblies with Illumina reads (only polishing with the long reads themselves), or scaffolding with Nanopore reads.

This pipeline is intended to automate the common QC and processing steps to ensure seamless and reproducible processing of metagenomes for downstream analysis. Therefore the end goal of the pipeline regardless of which sequencing technology used is to produce QC stats of the reads, generate assemblies (including polishing for Nanopore), map the original reads back to the assemblies and get mapping statistics, and summarize the composition of the metagenomes such as taxonomy summaries. 

Since Illumina or Nanopore metagenomes have to be processed separately, you can find the corresponding results files produced from each step of the pipeline in a folder with the name of the tool. For example, QCed Illumina reads will be in a subfolder of your output results directory called `fastp/`.

### Illumina-Specific Outputs

Read QC and adapter trimming is performed with `fastp`, and assembly performed with `metaspades`. Reads are mapped back to the assembly with `bowtie2`. QC stats for both the reads and resulting assemblies are listed in the MultiQC report. The intermediate files, logs, and resulting files such as QCed reads, assemblies, and mapping BAM files can be found in the folders with the name of each tool.

### Nanopore-Specific Outputs

Read statistics are output with `NanoStat`. Adapter trimming is performed with `porechop_ABI`, the successor to the popular adapter trimming software `porechop`. Assembly is performed with `flye` using the `--meta` option. Reads are mapped to the assembly with `minimap2` to then polish with `medaka` and get differential coverage statistics. The intermediate files, logs, and resulting files such as the QCed reads, draft assemblies, polished assemblies, and mapping BAM files can be found within the folders with the name of each tool.

### Sourmash Output Files

Sourmash is a command-line tool for computing hash sketches from DNA sequences, which can be used to compare DNA sequences against each other such as for samples similarity comparisons or obtaining taxonomic composition information by comparing against databases of publicly available sequences. In this pipeline, the sourmash subworkflow runs `sourmash sketch`, `sourmash compare`, `sourmash gather` and `sourmash taxannotate` on the sets of input samples separately for resulting QCed reads and assemblies. The outputs including individual sketches for each sample, comparison results of all sketches against each other, and gather and taxannotate results can be used to explore sample similarity and composition based on the input databases that are supplied in the CSV via the `--sourmash_dbs` parameter.

### General Outputs and MultiQC HTML Report

Assemblies are QCed with `QUAST` for general statistics. Depth of reads mapping back to the resulting assembly is calculated with `jgisummarizebamcontigs` from the `metabat2` software. Depth results of the reads mapped back to the corresponding assembly can be found in a TSV file in `metabat2/jgisummarizebamcontigs`.

Separate HTML reports are generated depending on if you run the workflow with `--platform illumina` or `--platform nanopore`, as the read QC tools used to summarize read quality are different, and therefore the report modules will be different as well. However the overall structure of the reports are similar - showing the reports of read QC, assembly QC stats, mapping statistics, and versions of software used in the pipeline run.
