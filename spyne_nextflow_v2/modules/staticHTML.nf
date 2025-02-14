#!/usr/bin/env nextflow

/*
========================================================================================
   staticHTML module
========================================================================================
*/

nextflow.enable.dsl=2

process staticHTML {
    tag {"Creating static HTML output"}
    publishDir "${params.r}", mode: 'copy'

    input:
    val x

    output:
    path ("*"), emit: dash_json

    script:
    """
    python3 ${launchDir}/bin/static_report.py ${params.r}
    """
}
