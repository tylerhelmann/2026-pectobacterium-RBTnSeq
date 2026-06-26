### Identify orthogroups using OrthoFinder

Citation: Emms, D.M., Kelly, S. OrthoFinder: phylogenetic orthology inference for comparative genomics. Genome Biol 20, 238 (2019). https://doi.org/10.1186/s13059-019-1832-y

[https://github.com/OrthoFinder/OrthoFinder](https://github.com/OrthoFinder/OrthoFinder)

#### Download protein FASTAs using [ncbi-genome-download](https://github.com/kblin/ncbi-genome-download/)

[https://doi.org/10.5281/zenodo.8192432](https://doi.org/10.5281/zenodo.8192432)

~~~bash
pip install ncbi-genome-download

# Only "complete"/"chromosome" genomes
# Download date: 3/17/2026
ncbi-genome-download \
--genera Pectobacterium \
bacteria \
--assembly-levels complete,chromosome \
--formats protein-fasta \
--parallel 4 
~~~

-> 152 genomes downloaded into refseq/bacteria/

~~~bash
# Unzip all
gunzip refseq/bacteria/GCF*/*protein.faa.gz

# Copy all into a single folder
mkdir fasta
mv refseq/bacteria/*/*faa fasta/
rm -r refseq
~~~

Download NCBI RefSeq metadata

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

Rename from GCF* to strain name using metadata

~~~bash
# Write strainlist.txt and write/run rename strain shell script (Run from base directory)
Rscript ./src/save_rename_script.R
./src/rename_fasta.sh
~~~

#### Add additional Pectobacterium genomes

- *P. aroidearum* 61-19
- *P. brasiliense* 123-1 
- *P. parmentieri* NY1722A 
- *P. versatile* NY1715C 

~~~bash
for strain in $(ls ../additional_genomes/*protein.faa); do
	echo "Copying: ${strain}"
	cp $strain fasta/
done
~~~

-> 156 total genomes in fasta/

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

#### Optional: re-calculate to include *Dickeya dadantii* 3937, *D. dianthicola* ME23, and *D. dianthicola* 67-19 to orthogroup tables to allow for comparison to previous BarSeq work

- Dda3937 = GCF_000147055.1
- DdiaME23 = GCF_003403135.1
- Ddia67-19 = GCF_014893095.1

~~~bash
mkdir dickeya_fasta

wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/147/055/GCF_000147055.1_ASM14705v1/GCF_000147055.1_ASM14705v1_protein.faa.gz \
-O dickeya_fasta/Dickeya_dadantii_3937.protein.faa.gz
wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/003/403/135/GCF_003403135.1_ASM340313v1/GCF_003403135.1_ASM340313v1_protein.faa.gz \
-O dickeya_fasta/Dickeya_dianthicola_ME23.protein.faa.gz
wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/014/893/095/GCF_014893095.1_ASM1489309v1/GCF_014893095.1_ASM1489309v1_protein.faa.gz \
-O dickeya_fasta/Dickeya_dianthicola_67_19.protein.faa.gz

gunzip dickeya_fasta/*protein.faa.gz

mkdir fasta_both
cp fasta/* fasta_both
cp dickeya_fasta/* fasta_both

# orthofinder --assign dickeya_fasta --core results/Results_Mar18
orthofinder -f fasta_both -o results_both
~~~

Results: 

- [results+Dickeya/Orthogroups/Orthogroups.tsv](results+Dickeya/Orthogroups/Orthogroups.tsv)
- [results+Dickeya/Comparative\_Genomics\_Statistics/Statistics_Overall.tsv](results+Dickeya/Comparative_Genomics_Statistics/Statistics_Overall.tsv)



