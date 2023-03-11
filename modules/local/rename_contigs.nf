process RENAME_CONTIGS {
    tag "$meta.id"

    conda (params.enable_conda ? "conda-forge::python=3.8.3 conda-forge::biopython=1.75" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/biopython' :
        'quay.io/biocontainers/biopython:1.75' }"

    input:
    tuple val(meta), path(assembly)
    val assembler

    output:
    tuple val(meta), path ('*.reformatted.fasta.gz')       , emit: reformatted_assembly

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    rename_contigs.py --input $assembly --assembler $assembler --output ${prefix}.reformatted.fasta.gz
    """
}
