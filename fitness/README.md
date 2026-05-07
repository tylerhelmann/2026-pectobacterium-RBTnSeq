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

(Note: no strainusage files used here, so comment out that requirement:
strainusage=expand("results/{{lib}}/strainusage.{ext}", ext = ["barcodes", "genes", "genes12"]))

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

- Fitness values for passQC samples: html/{Strain}/fit\_logratios_good.tab
- Summary of experimental QC metrics: html/{Strain}/fit_quality.tab

#### Save strainusage files for future use

See: <https://bitbucket.org/berkeleylab/feba/src/master/bin/SaveStrainUsage.pl>

Usage: SaveStrainUsage.pl [ -org organism ] [ -fit html/organism ] [ -out g/organism ]

~~~bash
for strain in $(ls html/); do
../feba/bin/SaveStrainUsage.pl -org ${strain} \
-fit html/${strain} -out html/${strain}
done
~~~

~~~
Wrote strain usage to html/Par6119/strainusage.*
Wrote strain usage to html/Pat1043/strainusage.*
Wrote strain usage to html/Pbr123/strainusage.*
Wrote strain usage to html/Pbr1692/strainusage.*
Wrote strain usage to html/PcWPP14/strainusage.*
Wrote strain usage to html/Ppa1722A/strainusage.*
Wrote strain usage to html/Pve1715C/strainusage.*
~~~