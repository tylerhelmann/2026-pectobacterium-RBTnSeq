### Identify orthogroups using OrthoFinder

Citation: Emms, D.M., Kelly, S. OrthoFinder: phylogenetic orthology inference for comparative genomics. Genome Biol 20, 238 (2019). https://doi.org/10.1186/s13059-019-1832-y

[https://github.com/OrthoFinder/OrthoFinder](https://github.com/OrthoFinder/OrthoFinder)

#### Download protein FASTAs using ncbi datasets

<https://www.ncbi.nlm.nih.gov/datasets/docs/v2/command-line-tools/download-and-install/>

~~~bash
# Download
curl -o datasets 'https://ftp.ncbi.nlm.nih.gov/pub/datasets/command-line/v2/linux-amd64/datasets'
chmod +x datasets dataformat

# Only "complete"/"chromosome" genomes
# Download date: 7/7/2026
./datasets download genome taxon Pectobacterium \
--assembly-level complete,chromosome \
--include protein 
~~~

Unzip -> 311 genomes downloaded into ncbi_dataset/data/ (mix of RefSeq and Genbank)

Download NCBI RefSeq metadata: 152 genomes

~~~bash
# Download NCBI RefSeq genome metadata
wget ftp://ftp.ncbi.nlm.nih.gov/genomes/refseq/bacteria/assembly_summary.txt \
-O ncbi_metadata.txt

# Extract header.
head -n 2 ncbi_metadata.txt | tail -n 1 | \
sed 's/#//' > ncbi_header.txt

# Extract Pectobacterium data; all "complete" and "chromosome" assemblies
grep Pectobacterium ncbi_metadata.txt | grep -E "Complete|Chromosome" > ncbi_pecto_temp.txt

# Combine.
cat ncbi_header.txt ncbi_pecto_temp.txt \
> ncbi_pecto.txt

# Clean up.
rm ncbi_metadata.txt ncbi_header.txt ncbi_pecto_temp.txt
~~~

Rename from GCF*protein.faa to strain name using metadata

~~~bash
mkdir fasta

# Write strainlist.txt and write/run rename strain shell script (Run from base directory)
Rscript ./src/save_rename_script.R
./src/rename_fasta.sh
~~~

#### Add additional Pectobacterium genomes

- *P. aroidearum* 61-19
- *P. brasiliense* 123-1 
- *P. parmentieri* NY1722A 
- *P. versatile* NY1715C 

For 7 strains, use amino acid fastas generated from RB-TnSeq FEBA pipeline SetupOrg.pl ("aaseq" file)

-> 156 total genomes in fasta/

~~~
cp ${lib}_data/aaseq fasta/${strain}.protein.faa
~~~

#### Run OrthoFinder

OrthoFinder:v3.1.3

~~~bash
# software pre-installed in BioHPC Cloud
source /programs/miniconda3.1/bin/activate orthofinder

orthofinder -f fasta -o results
~~~

Results: 

- [results/Orthogroups/Orthogroups.tsv](results/Orthogroups/Orthogroups.tsv)
- [results/Comparative\_Genomics\_Statistics/Statistics_Overall.tsv](results/Comparative_Genomics_Statistics/Statistics_Overall.tsv)

--


