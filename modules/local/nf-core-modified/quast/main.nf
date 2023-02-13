process QUAST {
    label 'process_medium'

    conda "bioconda::quast=5.2.0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/quast:5.2.0--py39pl5321h2add14b_1' :
        'quay.io/biocontainers/quast:5.2.0--py39pl5321h2add14b_1' }"

    // modified from nf-core module to output to generic QUAST directory and copy the report.tsv file

    input:
    path("*")

    output:
    path "QUAST/*", type: 'dir'     , emit: qc
    path '*.tsv'                    , emit: results
    path "versions.yml"             , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args   ?: ''

    """
    quast.py \\
        --output-dir QUAST \\
        *.fasta.gz \\
        --threads $task.cpus \\
        $args
    ln -s QUAST/report.tsv
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        quast: \$(quast.py --version 2>&1 | sed 's/^.*QUAST v//; s/ .*\$//')
    END_VERSIONS
    """
}
