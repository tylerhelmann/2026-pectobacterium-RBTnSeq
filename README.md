# Scripts and data used in Helmann *et al.* 2026

Preprint: TBD

Abstract:

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

Join orthogroup matrix with BarSeq fitness tables

- [src/merge_fitness.R](src/merge_fitness.R)
- Saves: [fitness/orthogroups\_long_locus.csv](fitness/orthogroups_long_locus.csv); [fitness/merged_fitness.csv](fitness/merged_fitness.csv)

Calculate co-fitness networks at various correlation cutoffs