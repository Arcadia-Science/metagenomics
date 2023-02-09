/*
 * Bowtie2 build and align steps for mapping
 */

include {BOWTIE2_ASSEMBLY_BUILD                          } from '../../modules/local/bowtie2_assembly_build'
include {BOWTIE2_ASSEMBLY_ALIGN                          } from '../../modules/local/bowtie2_assembly_align'
include {METABAT2_JGISUMMARIZEBAMCONTIGDEPTHS            } from '../../modules/nf-core/metabat2/jgisummarizebamcontigdepths/main'

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
    ch_align_bam = BOWTIE2_ASSEMBLY_ALIGN.out.bam
    ch_indexed_bam = BOWTIE2_ASSEMBLY_ALIGN.out.indexed_bam
    ch_log = BOWTIE2_ASSEMBLY_ALIGN.out.log

    // summarize contigs with metabat2
    METABAT2_JGISUMMARIZEBAMCONTIGDEPTHS (ch_align_bam, ch_indexed_bam)
    ch_versions = ch_versions.mix(METABAT2_JGISUMMARIZEBAMCONTIGDEPTHS.out.versions.first())
    ch_depth = METABAT2_JGISUMMARIZEBAMCONTIGDEPTHS.out.depth

    // emit results
    emit:
    ch_index
    ch_align_bam
    ch_indexed_bam
    ch_depth
    versions = ch_versions
}
