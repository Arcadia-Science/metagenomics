// Influenced by https://github.dev/nf-core/mag but modified output of index
process BOWTIE2_ASSEMBLY_BUILD {
    tag "${meta.id}"
    label 'process_medium'

    conda (params.enable_conda ? 'bioconda::bowtie2=2.4.2' : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/bowtie2:2.4.2--py38h1c8e9b9_1' :
        'quay.io/biocontainers/bowtie2:2.4.2--py38h1c8e9b9_1' }"

    input:
    tuple val(meta), path(assembly)

    output:
    tuple val(meta), path('*bt2_index_base*')               , emit: index
    path "versions.yml"                                     , emit: versions

    script:
    def args = task.ext.args ?: ''
    """
    mkdir bowtie
    bowtie2-build --threads $task.cpus $assembly "${assembly.baseName}-bt2_index_base"
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bowtie2: \$(echo \$(bowtie2 --version 2>&1) | sed 's/^.*bowtie2-align-s version //; s/ .*\$//')
    END_VERSIONS
    """
}
