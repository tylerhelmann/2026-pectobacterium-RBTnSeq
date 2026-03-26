

import pandas as pd

# Load metadata
seq_df = pd.read_csv("seqfiles.txt", sep="\t")

# Extract strains (skip header row, use 2nd column)
STRAINS = seq_df["Lib"].unique()

# Extract seqfile info
SEQFILES = [
    {
        "seqfile": row[0],
        "lib": row[1],
        "transposon": row[2],
        "name": row[0].replace(".fastq.gz", "")
    }
    for row in seq_df.values.tolist()
]

# Final outputs
rule all:
    input:
        expand("{lib}_data/ess_final.tsv", lib=STRAINS),
        expand("{lib}_data/{lib}.pool", lib=STRAINS),
        [f"{s['lib']}_data/{s['name']}-mapped.txt" for s in SEQFILES]

rule setup_org:
    input:
        gbff="{lib}.gbff"
    output:
        fna="{lib}_data/genome.fna",
        genes="{lib}_data/genes.tab"
    log:
        "{lib}_data/{lib}_setup.log"
    shell:
        "./feba/bin/SetupOrg.pl "
        "-gbk {input.gbff} "
        "-out {wildcards.lib}_data/ "
        "2>&1 | tee {log}"
        
# Mapping
rule map_reads:
    input:
        fna="{lib}_data/genome.fna",
        seqfile=lambda wildcards: next(
            s["seqfile"] for s in SEQFILES
            if s["name"] == wildcards.name and s["lib"] == wildcards.lib
        )
    output:
        mapped="{lib}_data/{name}-mapped.txt"
    log:
        "{lib}_data/{name}_log.txt"
    params:
        model=lambda wildcards: (
            "feba/primers/model_pKMW7.2"
            if next(s["transposon"] for s in SEQFILES if s["name"] == wildcards.name and s["lib"] == wildcards.lib) == "Tn5"
            else "feba/primers/model_pKMW3.2"
            if next(s["transposon"] for s in SEQFILES if s["name"] == wildcards.name and s["lib"] == wildcards.lib) == "Mariner"
            else "undefined"
        )
    shell:
        r"""
        if [ "{params.model}" = "undefined" ]; then
            echo "Transposon not recognized for {wildcards.lib} / {wildcards.name}";
            exit 1;
        fi

        ./feba/bin/MapTnSeq.pl \
            -genome {input.fna} \
            -model {params.model} \
            -first {input.seqfile} \
            > {output.mapped} \
            2> {log}
        """

# Construct poolfile per strain
rule design_pool:
    input:
        genes="{lib}_data/genes.tab",
        mapped=lambda wildcards: [
            f"{wildcards.lib}_data/{s['name']}-mapped.txt"
            for s in SEQFILES if s["lib"] == wildcards.lib
        ]
    params: minN=10
    output:
        pool="{lib}_data/{lib}.pool",
        stats="{lib}_data/{lib}.stats"
    shell:
        "./feba/bin/DesignRandomPool.pl "
        "-minN {params.minN} "
        "-genes {input.genes} "
        "-pool {output.pool} "
        "{input.mapped} "
        "2>&1 | tee {output.stats}"

rule essentiality:
    input:
        fna="{lib}_data/genome.fna",
        genes="{lib}_data/genes.tab",
        mapped=lambda wildcards: [
            f"{wildcards.lib}_data/{s['name']}-mapped.txt"
            for s in SEQFILES if s["lib"] == wildcards.lib
        ]
    output:
        ess="{lib}_data/ess"
    shell:
        "./feba/bin/Essentiality.pl "
        "-out {wildcards.lib}_data/ess "
        "-genome {input.fna} "
        "-genes {input.genes} "
        "{input.mapped} "
        "$blatShow"

# Generate the per-strain R script
rule rscript:
    input:
        gc="{lib}_data/genes.GC",
        essgenes="{lib}_data/ess.genes"
    output:
        script="{lib}_data/{lib}_analysis.R"
    shell:
        r"""
        cat > {output.script} <<'EOF'
        genes.GC <- read.delim(file = "{input.gc}")
        ess.genes <- read.delim(file = "{input.essgenes}")

        source("feba/lib/comb.R")

        ess <- Essentials(genes.GC, ess.genes, "")
        write.table(ess, file = "{wildcards.lib}_data/ess_final.tsv",
                    sep = "\t", row.names=FALSE)

        q()
        EOF
        """
        

# Run the R script to generate final essentiality results
rule run_r:
    input:
        script="{lib}_data/{lib}_analysis.R",
        ess="{lib}_data/ess"   # force dependency on essentiality
    output:
        result="{lib}_data/ess_final.tsv"
    shell:
        "Rscript {input.script}"

