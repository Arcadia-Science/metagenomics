// similar to nf-core/mag spades local module: https://github.com/nf-core/mag/blob/master/modules/local/spades.nf except with newer version of spades and only emits gzipped versions of assemblies

process METASPADES {
    tag "$meta.id"

    conda (params.enable_conda ? "bioconda::spades=3.15.3" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/spades:3.15.3--h95f258a_0' :
        'quay.io/biocontainers/spades:3.15.3--h95f258a_0' }"

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path("metaspades-${meta.id}_scaffolds.fasta"), emit: assembly
    path "metaspades-${meta.id}.log"                              , emit: log
    path "metaspades-${meta.id}_contigs.fasta.gz"                 , emit: contigs_gz
    path "metaspades-${meta.id}_scaffolds.fasta.gz"               , emit: assembly_gz
    path "metaspades-${meta.id}_graph.gfa.gz"                     , emit: graph
    path "versions.yml"                                , emit: versions

    script:
    def args = task.ext.args ?: ''
    maxmem = task.memory.toGiga()
    if ( params.metaspades_fix_cpus == -1 || task.cpus == params.metaspades_fix_cpus )
        """
        metaspades.py \
            $args \
            --threads "${task.cpus}" \
            --memory $maxmem \
            --pe1-1 ${reads[0]} \
            --pe1-2 ${reads[1]} \
            -o metaspades
        mv metaspades/assembly_graph_with_scaffolds.gfa metaspades-${meta.id}_graph.gfa
        mv metaspades/scaffolds.fasta metaspades-${meta.id}_scaffolds.fasta
        mv metaspades/contigs.fasta metaspades-${meta.id}_contigs.fasta
        mv metaspades/spades.log metaspades-${meta.id}.log
        gzip "metaspades-${meta.id}_contigs.fasta"
        gzip "metaspades-${meta.id}_graph.gfa"
        gzip -c "metaspades-${meta.id}_scaffolds.fasta" > "metaspades-${meta.id}_scaffolds.fasta.gz"
        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            python: \$(python --version 2>&1 | sed 's/Python //g')
            metaspades: \$(metaspades.py --version | sed "s/SPAdes genome assembler v//; s/ \\[.*//")
        END_VERSIONS
        """
    else
        error "ERROR: '--metaspades_fix_cpus' was specified, but not succesfully applied. Likely this is caused by changed process properties in a custom config file."
}
