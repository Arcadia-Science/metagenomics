include { SOURMASH_SKETCH                           }   from '../../modules/local/nf-core-modified/sourmash/sketch'
include { SOURMASH_COMPARE                          }   from '../../modules/local/nf-core-modified/sourmash/compare'
include { SOURMASH_GATHER                           }   from '../../modules/local/nf-core-modified/sourmash/gather'
include { SOURMASH_TAXANNOTATE                      }   from '../../modules/local/nf-core-modified/sourmash/taxannotate'

workflow SOURMASH_PROFILING {
    take:
    sequences       // tuple val(meta), path(assemblies) OR tuple val(meta), path(reads)
    seqtype         // "reads" or "assembly"
    databases_csv  // path(sourmash_dbs_csv) CSV file of database_path,lineage_path and can contain multiple rows of databases and lineage paths

    main:
    ch_versions = Channel.empty()

    // read in databases from input CSV
    // collects all of them together to make a list to run once per sample
    ch_sourmash_databases = Channel.fromPath(databases_csv)
        .splitCsv(header:true, sep:',')
        .filter { row -> row.database_path != null }
        .map { row -> file(row.database_path) }
        .collect()
        .toList()

    // read in lineages from input CSV
    ch_sourmash_lineages = Channel.fromPath(databases_csv)
        .splitCsv(header:true, sep:',')
        .filter { row -> row.lineage_path != null }
        .map { row -> file(row.lineage_path) }
        .collect()
        .toList()

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
    // prep all combinations of input files with combined databases
    ch_input_gather = ch_signatures
        .combine(ch_sourmash_databases)

    SOURMASH_GATHER(ch_input_gather, seqtype,
        [], // val save_unassigned
        [], // val save_matches_sig
        [], // val save_prefetch
        []  // val save_prefetch_csv
    )
    ch_gather_result = SOURMASH_GATHER.out.result
    ch_versions = ch_versions.mix(SOURMASH_GATHER.out.versions)

    // taxonomy against lineage CSV
    // combine per sample all lineage CSVs
    ch_input_taxannotate = ch_gather_result
        .combine(ch_sourmash_lineages)
    SOURMASH_TAXANNOTATE(ch_input_taxannotate, seqtype)
    ch_tax_result = SOURMASH_TAXANNOTATE.out.result
    ch_versions = ch_versions.mix(SOURMASH_TAXANNOTATE.out.versions)

    // sourmashconsumr module for running functions to process all files
    // TODO: calls a script that outputs an HTML document for Rmarkdown rendering???

    emit:
    ch_signatures
    ch_compare_matrix
    ch_compare_csv
    ch_gather_result
    ch_tax_result
    versions = ch_versions
}
