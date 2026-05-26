## Mapping RB-TnSeq libraries in *Pectobacterium* spp

Strains: 

| Strain | Accession | Transposon Used 
| --- | --- | --- 
|*P. aroidearum* 61-19 | Unpublished | Tn5
|*P. atrosepticum* SCRI1043 | GCF_000011605.1 | Mariner
|*P. brasiliense* 123-1 | Unpublished | Mariner
|*P. brasiliense* 1692 | GCF_009873295.1 | Mariner
|*P. carotovorum* WPP14 | GCF_013488025.1 | Mariner
|*P. parmentieri* NY1722A | Unpublished* | Tn5
|*P. versatile* NY1715C | Unpublished** | Mariner

*Older contig assembly (not used): WABU00000000.1 

**Older contig assembly (not used): GCF_018095745.1 

[strain_metadata.txt](strain_metadata.txt)

System used: Linux CentOS 7.6 (40 core server, 256 Gb RAM)

#### Download strains

~~~
for lib in $(cat strain_metadata.txt | cut -f 2 | sed 1d)
do
	download_link=$(grep $lib strain_metadata.txt | cut -f 4)
	wget $download_link -O ${lib}.gbff.gz
done
gunzip *gbff.gz
~~~

Copy custom gbff files from unpublished assemblies (N=4):

- [Par6119.gbff](../additional_genomes/Pectobacterium_aroidearum_61-19.gbff)
- [Pbr123.gbff](../additional_genomes/Pectobacterium_brasiliense_123-1.gbff)
- [Ppa1722A.gbff](../additional_genomes/Pectobacterium_parmentieri_NY1722A.gbff)
- [Pve1715C.gbff](../additional_genomes/Pectobacterium_versatile_NY1715C.gbff)

#### Set up strains for FEBA pipeline

~~~
for lib in $(cat strain_metadata.txt | cut -f 2 | sed 1d)
do
	../feba/bin/SetupOrg.pl -gbk ${lib}.gbff \
	-out ${lib}_data/ \
	2>&1 | tee ${lib}_data/${lib}_setup.log 
done
~~~

#### Map reads

All mapping data: [seqfiles.txt](seqfiles.txt)

>model\_pKMW3.2 for pKMW3-based Mariner libraries  
>model\_pKMW7.2 for pKMW7-based Tn5 libraries

~~~
for seqfile in $(cat seqfiles.txt | cut -f 1 | sed 1d); 
do
	lib=$(grep $seqfile seqfiles.txt | cut -f 2)
	transposon=$(grep ${seqfile} seqfiles.txt | cut -f 3)
	name=$(echo $seqfile | sed 's/.fastq.gz//g')
	
	if [[ $transposon == "Tn5" ]]; then
		model="../feba/primers/model_pKMW7.2"
	elif [[ $transposon == "Mariner" ]]; then
		model="../feba/primers/model_pKMW3.2"
	else
		echo "Transposon not recognized"
	fi
	
	../feba/bin/MapTnSeq.pl \
	-genome ${lib}_data/genome.fna \
	-model $model \
	-first input/$seqfile \
	> ${lib}_data/${name}-mapped.txt \
	2> ${lib}_data/${name}_log.txt &
done
~~~

#### Assemble pool

~~~
# Fix feba/lib/PoolStats.R shebang line. 
# For me needs to be: #!/usr/bin/env Rscript

for lib in $(cat strain_metadata.txt | cut -f 2 | sed 1d)
do
	../feba/bin/DesignRandomPool.pl \
	-minN 10 \
	-genes ${lib}_data/genes.tab \
	-pool ${lib}_data/${lib}.pool \
	${lib}_data/*-mapped.txt \
	2>&1 | tee ${lib}_data/${lib}.stats &
done
~~~

Save pool results into fitness/inputs/ 

Library sizes:

Strain | Insertions in genome 
---|---
Par6119 | 359,157
Pat1043| 240,722
Pbr123| 388,212
Pbr1692| 185,037
PcWPP14| 284,613
Ppa1722A | 586,547
Pve1715C| 511,350

#### Essential gene prediction

~~~
for lib in $(cat strain_metadata.txt | cut -f 2 | sed 1d)
do
	../feba/bin/Essentiality.pl \
	-out ${lib}_data/ess \
	-genome ${lib}_data/genome.fna \
	-genes ${lib}_data/genes.tab \
	${lib}_data/*-mapped.txt \
	$blatShow
done
~~~

Generate R script for each strain: 

~~~ 
for lib in $(cat strain_metadata.txt | cut -f 2 | sed 1d)
do
	echo "genes.GC <- read.delim(file = \"${lib}_data/genes.GC\")"
	echo "ess.genes <- read.delim(file = \"${lib}_data/ess.genes\")"
	
	echo "ess <- Essentials(genes.GC, ess.genes, \"\")"
	echo "write.table(ess, file = \"${lib}_data/ess\", sep = \"\t\", row.names=F)"
done
~~~

~~~
# Copy and run all commands in R

# Load FEBA script comb.R.
source("feba/lib/comb.R")

# Exit R shell. Do not save workspace image. 
q()
~~~

Note minimum gene length:

- Par6119: Chose length  150 minimum fp rate 0.01791984 
- Pat1043: Chose length  175 minimum fp rate 0.01505863 
- Pbr123: Chose length  125 minimum fp rate 0.01432493 
- Pbr1692: Chose length  225 minimum fp rate 0.01421111 
- PcWPP14: Chose length  175 minimum fp rate 0.01292093 
- Ppa1722A: Chose length  100 minimum fp rate 0.00255386 
- Pve1715C: Chose length  100 minimum fp rate 0.002569061 

Save results into library_mapping/ess/ 


### Predicted essential genes per mapped library

Strain | Essential | Not (or too short)
---|---|---
Par6119|376|3841
Pat1043|315|3985
Pbr123|332|3764
Pbr1692|357|3738
PcWPP14|342|3732
Ppa1722A|399|3985
Pve1715C|327|4255



