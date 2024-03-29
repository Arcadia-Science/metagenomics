process SOURMASH_TAXANNOTATE {
    tag "$meta.id"
    label 'process_single'
    // added seqtype and updated sourmash version

    conda "bioconda::sourmash=4.6.1"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/sourmash:4.6.1--hdfd78af_0':
        'quay.io/biocontainers/sourmash:4.6.1--hdfd78af_0' }"

    input:
    tuple val(meta), path(gather_results), path(taxonomies) // latter can take paths to multiple taxonomy CSVs to run all together against a gather result CSV
    val seqtype

    output:
    tuple val(meta), path("*.with-lineages.csv.gz"), emit: result
    path "versions.yml"                            , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    """
    sourmash \\
        tax annotate \
        $args \\
        --gather-csv ${gather_results} \\
        --taxonomy ${taxonomies} \\
        --output-dir "."

    ## Compress output
    gzip --no-name *.with-lineages.csv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        sourmash: \$(echo \$(sourmash --version 2>&1) | sed 's/^sourmash //' )
    END_VERSIONS
    """
}
