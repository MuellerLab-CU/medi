#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

params.maxDbSize = 750
params.confidence = 0.3
params.downloads = "${launchDir}/data"
params.out = "${launchDir}/data"
params.db = "${params.out}/medi_db"


workflow {
    db = Channel.fromPath(params.db)
    self_classify(db)
    build_bracken(self_classify.out) | add_info
}

process self_classify {
    cpus 8               
    memory "${params.maxDbSize} GB"        

    input:
    path(db)

    output:
    path(db)

    script:
    """
    kraken2 --db ${db} --threads ${task.cpus} \
        --confidence ${params.confidence} \
        ${db}/library/*/*.f*a > ${db}/database.kraken
    """
}

process build_bracken {
    cpus 20
    memory "${params.maxDbSize} GB"
    publishDir params.out

    input:
    path(db)

    output:
    path("$db")

    script:
    """
    bracken-build -d $db -t ${task.cpus} -k 35 -l 100 && \
    bracken-build -d $db -t ${task.cpus} -k 35 -l 150
    """
}


process library {
    cpus 1
    memory "4 GB"

    input:
    path(db)

    output:
    path("$db/library/*/*.f*a")

    script:
    """
    ls ${db}/library/*/*.f*a | wc -l
    """
}

process add_info {
    cpus 1
    memory "1 GB"
    publishDir params.out

    input:
    path(db)

    output:
    path("$db")

    script:
    """
    cp ${params.downloads}/dbs/{food_matches.csv,food_contents.csv.gz} ${db}
    cp ${params.downloads}/manifest.csv ${db}
    """
}
