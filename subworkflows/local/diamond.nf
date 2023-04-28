include { DIAMOND_MAKEDB                        } from '../../modules/nf-core/diamond/makedb/main'
include { DIAMOND_BLASTP                        } from '../../modules/nf-core/diamond/blastp/main'
include { MEGAN_DAA2INFO                        } from '../../modules/nf-core/megan/daa2info/main'


workflow DIAMOND_SUBWORKFLOW {
    take:
    protein_fasta
    

    main:


    emit:

}
