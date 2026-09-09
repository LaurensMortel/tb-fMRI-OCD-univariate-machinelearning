# N, Dzinalija, August 2025, AUMC

# After script 2 has run univariate frequentist models in inhibitory control tasks and several
# sensitivity analyses, this script creates a heat-map plot of the comparison of ROI and whole-brain
# results across different sensitivity analyses.

library(dplyr)
library(ggplot2)
library(readr)
library(stringr)
library(tidyr)
library(gtools)

# =========================
# Functions
# =========================

# Clean and relabel ROI names
clean_roi_names <- function(roi_names) {
  # 7 networks
  roi_names <- gsub("Vis", "Visual", roi_names)
  roi_names <- gsub("SomMot", "Somatomotor", roi_names)
  roi_names <- gsub("DorsAttn", "Dorsal Attention", roi_names)
  roi_names <- gsub("SalVentAttn", "Salience / Ventral Attention", roi_names)
  roi_names <- gsub("Cont", "Control", roi_names)
  roi_names <- gsub("_", " ", roi_names)
  
  # Move hemisphere to end
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
  
  # Subcortical
  roi_names <- gsub("aHIP", "Hippocampus Ant", roi_names)
  roi_names <- gsub("pHIP", "Hippocampus Post", roi_names)
  roi_names <- gsub("lAMY", "Amygdala Lat", roi_names)
  roi_names <- gsub("mAMY", "Amygdala Med", roi_names)
  roi_names <- gsub("THA.DP", "Thalamus DorsopPost", roi_names)
  roi_names <- gsub("THA.VP", "Thalamus VentroPost", roi_names)
  roi_names <- gsub("THA.VA", "Thalamus VentroAnt", roi_names)
  roi_names <- gsub("THA.DA", "Thalamus DorsoAnt", roi_names)
  roi_names <- gsub("NAc.shell", "Nucleus Accumbens Shell", roi_names)
  roi_names <- gsub("NAc.core", "Nucleus Accumbens Core", roi_names)
  roi_names <- gsub("pGP", "Globus Pallidus Post", roi_names)
  roi_names <- gsub("aGP", "Globus Pallidus Ant", roi_names)
  roi_names <- gsub("aPUT", "Putamen Ant", roi_names)
  roi_names <- gsub("pPUT", "Putamen Post", roi_names)
  roi_names <- gsub("aCAU", "Caudate Ant", roi_names)
  roi_names <- gsub("pCAU", "Caudate Post", roi_names)
  roi_names <- gsub(".rh", " R", roi_names)
  roi_names <- gsub(".lh", " L", roi_names)
  
  # Contrast
  roi_names <- gsub(" l", " L", roi_names)
  roi_names <- gsub(" r", " R", roi_names)
  roi_names <- gsub(" b", " B", roi_names)
  
  return(roi_names)
}

# Identify subcortical ROIs
is_subcortical <- function(roi_name) {
  subcortical_patterns <- c("Hippocampus", "Amygdala", "Thalamus", 
                            "Caudate", "Putamen", "Globus Pallidus", 
                            "Nucleus Accumbens")
  any(sapply(subcortical_patterns, function(pat) grepl(pat, roi_name)))
}

# Bin p-values for color coding
bin_p_value <- function(p) {
  case_when(
    p > 0.05 ~ "> 0.05",
    p <= 0.05 & p > 0.01 ~ "< 0.05",
    p <= 0.01 & p > 0.001 ~ "< 0.01",
    p <= 0.001 ~ "< 0.001"
  )
}

# Read and combine results
# =========================

results_folder <- "/data/anw/anw-work/NP/projects/data_ENIGMA_OCD/ENIGMA_TASK/analysis/CBT_response/Regression_results"
files <- list.files(results_folder, pattern = "\\.csv$", full.names = TRUE)

grid_data <- data.frame()

for(f in files) {
  data <- read_csv(f, show_col_types = FALSE)
  
  # Determine analysis type (with line breaks for long labels)
  analysis <- case_when(
    str_detect(f, "_COMBAT_OMNIBUS") ~ "Omnibus + ComBat\n(participant as random\nintercept)",
    str_detect(f, "_OMNIBUS") ~ "Omnibus (all-ROI model,\nsample and participant\nas random intercepts)",
    str_detect(f, "_COMBAT.csv") ~ "ComBat (main model)",
    str_detect(f, "_COMBAT_Medication") ~ "Medication as covariate\nComBat",
    TRUE ~ "No ComBat (sample\nas random intercept)"
  )
  
  # Extract contrast and outcome from filename
  fname <- basename(f)
  contrast <- str_extract(fname, "INHIBITION|ERROR")
  outcome <- str_extract(fname, "deltaYBOCS|RemissionStatus|ResponderStatus")
  
  # Select correct p-value column
  p_col <- ifelse(str_detect(fname, "_OMNIBUS"), "p_value", "FDR_corr")
  
  data_long <- data %>%
    select(ROI, !!p_col) %>%
    rename(p_value = !!p_col) %>%
    mutate(
      Analysis = analysis,
      Contrast = contrast,
      Outcome = outcome
    )
  
  grid_data <- bind_rows(grid_data, data_long)
}


