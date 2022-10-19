/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    METAGENOMICS-SR WORKFLOW - QC, EVALUATION, AND ASSEMBLY OF METAGENOMIC SHORT READS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//
// NF-CORE MODULES installed with nf-core tools
//
include { FASTP                                  } from '../modules/nf-core/fastp/main'

// LOCAL MODULES
include { METASPADES                             } from '../modules/local/metaspades.nf'

//
// SUBWORKFLOWS
//
include { MAPPING_DEPTH                          } from '../subworkflows/local/mapping_depth.nf'

// TO help menu that prints for parameter options when adding those in for tools

// input reads parameters - TODO change to input check subworkflow later
ch_reads = Channel
    .fromFilePairs(params.input, size: params.single_end ? 1 : 2)
    .ifEmpty { exit 1, "Cannot find any reads matching: ${params.input}\nNB: Path needs to be enclosed in quotes!\nIf this is single-end data, please specify --single_end on the command line." }
            .map { row ->
                        def meta = [:]
                        meta.id           = row[0]
                        meta.group        = 0
                        meta.single_end   = params.single_end
                        return [ meta, row[1] ]
                }

// run the workflow

workflow METAGENOMICS_SR {
    ch_versions = Channel.empty()

    /*
    ================================================================================
                                    Read Preprocessing & QC
    ================================================================================
    */
    FASTP (
        ch_reads,
        params.fastp_save_trimmed_fail,
        []
    )
    ch_short_reads = FASTP.out.reads
    ch_versions = ch_versions.mix(FASTP.out.versions.first())
    /*
    ================================================================================
                                    Individual sample assembly with SPAdes
    ================================================================================
    */
    ch_assemblies = Channel.empty()
    ch_short_reads_metaspades = ch_short_reads
    METASPADES (
            ch_short_reads_spades.map { meta, fastq -> [ meta, fastq, [], [] ] },
            []
        )
        ch_metaspades_assemblies = METASPADES.out.scaffolds
            .map { meta, assembly ->
                def meta_new = meta.clone()
                meta_new.assembler  = "metaSPAdes"
                [ meta_new, assembly ]
            }
        ch_assemblies = ch_assemblies.mix(ch_metaspades_assemblies)
        ch_versions = ch_versions.mix(METASPADES.out.versions)

    /*
    ================================================================================
                                    Index, mapping, coverage calculations
                        mapping_depth.nf subworkflow with bowtie2, samtools, and jgisummarizecontigs
    ================================================================================
    */
    //
    MAPPING_DEPTH(
        ch_assemblies,
        ch_short_reads
    )
}
