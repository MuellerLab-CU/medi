#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

params.additionalDbs = ["bacteria", "archaea", "human", "viral", "plasmid", "UniVec_Core"]
params.maxDbSize = 500
params.confidence = 0.3
params.threads = 20
params.rebuild = false
params.downloads = "${launchDir}/data"
params.out = "${launchDir}/data"
params.db = "${params.out}/medi_db"


workflow {
    if (!params.rebuild) {
        Channel.fromPath("${params.downloads}/sequences/*.fna.gz").set{food_sequences}
        setup_kraken_db()
        add_existing(setup_kraken_db.out, params.additionalDbs)
        add_sequences(food_sequences, add_existing.out.last())
        db = add_sequences.out.last()
    } else {
        db = Channel.fromPath(params.db)
    }

    build_kraken_db(db)
}


process setup_kraken_db {
    cpus 1
    memory "8 GB"

    // Add Nextflow's auto-retry
    errorStrategy 'retry'
    maxRetries 3

    output:
    path("medi_db")

    script:
    """
    kraken2-build --download-taxonomy --db medi_db --use-ftp
    """
}

process add_sequences {
    cpus 16
    memory "52 GB"
    publishDir params.out

    input:
    path(fasta)
    path(db)

    output:
    path("$db")

    script:
    """
    gunzip -c $fasta > ${fasta.baseName} && \
    kraken2-build --add-to-library ${fasta.baseName} --db $db --threads ${task.cpus} && \
    rm ${fasta.baseName}
    """
}

process add_existing {
    cpus 16
    memory "64 GB"

    input:
    path(db)
    each group

    output:
    path("$db")

    script:
    if (group == "human")
        """
        kraken2-build --download-library $group --db $db --no-mask --threads ${task.cpus} --use-ftp
        """
    else
        """
        kraken2-build --download-library $group --db $db --threads ${task.cpus} --use-ftp
        """
}

process build_kraken_db {
    cpus 32
    memory "${params.maxDbSize} GB"

    input:
    path(db)

    output:
    path("$db")

    script:
    """
    kraken2-build --build --db $db \
        --threads ${task.cpus} \
        --max-db-size ${(params.maxDbSize as BigInteger) * (1000G**3)}
    """
}
