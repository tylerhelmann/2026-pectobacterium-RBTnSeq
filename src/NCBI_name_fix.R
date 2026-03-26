# 10/2/2024.

# For strains listed in NCBI metadata, some have name duplications 
# and forbidden characters.
# This function takes the "organism_name" and "infraspecific_name"
# from the strainlist (NCBI metadata categories) and
# returns a consolidated and edited "final" strain name.

name_fix <- function(row, strainlist){
  require(dplyr)
  
  org_name <- strainlist[row, "organism_name"]
  strain_name <- strainlist[row, "infraspecific_name"]
  
  # Check for name duplication only if "infraspecific_name" is not blank.
  if (strain_name != "") {
    # Remove "strain=" from strain_name if present.
    strain_name <- gsub("strain=", "", strain_name)
    # If strain_name can be found in org_name, delete strain_name.
    if (grep(strain_name, org_name) %>% length == 1) {
      strain_name <- ""
    }
  }
  
  # Combine org_name (genus + species) + strain_name.
  ifelse(test = strain_name == "", 
         yes = name <- org_name, 
         no = name <- paste(org_name, strain_name, sep = " "))
  
  # Replace forbidden characters with underscores.
  # Remove parentheses.
  name <- gsub(" ", "_", name)
  name <- gsub(":", "_", name)
  name <- gsub("/", "_", name)
  name <- gsub("\\.", "_", name)
  name <- gsub("-", "_", name)
  name <- gsub("__", "_", name)
  name <- gsub("\\)", "", name)
  name <- gsub("\\(", "", name)
  
  return(name)
}