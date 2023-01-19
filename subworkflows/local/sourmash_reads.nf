// sourmash sketch, compare, taxonomy on reads

include { SOURMASH_SKETCH           } from '../modules/nf-core/sourmash/sketch/main'
include { SOURMASH_COMPARE          } from '../modules/nf-core/sourmash/compare/main'
include { SOURMASH_GATHER           } from '../modules/nf-core/sourmash/gather/main'


workflow SOURMASH_READS {
    take:
    reads

    main:
    ch_versions = Channel.empty()

    // create signature of reads
    SOURMASH_SKETCH (reads)
    ch_versions = ch_versions.mix(SOURMASH_SKETCH.out.versions)

    

}
