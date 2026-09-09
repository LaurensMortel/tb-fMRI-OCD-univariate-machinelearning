library(readxl)
library(tidyverse)
library(ggpattern)
library(ggplot2)

# Path to your Excel file
setwd("/scratch/anw/nddzinalija")
file_path <- "/scratch/anw/nddzinalija/ML_tables_for_plotting.xlsx"

# Get all sheet names
sheets <- excel_sheets(file_path)

# Loop through sheets
for (sheet in sheets) {
  
  # ---- 1. Read sheet ----
  df <- read_excel(file_path, sheet = sheet)
  
  # ---- 2. Clean columns ----
  df <- df %>%
    rename(CrossValidation = `Cross-validation`) %>%
    mutate(
      # Extract numeric AUC
      AUC = as.numeric(sub(" .*", "", `AUC (CI)`)),
      # Extract lower CI
      Lower_CI = as.numeric(sub("^(.*)-(.*)$", "\\1",
                                gsub(".*\\((.*)\\).*", "\\1", `AUC (CI)`))),
      # Extract upper CI
      Upper_CI = as.numeric(sub("^(.*)-(.*)$", "\\2",
                                gsub(".*\\((.*)\\).*", "\\1", `AUC (CI)`))),
      # Shorten Random forest name
      Model = ifelse(Model == "Random forest", "RF", Model),
    )
  
  
  # ---- 3. Prepare for plotting custom patterns/colors ----
  df <- df %>%
    mutate(OutcomeCV = paste(Outcome, CrossValidation, sep = "_"))
  
  model_patterns <- c("RF" = "none", "SVM" = "circle")
  
  outcome_cv_colors <- c(
    "Response_5-fold CV+ComBat" = "#a6cee3",  # light blue
    "Response_LOSO" = "#1f78b4",      # dark blue
    "Remission_5-fold CV+ComBat" = "#fb9a99",  # light red
    "Remission_LOSO" = "#e31a1c"     # dark red  
    )

  # ---- 4. Plot ----
  p <- ggplot(df, aes(
    x = interaction(CrossValidation, Outcome, sep = " "),
    y = AUC,
    fill = OutcomeCV,
    group = interaction(Model, CrossValidation, Outcome)
  )) +
    geom_col_pattern(
      aes(pattern = Model),
      position = position_dodge(width = 0.9),
      colour = "black",
      pattern_fill = "black",
      pattern_density = 0.2,
      pattern_spacing = 0.03
    ) +
    geom_errorbar(
      aes(ymin = Lower_CI, ymax = Upper_CI),
      position = position_dodge(width = 0.9),
      width = 0.3
    ) +
    geom_hline(yintercept = 0.5, linetype = "dotted", colour = "black") +
    scale_fill_manual(
      values = outcome_cv_colors,
      name = "CBT Outcome",
      breaks = names(outcome_cv_colors),
      labels = c("Response (5-fold CV)", "Response (LOSO)",
                 "Remission (5-fold CV)", "Remission (LOSO)")
    ) +
    scale_pattern_manual(values = model_patterns, name = "ML Model") +
    scale_y_continuous(limits = c(0, 1),expand = c(0,0)) +
    labs(
      title = paste("Mean AUC values -", sheet),
      y = "AUC",
      x = "Features"
    ) +
    theme_minimal(base_size = 14) +
    theme(
      axis.line.y = element_line(color = "black"),
      legend.position = "right",
      axis.text.x = element_blank(),
      panel.grid = element_blank()
    ) +
    facet_grid(. ~ Features, scales = "free_x", space = "free_x", switch = "x") +
    theme(
      strip.placement = "outside")+
    guides(
      fill = guide_legend(override.aes = list(pattern = "none")), 
      pattern = guide_legend(override.aes = list(fill = "white"))
    )
  
  # ---- 5. Save each figure ----
  if (sheet=="Clinical"){
  ggsave(filename = paste0("AUC_plot_", sheet, ".png"),
         plot = p, width = 6.5, height = 6, dpi = 300)
  } else {
    ggsave(filename = paste0("AUC_plot_", sheet, ".png"),
           plot = p, width = 10, height = 6, dpi = 300)
  }
}









