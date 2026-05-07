## Fitness analysis

#### Set up snakemake wrapper

~~~
wget https://raw.githubusercontent.com/tylerhelmann/general-tools/refs/heads/main/feba/environment.yaml
wget https://raw.githubusercontent.com/tylerhelmann/general-tools/refs/heads/main/feba/Snakefile

source $HOME/miniconda3/bin/activate
# conda env create --name snakemake --file environment.yaml
# conda activate snakemake
~~~

#### Set up input files

Strains/libraries:

- Par6119
- Pat1043
- Pbr123
- Pbr1692
- PcWPP14
- Ppa1722A
- Pve1715C

Required:

- inputs/exp.tab

Required for each library:

- inputs/LIB.pool
- inputs/LIB_genes.GC

[inputs/](inputs/)

#### Run FEBA pipeline via snakemake for all strains, & samples

(Note: feba/ directory needs to be copied into fitness/ working directory for Snakefile to find)

~~~
# Snakemake dry run
snakemake --cores all -n
snakemake --dag | dot -Tpdf > dag.pdf

# Run full pipeline
snakemake --cores all
~~~

#### Results

Intermediate (per-set) results: [results/](results/)

Processed (per-strain) results: [html/](html)

[Pass QC summary?]