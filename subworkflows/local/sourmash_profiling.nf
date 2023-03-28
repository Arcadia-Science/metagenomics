include { SOURMASH_SKETCH                           }   from '../../modules/local/nf-core-modified/sourmash/sketch'
include { SOURMASH_COMPARE                          }   from '../../modules/local/nf-core-modified/sourmash/compare'
include { SOURMASH_GATHER                           }   from '../../modules/local/nf-core-modified/sourmash/gather'
include { SOURMASH_TAXANNOTATE                      }   from '../../modules/local/nf-core-modified/sourmash/taxannotate'

workflow SOURMASH_PROFILING {
    take:
    sequences  // tuple val(meta), path(assemblies) OR tuple val(meta), path(reads)
    seqtype
    databases  // tuple val (database_meta), path(database_path)
    // path(lineages)

    main:
    ch_versions = Channel.empty()

    // sketch
    SOURMASH_SKETCH(sequences, seqtype)
    ch_signatures = SOURMASH_SKETCH.out.signatures
    ch_versions = ch_versions.mix(SOURMASH_SKETCH.out.versions)

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
    // prep all combinations of input files with databases
    ch_input_gather = ch_signatures
        .combine(databases)

    SOURMASH_GATHER(ch_input_gather, seqtype,
        [], // val save_unassigned
        [], // val save_matches_sig
        [], // val save_prefetch
        []  // val save_prefetch_csv
    )
    ch_gather_result = SOURMASH_GATHER.out.result
    ch_versions = ch_versions.mix(SOURMASH_GATHER.out.versions)

    // taxonomy against lineage CSV
    SOURMASH_TAXANNOATE()

    // sourmashconsumr module for running functions to process all files
    // calls a script that outputs an HTML document for Rmarkdown rendering???

    emit:
    ch_signatures
    ch_compare_matrix
    ch_compare_csv
    ch_gather_result
    versions = ch_versions
}
