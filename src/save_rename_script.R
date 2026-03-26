
# Create shell script to rename pep.fa files from accession to name.
# 3/17/2026

library("dplyr")
source("src/NCBI_name_fix.R")

# Load metadata.
ncbi_pecto <- read.delim("identify_orthogroups/ncbi_pecto.txt", header = T)

# Sanitize strain names.
ncbi_pecto$final_name <- sapply(c(1:nrow(ncbi_pecto)), 
                                name_fix, strainlist= ncbi_pecto)

# Write ncbi list containing full strain names
write.table(ncbi_pecto, "identify_orthogroups/ncbi_pecto.tab",
            row.names = F, col.names = F, quote = F, sep = "\t")

# Function to print a single command
print_rename_command <- function(row, strainlist){
  return(paste("mv identify_orthogroups/fasta/", 
               strainlist[row, "assembly_accession"],
               "*protein.faa ",
               "identify_orthogroups/fasta/",
               strainlist[row, "final_name"],
               ".protein.faa",
               sep = ""))
}

# Function to save all commands for a given strainlist.
save_rename_command <- function(strainlist, file_name){
  commands <- c(sapply(c(1:nrow(strainlist)), print_rename_command,
                       strainlist = strainlist))
  commands <- c("#!/bin/bash \n", commands)
  write.table(commands, file = file_name, 
              row.names = F, quote = F, col.names = F)
}

# Write shell script to rename files
save_rename_command(ncbi_pecto, "src/rename_fasta.sh")