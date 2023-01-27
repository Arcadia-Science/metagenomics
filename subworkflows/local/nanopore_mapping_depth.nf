// Minimap2 subworkflow to index an assembly and map reads to the assembly


include { MINIMAP2_INDEX }                          from '../../modules/nf-core/minimap2/index'
include { MINIMAP2_ALIGN }                          from '../../modules/nf-core-modified/minimap2/align'
include { METABAT2_JGISUMMARIZEBAMCONTIGDEPTHS }    from '../../modules/nf-core/metabat2/jgisummarizebamcontigdepths'

workflow NANOPORE_MAPPING_DEPTH {
    take:
    assembly // tuple val(meta), path(fasta)
    reads    // tuple val(meta), path(reads)

    main:
    ch_versions = Channel.empty()

    // build index
    MINIMAP2_INDEX(assembly)
    ch_versions = ch_versions.mix(MINIMAP2_INDEX.out.versions)
    ch_index = MINIMAP2_INDEX.out.index

    // align reads to index, get SAM for polishing, BAM for calculating depth
    MINIMAP2_ALIGN(reads, ch_index)
    ch_versions = ch_versions.mix(MINIMAP2_ALIGN.out.versions)
    ch_align_sam = MINIMAP2_ALIGN.out.sam
    ch_align_bam = MINIMAP2_ALIGN.out.sorted_bam
    ch_align_index = MINIMAP2_ALIGN.out.indexed_bam

    // get depth
    METABAT2_JGISUMMARIZEBAMCONTIGDEPTHS(ch_align_bam, ch_align_index)
    ch_versions = ch_versions.mix(METABAT2_JGISUMMARIZEBAMCONTIGDEPTHS.out.versions.first())
    ch_depth = METABAT2_JGISUMMARIZEBAMCONTIGDEPTHS.out.depth

    emit:
    ch_index
    ch_align_sam // for polishing with racon
    ch_align_bam // sorted, indexed BAM file for calculating depth
    ch_align_index // indexed BAM file for calculating depth
    ch_depth
    versions = ch_versions

}
