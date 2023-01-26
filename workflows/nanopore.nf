/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    VALIDATE INPUTS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

def summary_params = NfcoreSchema.paramsSummaryMap(workflow, params)

// Validate input parameters

WorkflowMetagenomics.initialise(params, log)

// Check input path parameters to see if exist
def checkPathParamList = [ params.input ]
for (param in checkPathParamList) { if (param) { file(param, checkIfExists: true) } }

// Check mandatory parameters
if (params.input) { ch_input = file(params.input) } else { exit 1, 'Input samplesheet not specified!' }

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT NF-CORE MODULES
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
include { PORECHOP_ABI                           } from '../modules/nf-core/porechop/abi/main'
include { FLYE                                   } from '../modules/nf-core/flye/main'
include { RACON                                  } from '../modules/nf-core-modified/racon/main'
include { CUSTOM_DUMPSOFTWAREVERSIONS            } from '../modules/nf-core/custom/dumpsoftwareversions/main'


/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT LOCAL MODULES/SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
include { INPUT_CHECK                            } from '../subworkflows/local/input_check'
include { MINIMAP2_SUBWORKFLOW                   } from '../subworkflows/local/minimap2_subworkflow'

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

    // adapter removal with PORECHOP_ABI
    PORECHOP_ABI (
        INPUT_CHECK.out.reads
    )
    ch_versions = ch_versions.mix(PORECHOP_ABI.out.versions)

    // assembly with flye
    FLYE (
        PORECHOP_ABI.out.reads,
        "--nano-hq"
    )
    ch_versions = ch_versions.mix(FLYE.out.versions)

    // map reads to assembly with minimap2
    MINIMAP2_SUBWORKFLOW (
        FLYE.out.fasta,
        PORECHOP_ABI.out.reads
    )
    ch_versions = ch_versions.mix(MINIMAP2_SUBWORKFLOW.out.versions)

    // polishing with racon
    RACON (
        PORECHOP_ABI.out.reads,
        FLYE.out.fasta,
        MINIMAP2_SUBWORKFLOW.out.ch_align_sam
    )
    ch_versions = ch_versions.mix(RACON.out.versions)

    // dump software versions
    CUSTOM_DUMPSOFTWAREVERSIONS (
        ch_versions.unique().collectFile(name: 'collated_versions.yml')
    )
}
