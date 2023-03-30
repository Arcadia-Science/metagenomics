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
if (params.sourmash_dbs) { ch_sourmash_dbs_csv = file(params.sourmash_dbs) } else { exit 1, 'CSV file of sourmash databases and lineage files not provided!' }

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    CONFIG FILES
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
ch_multiqc_config                               = Channel.fromPath("$projectDir/assets/illumina_multiqc_config.yml", checkIfExists: true)
ch_multiqc_custom_config                        = params.multiqc_config ? Channel.fromPath( params.multiqc_config, checkIfExists: true ) : Channel.empty()
ch_multiqc_logo                                 = params.multiqc_logo  ? Channel.fromPath( params.multiqc_logo, checkIfExists: true ): Channel.empty()
ch_multiqc_custom_methods_description           = params.multiqc_methods_description ? file(params.multiqc_methods_description, checkIfExists: true) : file("$projectDir/assets/illumina_methods_description_template.yml", checkIfExists: true)

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT NF-CORE MODULES
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
include { FASTP                                  } from '../modules/nf-core/fastp/main'
include { CUSTOM_DUMPSOFTWAREVERSIONS            } from '../modules/nf-core/custom/dumpsoftwareversions/main'
include { MULTIQC                                } from '../modules/nf-core/multiqc/main'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT LOCAL MODULES/SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
include { METASPADES                                      } from '../modules/local/metaspades'
include { ILLUMINA_MAPPING_DEPTH                          } from '../subworkflows/local/illumina_mapping_depth'
include { INPUT_CHECK                                     } from '../subworkflows/local/input_check'
include { RENAME_CONTIGS                                  } from '../modules/local/rename_contigs'
include { QUAST                                           } from '../modules/local/nf-core-modified/quast/main'
include { SOURMASH_PROFILING as SOURMASH_PROFILE_READS    } from '../subworkflows/local/sourmash_profiling'
include { SOURMASH_PROFILING as SOURMASH_PROFILE_ASSEMBS  } from '../subworkflows/local/sourmash_profiling'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow ILLUMINA {
    ch_versions = Channel.empty()

    // read in samplesheet
    INPUT_CHECK (
        ch_input
    )
    ch_versions = ch_versions.mix(INPUT_CHECK.out.versions)

    // read preprocessing and QC with fastp
    FASTP (
        INPUT_CHECK.out.reads,
        params.fastp_save_trimmed_fail,
        []
    )
    ch_short_reads = FASTP.out.reads
    ch_versions = ch_versions.mix(FASTP.out.versions.first())

    // individual sample assembly with metaspades
    ch_assemblies = Channel.empty()
    METASPADES (
        ch_short_reads
    )
    ch_assemblies = METASPADES.out.assembly
    ch_versions = ch_versions.mix(METASPADES.out.versions)

    // rename contigs after assembly for cleaner downstream steps
    RENAME_CONTIGS (
        ch_assemblies, "metaspades"
    )
    ch_reformatted_assemblies = RENAME_CONTIGS.out.reformatted_assembly

    // run QUAST on reformatted assemblies for stats
    QUAST (
        ch_reformatted_assemblies.map{it -> it[1]}.collect() // aggregate assemblies together
    )
    ch_versions = ch_versions.mix(QUAST.out.versions)

    // map reads to corresponding assembly and calculate depth with local subworkflow
    ILLUMINA_MAPPING_DEPTH (
        ch_reformatted_assemblies,
        ch_short_reads
    )
    ch_versions = ch_versions.mix(ILLUMINA_MAPPING_DEPTH.out.versions)

    // sourmash profiling subworkflow for reads
    SOURMASH_PROFILE_READS (
        ch_short_reads,
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
    ch_multiqc_files = ch_multiqc_files.mix(QUAST.out.results.collect().ifEmpty([]))
    ch_multiqc_files = ch_multiqc_files.mix(FASTP.out.json.collect{it[1]}.ifEmpty([]))
    ch_multiqc_files = ch_multiqc_files.mix(ILLUMINA_MAPPING_DEPTH.out.ch_stats.collect().ifEmpty([]))

    MULTIQC(
        ch_multiqc_files.collect(),
        ch_multiqc_config.collect().ifEmpty([]),
        ch_multiqc_custom_config.collect().ifEmpty([]),
        ch_multiqc_logo.collect().ifEmpty([])
    )
    multiqc_report = MULTIQC.out.report.toList()
    ch_versions = ch_versions.mix(MULTIQC.out.versions)
}
