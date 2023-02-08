process MINIMAP2_ALIGN {
    tag "$meta.id"
    label 'process_medium'

    // modified with output to just SAM and not requiring the options for output to BAM/PAF, also requires tuple input for the index reference

    // Note: the versions here need to match the versions used in the mulled container below and minimap2/index
    conda "bioconda::minimap2=2.24 bioconda::samtools=1.14"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/mulled-v2-66534bcbb7031a148b13e2ad42583020b9cd25c4:1679e915ddb9d6b4abda91880c4b48857d471bd8-0' :
        'quay.io/biocontainers/mulled-v2-66534bcbb7031a148b13e2ad42583020b9cd25c4:1679e915ddb9d6b4abda91880c4b48857d471bd8-0' }"

    input:
    tuple val(meta), path(reads)
    tuple val(index_meta), path(index)

    output:
    tuple val(meta), path("*.sam"),             emit: sam
    tuple val(meta), path("*.sorted.bam"),      emit: sorted_bam
    tuple val(meta), path("*.bam.bai"),         emit: indexed_bam
    path "versions.yml",                        emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    minimap2 \\
        $args \\
        -t $task.cpus \\
        $index \\
        $reads > ${prefix}.sam
    samtools view -@ $task.cpus -bS ${prefix}.sam | samtools sort -@ $task.cpus -o ${prefix}.sorted.bam
    samtools index ${prefix}.sorted.bam ${prefix}.bam.bai


    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        minimap2: \$(minimap2 --version 2>&1)
    END_VERSIONS
    """
}
