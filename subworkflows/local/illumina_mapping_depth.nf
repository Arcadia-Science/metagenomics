/*
 * Bowtie2 build and align steps for mapping
 */

include { BOWTIE2_ASSEMBLY_BUILD                          } from '../../modules/local/bowtie2_assembly_build'
include { BOWTIE2_ASSEMBLY_ALIGN                          } from '../../modules/local/bowtie2_assembly_align'
include { METABAT2_JGISUMMARIZEBAMCONTIGDEPTHS            } from '../../modules/local/nf-core-modified/metabat2/jgisummarizebamcontigdepths/main'
include { SAMTOOLS_STATS                                  } from '../../modules/nf-core/samtools/stats/main'

workflow ILLUMINA_MAPPING_DEPTH {
    take:
    assemblies
    reads

    main:
    ch_versions = Channel.empty()

    // build index
    BOWTIE2_ASSEMBLY_BUILD(assemblies)
    ch_versions = ch_versions.mix(BOWTIE2_ASSEMBLY_BUILD.out.versions)
    ch_index = BOWTIE2_ASSEMBLY_BUILD.out.index

    // align reads to index, get sorted and indexed BAM
    BOWTIE2_ASSEMBLY_ALIGN(assemblies, ch_index, reads)
    ch_versions = ch_versions.mix(BOWTIE2_ASSEMBLY_ALIGN.out.versions)
    ch_align_bam = BOWTIE2_ASSEMBLY_ALIGN.out.sorted_indexed_bam
    ch_log = BOWTIE2_ASSEMBLY_ALIGN.out.log

    // summarize contigs with metabat2
    METABAT2_JGISUMMARIZEBAMCONTIGDEPTHS (ch_align_bam)
    ch_versions = ch_versions.mix(METABAT2_JGISUMMARIZEBAMCONTIGDEPTHS.out.versions.first())
    ch_depth = METABAT2_JGISUMMARIZEBAMCONTIGDEPTHS.out.depth

    // samtools stats
    SAMTOOLS_STATS(ch_align_bam, assemblies)
    ch_stats = SAMTOOLS_STATS.out.stats
    ch_versions = ch_versions.mix(SAMTOOLS_STATS.out.versions)


    // emit results
    emit:
    ch_stats         // stats from samtools stats for % mapped
    ch_index         // bowtie2 index
    ch_align_bam     // sorted, indexed BAMs
    ch_depth        // depth table from metabat2
    versions = ch_versions
}
