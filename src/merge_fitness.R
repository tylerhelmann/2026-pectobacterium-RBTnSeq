
### Merge orthogroup matrix + fitness table to compare fitness across strains

library(dplyr)
library(purrr)
library(readr)
library(tidyr)

# setwd("2026-pectobacterium-RBTnSeq/")

# Define strain names 
strain_names <- c("Par6119", "PatSCRI1043", "Pbr123", "Pbr1692", "PccWPP14", "PpaNY1722A", "PveNY1715C")

# Load ortholog matrix (with protein IDs) - revised to include "unassigned" genes
orthogroups <- read.csv("identify_orthogroups/results/Orthogroups/Orthogroups_subset.csv")

# Load fitness tables 
fitness_list <- map(strain_names, ~ read_tsv(paste0("fitness/html/", .x, "/fit_logratios_good.tab")))
names(fitness_list) <- strain_names

orthogroups_long_locus <- orthogroups %>%
  pivot_longer(-Orthogroup, names_to = "strain", values_to = "locusId") %>%
  filter(!is.na(locusId)) %>%
  distinct(locusId, .keep_all = TRUE)
write.csv(orthogroups_long_locus, "fitness/orthogroups_long_locus.csv", row.names = F)

# Map fitness to orthogroups
fitness_mapped <- imap(fitness_list, function(df, strain) {
  df %>%
    left_join(orthogroups_long_locus %>% filter(strain == strain), by = "locusId") %>%
    mutate(Orthogroup = coalesce(Orthogroup, locusId)) %>%
  #  filter(!is.na(Orthogroup)) %>%  # Should be no unmatched genes at this point
    group_by(Orthogroup) %>%
    summarize(across(where(is.numeric), mean, na.rm = TRUE)) %>%
    rename_with(~ paste0(., "_", strain), -Orthogroup)
})

# Merge all fitness data
merged_fitness <- reduce(fitness_mapped, full_join, by = "Orthogroup")

# Save merged fitness file
write.csv(merged_fitness, "fitness/merged_fitness.csv", row.names = F)

