process NANOPLOT {
    tag "$meta.id"
    label 'process_low'

    // modified by explicitly passing a fastq argument in the nanopore modules config because will fail if the file is .fq.gz with default, so I'm forcing fastq
    // also modifications for outputs to play nice with what multiqc expects from the NanoStats.txt file for each fastq file

    conda "bioconda::nanoplot=1.41.0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/nanoplot:1.41.0--pyhdfd78af_0' :
        'quay.io/biocontainers/nanoplot:1.41.0--pyhdfd78af_0' }"

    input:
    tuple val(meta), path(ontfile)

    output:
    path "${prefix}", type: 'dir'                  , emit: qc
    path("*.txt")                                  , emit: txt
    path  "versions.yml"                           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    prefix = task.ext.prefix ?: "${meta.id}"
    """
    NanoPlot \\
        $args $ontfile \\
        -t $task.cpus -o $prefix
    mv ${prefix}/NanoStats.txt ${prefix}_nanoplot_stats.txt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        nanoplot: \$(echo \$(NanoPlot --version 2>&1) | sed 's/^.*NanoPlot //; s/ .*\$//')
    END_VERSIONS
    """
}
