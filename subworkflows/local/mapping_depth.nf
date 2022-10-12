
/*
 * Bowtie2 build and align steps for mapping
 */

include {BOWTIE2_ASSEMBLY_BUILD                          } from '../../modules/local/bowtie2_assembly_build'
include {BOWTIE2_ASSEMBLY_ALIGN                          } from '../../modules/local/bowtie2_assembly_align'
include {METABAT2_JGISUMMARIZEBAMCONTIGDEPTHS            } from '../../modules/nf-core/metabat2/jgisummarizebamcontigdepths/main'

workflow MAPPING_DEPTH {
    take:
    assemblies
    reads

    main:
    ch_versions = Channel.empty()

    // build index
    BOWTIE2_ASSEMBLY_BUILD ( assemblies )
    ch_versions = ch_versions.mix(BOWTIE2_ASSEMBLY_BUILD.out.versions)

    // prepare for mapping
    ch_reads_bowtie2 = reads.map{ meta, reads -> [ meta.id, meta, reads ] }
    ch_bowtie2_input = BOWTIE2_ASSEMBLY_BUILD.out.assembly_index
        .map{ meta, assembly, index -> [ meta.id, meta, assembly, index ] }
        .combine(ch_reads_bowtie2, by: 0)
        .map{ id, assembly_meta, assembly, index, reads_meta, reads -> [ assembly_meta, assembly, index, reads_meta, reads ] }

    // align
    BOWTIE2_ASSEMBLY_ALIGN (ch_bowtie2_input )
    ch_grouped_mappings = BOWTIE2_ASSEMBLY_ALIGN.out.mappings
        .groupTuple(by: 0)
        .map{ meta, assembly, bams, bais -> [ meta, assembly.sort()[0], bams, bais ]}
    ch_versions = ch_versions.mix(BOWTIE2_ASSEMBLY_ALIGN.out.versions)

    // depth input prep
    ch_depth_input = ch_grouped_mappings.map { meta, assembly, bams, bais ->
                                            def meta_new = meta.clone()
                                        [meta_new, bams, bais]
    }

    // summarize contigs with metabat2
    METABAT2_JGISUMMARIZEBAMCONTIGDEPTHS (ch_depth_input )
    ch_versions = ch_versions.mix(METABAT2_JGISUMMARIZEBAMCONTIGDEPTHS.out.versions.first())
    ch_metabat_depths = METABAT2_JGISUMMARIZEBAMCONTIGDEPTHS.out.depth
        .map { meta, depths ->
                def meta_new = meta.clone()
                meta_new['binner'] = 'MetaBAT2'
                [meta_new, depths]
                }

    // emit results
    emit:
    grouped_mappings                = ch_grouped_mappings
    metabat_depths                  = ch_metabat_depths



}
