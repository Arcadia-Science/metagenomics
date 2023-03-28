process CHECK_SOURMASH_DBS {
    tag "$sourmash_dbs_csv"

    conda "conda-forge::python=3.9--1"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/python:3.9--1' :
        'quay.io/biocontainers/python:3.9--1' }"

    input:
    path sourmash_dbs_csv

    output:
    path '*.csv'       , emit: csv
    path "versions.yml" , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:

    """
    check_sourmash_dbs.py \\
        $sourmash_dbs_csv \\
        -o sourmash_dbs.valid.csv
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python --version | sed 's/Python //g')
    END_VERSIONS
    """
}
