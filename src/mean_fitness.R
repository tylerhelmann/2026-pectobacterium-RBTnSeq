
library(stringr)

# Define strain names
strain_names <- c("Par6119", "PatSCRI1043", "Pbr123", "Pbr1692", "PccWPP14", "PpaNY1722A", "PveNY1715C")

# Load orthogroup matrix
orthogroups_long_locus <- read.csv("fitness/orthogroups_long_locus.csv")
# Need COG codes
COG_codes <- read.delim("analysis/COG_codes.txt", header = T)

for (strain_name in strain_names) {
  
  # Load fitness matrix: genes as rows, conditions as columns
  fitness <- read.delim(paste0("fitness/html/", strain_name, "/fit_logratios_good.tab"))
  
  mean_mat <- fitness %>%
    # Pivot replicate columns to long format
    pivot_longer(
      cols = starts_with("set"), 
      names_to = "raw_sample", 
      values_to = "fitness"
    ) %>%
    # Extract the condition name 
    mutate(condition = str_remove(raw_sample, "^set[0-9]+[A-Za-z0-9]+\\.")) %>%
    # Group by gene & condition, then calculate mean fitness across replicates
    group_by(locusId, desc, condition) %>%
    summarise(mean_fitness = mean(fitness, na.rm = TRUE), .groups = "drop") %>%
    # Pivot back to wide format matrix
    pivot_wider(
      names_from = condition, 
      values_from = mean_fitness
    ) 
  
  # Add orthogroups
  mean_mat <- left_join(mean_mat, orthogroups_long_locus) %>%
    mutate(Orthogroup = coalesce(Orthogroup, locusId)) %>% 
    mutate(strain = coalesce(strain, strain_name))
  
  # Add COG Descriptions
  eggNOG <- read.delim(paste0("analysis/", strain_name, "-eggnog-mapper.tsv"), skip = 4) %>%
    select(query, COG = COG_category, Description) %>%
    rename("locusId" = "query") %>%
    left_join(COG_codes, by = c("COG" = "Code")) %>%
    mutate(COG_Description = case_when(
      nchar(COG) > 1 ~ "Multiple",
      is.na(COG_Description) ~ "None",
      TRUE ~ COG_Description
    ))
  mean_mat <- left_join(mean_mat, eggNOG, by = "locusId")
  
  write.csv(mean_mat, paste0("analysis/mean_fit_", strain_name, ".csv"), row.names = F)
}
