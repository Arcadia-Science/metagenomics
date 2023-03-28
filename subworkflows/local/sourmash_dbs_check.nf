//
// Check input sourmash CSV and create two channels: DB and lineage channels each have the database name since are callled in different sourmash subcommands
//

include { CHECK_SOURMASH_DBS } from '../../modules/local/check_sourmash_dbs'

workflow SOURMASH_DBS_CHECK {
    take:
    sourmash_dbs_csv // file: /path/to/samplesheet.csv

    main:
    CHECK_SOURMASH_DBS (sourmash_dbs_csv)
        .csv
        .splitCsv ( header:true, sep:',' )
        .map { create_fastq_channel(it) }
        .set { sourmash_databases }

    emit:
    sourmash_databases
    versions = CHECK_SOURMASH_DBS.out.versions
}

// Function to get list of [ meta, [database_path,lineage_path] ]
def create_fastq_channel(LinkedHashMap row) {
    // create meta map
    def meta = [:]
    meta.database         = row.database

    // add path(s) of the fastq file(s) to the meta map
    def sourmash_meta = []

    if (!file(row.database_path).exists()) {
        exit 1, "ERROR: Please check input sourmash database CSV -> sourmash database does not exist!\n${row.database_path}"
    } else {
        sourmash_meta = [ meta, [file(row.database_path)]]
    }
    return sourmash_meta
}
