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

#### CheckM filter

~~~bash
export PATH=/programs/hmmer/bin:$PATH
export PATH=/programs/prodigal-2.6.3:$PATH
export PATH=/programs/pplacer-Linux-v1.1.alpha19:$PATH
export PATH=/programs/checkm-1.2.4/bin:$PATH
export PYTHONPATH=/programs/checkm-1.2.4/lib/python3.9/site-packages

checkm lineage_wf --genes -t 16 -x faa fasta/ checkm_test/ --tmpdir .

# Marker: Enterobacteriaceae
~~~

Remove outlier: Pectobacterium\_sp_A5354, completeness = 90.43

All others, completeness >94% and contamination ≤1%

#### Run OrthoFinder

OrthoFinder:v3.1.3

~~~bash
rm fasta/Pectobacterium_sp_A5354.protein.faa
# N = 155 total genomes

# software pre-installed in BioHPC Cloud
source /programs/miniconda3.1/bin/activate orthofinder

orthofinder -f fasta -o results
~~~

Results: 

- [results/Orthogroups/Orthogroups.tsv](results/Orthogroups/Orthogroups.tsv)
- [results/Orthogroups/Orthogroups_UnassignedGenes.tsv](results/Orthogroups/Orthogroups_UnassignedGenes.tsv)
- [results/Comparative\_Genomics\_Statistics/Statistics_Overall.tsv](results/Comparative_Genomics_Statistics/Statistics_Overall.tsv)

#### Combine orthogroups with unassigned (unique) proteins, and subset to Tn-lib strains

~~~r
library(dplyr)
library(tidyr)

og <- read.delim("results/Orthogroups/Orthogroups.tsv")
unassigned <- read.delim("results/Orthogroups/Orthogroups_UnassignedGenes.tsv")

og_all <- rbind(og, unassigned)

og_subset <- og_all %>% 
  rename("Par6119" = "Pectobacterium_aroidearum_6119.protein",
         "PatSCRI1043" = "Pectobacterium_atrosepticum_SCRI1043.protein",
         "Pbr123" = "Pectobacterium_brasiliense_123.1.protein",
         "Pbr1692" = "Pectobacterium_brasiliense_1692.protein",
         "PccWPP14" = "Pectobacterium_carotovorum_WPP14.protein",
         "PpaNY1722A" = "Pectobacterium_parmentieri_NY1722A.protein",
         "PveNY1715C" = "Pectobacterium_versatile_NY1715C.protein") %>%
  select("Orthogroup", "Par6119", "PatSCRI1043", "Pbr123", "Pbr1692",
         "PccWPP14", "PpaNY1722A", "PveNY1715C") %>%
  separate_rows("Par6119", sep = ", ") %>%
  separate_rows("PatSCRI1043", sep = ", ") %>%
  separate_rows("Pbr123", sep = ", ") %>%
  separate_rows("Pbr1692", sep = ", ") %>%
  separate_rows("PccWPP14", sep = ", ") %>%
  separate_rows("PpaNY1722A", sep = ", ") %>%
  separate_rows("PveNY1715C", sep = ", ") %>%
  filter(if_any(-Orthogroup, ~ !is.na(.)))
  
# Save
write.csv(og_subset, "results/Orthogroups/Orthogroups_subset.csv", row.names=F, quote=F)
~~~

