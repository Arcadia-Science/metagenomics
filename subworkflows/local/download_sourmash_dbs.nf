process DOWNLOAD_SOURMASH_DBS {
    tag "gatherdb"
    label 'process_single'

    conda (params.enable_conda ? "anaconda::wget=1.20.1" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/wget:1.20.1' :
        'quay.io/biocontainers/wget:1.20.1' }"

    input:

    output:
    path '*.zip'       , emit: zips // contam db
    path "versions.yml", emit: versions

    script: //
    """
    # download databases provided with parameter, by default is TODO
    wget -O <DATABASES>

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        wget: \$(wget --version | grep '^GNU' | sed 's/GNU Wget //' | sed 's/ .*//')
    END_VERSIONS
    """
}
