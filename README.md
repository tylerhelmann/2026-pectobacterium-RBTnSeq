# Scripts and data used in Helmann *et al.* 2026

#### Title: Comparative functional genomics of six *Pectobacterium* species reveals core and unique fitness determinants in potato tubers 

Abstract: *Pectobacterium*, a member of the soft rot Pectobacteriaceae (SRP), can cause highly destructive soft rot and blackleg diseases on many important crop and other host plants, particularly potato (*Solanum tuberosum*). *Pectobacterium* and its sister genus *Dickeya* have common virulence strategies, yet a highly diverse “open” pangenome containing many unique and hypothetical proteins. Here, we used randomly-barcoded transposon insertion-site sequencing (RB-TnSeq) on six *Pectobacterium* species to identify genes involved in bacterial survival and growth in potato tubers, as well as in minimal media conditions containing different single carbon sources. The strains evaluated varied broadly in genomic content as well as host plant and year of isolation. We focused on identifying genes important across all strains tested, as well as genes that were important in one or few of the tested strains. These results highlight the importance of many common genes involved in metabolism and maintaining cellular homeostasis, as well as shared and rare virulence traits including polygalacturonate catabolism, genes involved in polysaccharide biosynthesis, immunity proteins, and (for *P. brasiliense*) self-tolerance of the antibiotic carbapenem. This large dataset of conditionally essential genes, generated across *Pectobacterium* species during soft rot infection of the agriculturally important plant host potato, can serve as a rich mutagenesis dataset for further hypothesis generation and identification of important and/or novel in planta fitness factors.


Preprint: TBD

--

System used: Linux CentOS 7.6 (64 core server, 256 Gb RAM)

### Genome inputs

Strains included in this project:

- *P. aroidearum* 61-19
- *P. atrosepticum* SCRI1043 (GCF_000011605.1)
- *P. brasiliense* 123-1 
- *P. brasiliense* 1692 (GCF_009873295.1)
- *P. carotovorum* WPP14 (GCF_013488025.1)
- *P. parmentieri* NY1722A 
- *P. versatile* NY1715C 

### Download FEBA repository

Citation: [https://doi.org/10.1128/mbio.00306-15](https://doi.org/10.1128/mbio.00306-15)

Required for both TnSeq mapping (incl. essential gene predictions) and BarSeq analysis


~~~bash
git clone -q https://bitbucket.org/berkeleylab/feba.git

# genbank2gff.pl is only a link. 
# Delete the link and replace the file with:
# https://github.com/ihh/gfftools/blob/master/genbank2gff.pl

rm feba/bin/genbank2gff.pl
wget https://raw.githubusercontent.com/ihh/gfftools/master/genbank2gff.pl \
-O feba/bin/genbank2gff.pl
chmod +x feba/bin/genbank2gff.pl
~~~

### Mapping barcoded transposon libraries

Per-strain [library_mapping](library_mapping)

### Measuring genome-wide fitness *in vitro* and *in planta*

Per-strain experimental [fitness](fitness) calculations

### Identify orthologs using OrthoFinder

For *Pectobacterium* genomes, [identify_orthogroups](identify_orthogroups) using [OrthoFinder](https://github.com/OrthoFinder/OrthoFinder)

For the 7 Tn-lib strains here, use the "aaseq" protein fasta from FEBA SetupOrg.pl as input for OrthoFinder. This labels peptide sequence using the gene locusId, for easy joining of fitness - orthogroup.

### Combined fitness analysis

Join orthogroup matrix with BarSeq fitness tables and calculate mean fitness per condition

- [src/merge_fitness.R](src/merge_fitness.R)
	- [fitness/orthogroups\_long_locus.csv](fitness/orthogroups_long_locus.csv)
	- [fitness/merged_fitness.csv](fitness/merged_fitness.csv)
- [src/mean_fitness.R](src/mean_fitness.R)
	- [analysis/mean\_fit_Par6119.csv](analysis/mean_fit_Par6119.csv)
	- [analysis/mean\_fit_PatSCRI1043.csv](analysis/mean_fit_PatSCRI1043.csv)
	- [analysis/mean\_fit_Pbr123.csv](analysis/mean_fit_Pbr123.csv)
	- [analysis/mean\_fit_Pbr1692.csv](analysis/mean_fit_Pbr1692.csv)
	- [analysis/mean\_fit_PccWPP14.csv](analysis/mean_fit_PccWPP14.csv)
	- [analysis/mean\_fit_PpaNY1722A.csv](analysis/mean_fit_PpaNY1722A.csv)
	- [analysis/mean\_fit_PveNY1715C.csv](analysis/mean_fit_PveNY1715C.csv)

Calculate co-fitness networks at various correlation cutoffs

### Synteny analysis using clinker

<https://github.com/gamcil/clinker>

<https://doi.org/10.1093/bioinformatics/btab007>

~~~bash
pip install clinker
clinker analysis/genomic_regions/ankyrin/*gbk -p
~~~

Genome files:

[analysis/genomic_regions](analysis/genomic_regions)