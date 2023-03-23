include { SOURMASH_SKETCH                           }   from '../../modules/local/nf-core-modified/sourmash/sketch'
include { SOURMASH_COMPARE                          }   from '../../modules/local/nf-core-modified/sourmash/compare'
include { SOURMASH_GATHER                           }   from '../../modules/local/nf-core-modified/sourmash/gather'

workflow SOURMASH_PROFILING {
    take:
    sequences  // tuple val(meta), path(assemblies) OR tuple val(meta), path(reads)
    seqtype
    databases  // path(databases)
    lineages   // path(lineages)

    main:
    ch_versions = Channel.empty()

    // sketch
    SOURMASH_SKETCH(sequences, seqtype)
    ch_signatures = SOURMASH_SKETCH.out.signatures
    ch_versions = ch_versions.mix(SOURMASH_SKETCH.out.versions)
    view(ch_signatures)

    // compare
    ch_compare = ch_signatures
        .collect{ it[1] }
        .map {
            signatures ->
                def meta = [:]
                meta.id = "k31"
                [ meta, signatures ]
        }
    SOURMASH_COMPARE(ch_compare, seqtype, [], true, true)
    ch_compare_matrix = SOURMASH_COMPARE.out.matrix
    ch_compare_csv = SOURMASH_COMPARE.out.csv
    ch_versions = ch_versions.mix(SOURMASH_COMPARE.out.versions)

    // gather against database
    SOURMASH_GATHER(ch_signatures,
        databases,
        seqtype,
        [], // val save_unassigned
        [], // val save_matches_sig
        [], // val save_prefetch
        []  // val save_prefetch_csv
    )
    ch_gather_result = SOURMASH_GATHER.out.result
    ch_versions = ch_versions.mix(SOURMASH_GATHER.out.versions)

    // taxonomy against lineage CSV

    // sourmashconsumr module for running functions to process all files

    emit:
    ch_signatures
    ch_compare_matrix
    ch_compare_csv
    ch_gather_result
    versions = ch_versions
}
