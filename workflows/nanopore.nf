/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    VALIDATE INPUTS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

def summary_params = NfcoreSchema.paramsSummaryMap(workflow, params)

// Validate input parameters

WorkflowMetagenomics.initialise(params, log)

// Check input path parameters to see if exist
def checkPathParamList = []
for (param in checkPathParamList) { if (param) { file(param, checkIfExists: true) } }

// Check mandatory parameters
if (params.input) { ch_input = file(params.input) } else { exit 1, 'Input samplesheet not specified!' }
if (params.sourmash_dbs) { ch_sourmash_dbs_csv = file(params.sourmash_dbs) } else { exit 1, 'Samplesheet CSV of sourmash DBs not specified!' }

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    CONFIG FILES
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
ch_multiqc_config                               = Channel.fromPath("$projectDir/assets/nanopore_multiqc_config.yml", checkIfExists: true)
ch_multiqc_custom_config                        = params.multiqc_config ? Channel.fromPath( params.multiqc_config, checkIfExists: true ) : Channel.empty()
ch_multiqc_logo                                 = params.multiqc_logo  ? Channel.fromPath( params.multiqc_logo, checkIfExists: true ): Channel.empty()
ch_multiqc_custom_methods_description           = params.multiqc_methods_description ? file(params.multiqc_methods_description, checkIfExists: true) : file("$projectDir/assets/nanopore_methods_description_template.yml", checkIfExists: true)

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT NF-CORE MODULES
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
include { PORECHOP_ABI                           } from '../modules/nf-core/porechop/abi/main'
include { FLYE                                   } from '../modules/nf-core/flye/main'
include { CUSTOM_DUMPSOFTWAREVERSIONS            } from '../modules/nf-core/custom/dumpsoftwareversions/main'
include { MULTIQC                                } from '../modules/nf-core/multiqc/main'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT LOCAL MODULES/SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
include { INPUT_CHECK                                    } from '../subworkflows/local/input_check'
include { MEDAKA                                         } from '../modules/local/nf-core-modified/medaka/main'
include { NANOPORE_MAPPING_DEPTH                         } from '../subworkflows/local/nanopore_mapping_depth'
include { RENAME_CONTIGS                                 } from '../modules/local/rename_contigs'
include { QUAST                                          } from '../modules/local/nf-core-modified/quast/main'
include { NANOPLOT                                       } from '../modules/local/nf-core-modified/nanoplot/main'
include { SOURMASH_PROFILING as SOURMASH_PROFILE_READS   } from '../subworkflows/local/sourmash_profiling'
include { SOURMASH_PROFILING as SOURMASH_PROFILE_ASSEMBS } from '../subworkflows/local/sourmash_profiling'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow NANOPORE {
    ch_versions = Channel.empty()

    // read in samplesheet
    INPUT_CHECK (
        ch_input
    )
    ch_versions = ch_versions.mix(INPUT_CHECK.out.versions)

    // stats on reads with nanoplot
    NANOPLOT (
        INPUT_CHECK.out.reads
    )
    ch_versions = ch_versions.mix(NANOPLOT.out.versions)

    // adapter removal with PORECHOP_ABI
    PORECHOP_ABI (
        INPUT_CHECK.out.reads
    )
    ch_reads = PORECHOP_ABI.out.reads
    ch_versions = ch_versions.mix(PORECHOP_ABI.out.versions)

    // assembly with flye
    FLYE (
        ch_reads,
        "--nano-hq"
    )
    ch_versions = ch_versions.mix(FLYE.out.versions)

    // rename contigs after assembly for cleaner downstream steps
    RENAME_CONTIGS (
        FLYE.out.fasta, "metaflye"
    )
    ch_reformatted_assemblies = RENAME_CONTIGS.out.reformatted_assembly

    // assembly QC with QUAST
    QUAST (
        ch_reformatted_assemblies.map{it -> it[1]}.collect() // aggregate assemblies together
    )

    // map reads to assembly with minimap2
    NANOPORE_MAPPING_DEPTH (
        ch_reformatted_assemblies,
        ch_reads
    )
    ch_versions = ch_versions.mix(NANOPORE_MAPPING_DEPTH.out.versions)

    // polishing with racon
    ch_medaka = ch_reads.join(ch_reformatted_assemblies)
    MEDAKA (
        ch_medaka
    )
    ch_versions = ch_versions.mix(MEDAKA.out.versions)

    // sourmash profiling subworkflow for reads
    SOURMASH_PROFILE_READS (
        ch_reads,
        "reads",
        ch_sourmash_dbs_csv
    )

    // sourmash profiling subworkflow for assemblies
    SOURMASH_PROFILE_ASSEMBS (
        ch_reformatted_assemblies,
        "assembly",
        ch_sourmash_dbs_csv
    )
    ch_versions = ch_versions.mix(SOURMASH_PROFILE_ASSEMBS.out.versions)

    // dump software versions
    CUSTOM_DUMPSOFTWAREVERSIONS (
        ch_versions.unique().collectFile(name: 'collated_versions.yml')
    )

    // multiqc reporting
    workflow_summary = WorkflowMetagenomics.paramsSummaryMultiqc(workflow, summary_params)
    ch_workflow_summary = Channel.value(workflow_summary)

    ch_multiqc_files = Channel.empty()
    ch_multiqc_files = ch_multiqc_files.mix(ch_workflow_summary.collectFile(name: 'workflow_summary_mqc.yaml'))
    ch_multiqc_files = ch_multiqc_files.mix(CUSTOM_DUMPSOFTWAREVERSIONS.out.mqc_yml.collect())
    ch_multiqc_files = ch_multiqc_files.mix(NANOPLOT.out.txt.collect().ifEmpty([]))
    ch_multiqc_files = ch_multiqc_files.mix(QUAST.out.results.collect().ifEmpty([]))
    ch_multiqc_files = ch_multiqc_files.mix(NANOPORE_MAPPING_DEPTH.out.ch_stats.collect().ifEmpty([]))

    MULTIQC(
        ch_multiqc_files.collect(),
        ch_multiqc_config.collect().ifEmpty([]),
        ch_multiqc_custom_config.collect().ifEmpty([]),
        ch_multiqc_logo.collect().ifEmpty([])
    )
    multiqc_report = MULTIQC.out.report.toList()
    ch_versions = ch_versions.mix(MULTIQC.out.versions)
}
