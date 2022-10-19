// similar to nf-core/mag spades local module: https://github.com/nf-core/mag/blob/master/modules/local/spades.nf except with newer version of spades and only emits gzipped versions of assemblies

process METASPADES {
    tag "$meta.id"

    conda (params.enable_conda ? 'bioconda::spades=3.15.4' : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/spades:3.15.4--h95f258a_0' :
        'quay.io/biocontainers/spades:3.15.4--h95f258a_0' }"

    input:
    tuple val(meta), path(reads)

    output:

    tuple val(meta), path("metaSPAdes-${meta.id}_scaffolds.fasta.gz"), emit: assembly
    path "metaSPAdes-${meta.id}_contigs.fasta.gz", emit: contigs
    path "metaSPAdes-${meta.id}_graph.gfa.gz", emit: graph
    path "metaSPAdes-${meta.id}.log", emit: log
    path "versions.yml", emit: versions

    script:
    def args = task.ext.args ?: ''
    maxmem = task.memory.toGiga() //dynamically change memory requirements
    if (params.spades_fix_cpus == -1 || task.cpus == params.spades_fix_cpus) //control cpus or dynamically change

        """
        metaspades.py \
            $args \
            --threads "${task.cpus}" \
            --memory $maxmem \
            --pe1-1 ${reads[0]} \
            --pe1-2 ${reads[1]} \
            -o spades
        mv spades/assembly_graph_with_scaffolds.gfa metaSPAdes-${meta.id}_graph.gfa
        mv spades/scaffolds.fasta metaSPAdes-${meta.id}_scaffolds.fasta
        mv spades/contigs.fasta metaSPAdes-${meta.id}_contigs.fasta
        mv spades/spades.log metaSPAdes-${meta.id}.log
        gzip "metaSPAdes-${meta.id}_contigs.fasta"
        gzip "metaSPAdes-${meta.id}_scaffolds.fasta"

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            python: \$(python --version 2>&1 | sed 's/Python //g')
            metaspades: \$(metaspades.py --version | sed 's/SPAdes genome assembler v//; s/ \\[.*//')
        END_VERSIONS
        """




}
