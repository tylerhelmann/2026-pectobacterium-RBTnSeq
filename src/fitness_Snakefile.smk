
from os import path
import pandas as pd

sample_metadata = pd.read_table("inputs/exp.tab")

ALL_LIBRARIES = sample_metadata["Mutant.Library"].unique()
ALL_SETS = sample_metadata["SetName"].unique()

rule all:
	input: 
		expand("html/{lib}/out", lib = ALL_LIBRARIES)

# Use unzipped input file if possible 
def get_input(wildcards):
	if path.exists("inputs/" + wildcards.sample + ".fastq"):
		return("inputs/" + wildcards.sample + ".fastq")
	else:
		return("inputs/" + wildcards.sample + ".fastq.gz")

# Unzip input if needed
def get_function(wildcards):
	if "gz" in get_input(wildcards):
		return("gzip -dc ")
	else:
		return("cat ")

# Count barcodes per sample
rule MultiCodes:
	input: get_input
	params: function=get_function
	output: "counts/{sample}.codes"
	log: "counts/{sample}.log"
	shell:
		"{params.function} {input} | "
		"./feba/bin/MultiCodes.pl "
		"-out counts/{wildcards.sample} "
		"-index {wildcards.sample} "
		">& {log}"

def get_codes(wildcards):
	setName = wildcards.lib + "_" + wildcards.set
	codes = sample_metadata.loc[sample_metadata['SetName'] == setName]['Index']
	codes_files = expand("counts/{index}.codes", index = codes)
	return(codes_files)

# Combine barcode counts per strain
rule combineBarSeq:
	input:
		pool="inputs/{lib}.pool",
		codes=get_codes
	params: dir="results/{lib}/{lib}_{set}",
	output: 
		poolcount="results/{lib}/{lib}_{set}.poolcount",
		colsum="results/{lib}/{lib}_{set}.colsum"
	log: "results/{lib}/{lib}_{set}.log"
	shell:
		"./feba/bin/combineBarSeq.pl "
		"{params.dir} "
		"{input.pool} "
		"{input.codes} "
		"2> {log}"

def get_setnames(lib):
	lib_sets = [n for n in ALL_SETS if str(lib) in n]
	return(lib_sets)

def check_poolcounts(lib):
	lib_sets = [n for n in ALL_SETS if str(lib) in n]
	poolcount_files = expand("results/{{lib}}/{set}.poolcount", set = lib_sets)
	return(poolcount_files)

# Calculate fitness per strain
rule BarSeqR:
	params: 
		setnames=get_setnames,
		outdir="html/{lib}"
	input:
		exp="inputs/exp.tab",
		genes="inputs/{lib}_genes.GC",
		pool="inputs/{lib}.pool",
		file_check=check_poolcounts,
#		strainusage=expand("results/{{lib}}/strainusage.{ext}", ext = ["barcodes", "genes", "genes12"])
	output: "html/{lib}/log"
	log: "html/{lib}/out"
	shell:
		"./feba/bin/BarSeqR.pl "
		"-org {wildcards.lib} "
		"-indir results/{wildcards.lib} "
		"-exps {input.exp} "
		"-genes {input.genes} "
		"-pool {input.pool} "
		"-outdir {params.outdir} "
		"{params.setnames} "
		"2> {log}"