# =========================
# Clean ROI names and set factor levels
# =========================
grid_data <- grid_data %>%
  mutate(ROI = clean_roi_names(ROI),
         p_bin = bin_p_value(p_value),
         Analysis = factor(
           Analysis,
           levels = c(
             "ComBat (main model)",
             "No ComBat (sample\nas random intercept)",
             "Medication as covariate\nComBat",
             "Omnibus (all-ROI model,\nsample and participant\nas random intercepts)",
             "Omnibus + ComBat\n(participant as random\nintercept)"
           )
         ))

# =========================
# Plot grids per contrast x outcome
# =========================
setwd(results_folder)


for(cntrst in unique(grid_data$Contrast)) {
  for(outc in unique(grid_data$Outcome)) {
    
    plot_data <- grid_data %>%
      filter(Contrast == cntrst, Outcome == outc)
    
    # ---- Get contrast-specific ROIs from CSV ----
    csv_files <- list.files(pattern = paste0(cntrst, "_ROI_", outc, "_.*\\.csv$"))
    contrast_rois <- character(0)
    if (length(csv_files) > 0) {
      # read first matching file (assuming all have same ROIs)
      contrast_df <- read.csv(csv_files[1])
      if ("ROI" %in% names(contrast_df)) {
        contrast_rois <- unique(contrast_df$ROI)
        contrast_rois <- gsub("_r", " R", contrast_rois)
        contrast_rois <- gsub("_l", " L", contrast_rois)
        contrast_rois <- gsub("_b", " B", contrast_rois)
      }
    }
    
    # ---- Get cortical ROIs from CSV ----
    csv_files <- list.files(pattern = paste0(cntrst, "_Schaefer200_", outc, "_.*\\.csv$"))
    cortical_rois <- character(0)
    if (length(csv_files) > 0) {
      # read first matching file (assuming all have same ROIs)
      cortical_df <- read.csv(csv_files[1])
      if ("ROI" %in% names(contrast_df)) {
        cortical_rois <- unique(cortical_df$ROI)
        cortical_rois <- clean_roi_names(cortical_rois)
      }
    }
    
    # ---- Split cortical vs subcortical ----
    subcortical_rois <- cortical_rois[sapply(cortical_rois, is_subcortical)]
    cortical_rois <- cortical_rois[!sapply(cortical_rois, is_subcortical)]
    
    # ---- Mixed sort (natural ordering: 1,2,...,9,10...) ----
    contrast_rois <- mixedsort(contrast_rois)
    cortical_rois <- mixedsort(unique(cortical_rois))
    subcortical_rois <- mixedsort(unique(subcortical_rois))
    
    # ---- Final order: contrast-specific -> cortical -> subcortical ----
    roi_levels <- c(contrast_rois, cortical_rois, subcortical_rois)
    plot_data$ROI <- factor(plot_data$ROI, levels = rev(roi_levels))  # reversed for top-to-bottom
    
    # Plot
    p <- ggplot(plot_data, aes(x = Analysis, y = ROI, fill = p_bin)) +
      geom_tile(color = "gray95", size = 0.2) +
      scale_fill_manual(
        values = c("> 0.05" = "white",
                   "< 0.05" = "pink",
                   "< 0.01" = "red",
                   "< 0.001" = "darkred"),
        drop = FALSE
      ) +
      theme_minimal() +
      theme(
        axis.text.y = element_text(size = 7),
        axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1),
        panel.grid = element_blank()
      ) +
      labs(title = paste("Contrast:", cntrst, "| Outcome:", outc),
           x = "Analysis",
           y = "ROI",
           fill = "Significance\n(FDR-corrected\nwhere applicable)")
    
    # Save plot
    ggsave(filename = paste0("Pvalue_Grid_", cntrst, "_", outc, ".jpg"),
           plot = p, width = 8, height = 22)
  }
}




