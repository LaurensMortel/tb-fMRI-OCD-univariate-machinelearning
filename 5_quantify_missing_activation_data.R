# N, Dzinalija, Sept 2025
# Script that quantifies per analysis group (ENIGMA adults, children, ABCD)
# how many parcels there are with missing data 
# For inhibitory domain there were no ROIs with missing data (less than 30% coverage)

library(tidyr)
library(dplyr)
library(knitr)

for (contrast in c("INHIBITION","ERROR")){
  setwd("/data/anw/anw-work/NP/projects/data_ENIGMA_OCD/ENIGMA_TASK/analysis/CBT_response/Features")
  data <- read.csv(paste0("RBA_input_",contrast,"_Schaefer200_response.txt"),sep="\t")

  # Copy ROI variable
  roi_names <- data$ROI  
  
  # --- 7 networks ---
  roi_names <- gsub("Vis", "Visual", roi_names)
  roi_names <- gsub("SomMot", "Somatomotor", roi_names)
  roi_names <- gsub("DorsAttn", "Dorsal Attention", roi_names)
  roi_names <- gsub("SalVentAttn", "Salience / Ventral Attention", roi_names)
  roi_names <- gsub("Cont", "Control", roi_names)
  roi_names <- gsub("_", " ", roi_names)
  
  # --- Move hemisphere to end ---
  roi_names <- sapply(roi_names, function(name) {
    if (grepl("^LH|^RH", name)) {
      parts <- strsplit(name, " ", fixed = TRUE)[[1]]
      direction <- substr(parts[1], 1, 1)
      parts <- parts[-1]
      paste(paste(parts, collapse = " "), direction, sep = " ")
    } else {
      name
    }
  })
  
  # --- Subcortical ---
  roi_names <- gsub("aHIP", "Hippocampus Ant", roi_names)
  roi_names <- gsub("pHIP", "Hippocampus Post", roi_names)
  roi_names <- gsub("lAMY", "Amygdala Lat", roi_names)
  roi_names <- gsub("mAMY", "Amygdala Med", roi_names)
  roi_names <- gsub("THA-DP", "Thalamus DorsopPost", roi_names)
  roi_names <- gsub("THA-VP", "Thalamus VentroPost", roi_names)
  roi_names <- gsub("THA-VA", "Thalamus VentroAnt", roi_names)
  roi_names <- gsub("THA-DA", "Thalamus DorsoAnt", roi_names)
  roi_names <- gsub("NAc-shell", "Nucleus Accumbens shell", roi_names)
  roi_names <- gsub("NAc-core", "Nucleus Accumbens core", roi_names)
  roi_names <- gsub("pGP", "Globus Pallidus Post", roi_names)
  roi_names <- gsub("aGP", "Globus Pallidus Ant", roi_names)
  roi_names <- gsub("aPUT", "Putamen Ant", roi_names)
  roi_names <- gsub("pPUT", "Putamen Post", roi_names)
  roi_names <- gsub("aCAU", "Caudate Ant", roi_names)
  roi_names <- gsub("pCAU", "Caudate Post", roi_names)
  roi_names <- gsub("-rh", " R", roi_names)
  roi_names <- gsub("-lh", " L", roi_names)
  
  # Apply back to your long dataset
  data$ROI <- roi_names
  
  
  # 1) compute missingness per ROI  
  missing_summary <- data %>%
    group_by(ROI) %>%
    summarise(
      total = n(),
      missing = sum(is.na(Y)),
      missing_pct = 100 * missing / total,
      .groups = "drop"
    ) %>%
    filter(missing > 0)   # drop ROIs with zero missing (optional)
  
  # 2) sort by missingness and add a rank column
  result <- missing_summary %>%
    arrange(desc(missing_pct), desc(missing)) %>%
    select(ROI, missing_pct) %>%
    mutate(rank = row_number())
  
  # 3) optional: round percentages
  result <- result %>%
    mutate(missing_pct = round(missing_pct, 1))
  
  # 4) view
  print(kable(result))
  }

