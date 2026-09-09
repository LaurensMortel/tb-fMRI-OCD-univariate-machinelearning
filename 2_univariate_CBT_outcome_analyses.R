# N, Dzinalija, June 2025, AUMC

# Script to run univariate frequentist models in inhibitory control tasks on:
#   1) remitters vs. non-remitters to CBT treatment (YBOCS-post < 12)
#   2) responders vs. non-responders to CBT treatment (deltaYBOCS > 35% of YBOCS-pre)
#   3) delta YBOCS as continuous variable
 
# Site effects corrected using Combat or using sample as random intercept

library(tidyr)
library(lme4)
library(lmerTest)
library(dplyr)
library(sva)
library(knitr)

########################
### Define functions ###
########################

# function to run combat on dataset
run_combat <- function(data_wide, roi_start_col = 16, covariates_formula, batch_column = "Sample") {
  library(sva)
  library(dplyr)
  library(tidyr)
  
  combat_input <- as.matrix(data_wide[, roi_start_col:ncol(data_wide)])
  combat_input <- t(combat_input)
  
  data_wide[[batch_column]] <- as.factor(data_wide[[batch_column]])
  batch <- data_wide[[batch_column]]
  mod <- model.matrix(covariates_formula, data = data_wide)
  
  combat_corrected <- ComBat(dat = combat_input, batch = batch, mod = mod, par.prior = TRUE)
  combat_corrected_wide <- t(combat_corrected)
  
  meta_cols <- all.vars(covariates_formula)
  meta_cols <- c("Subj", batch_column, meta_cols[!meta_cols %in% "1"])
  combat_corrected_wide <- cbind(data_wide[, meta_cols], as.data.frame(combat_corrected_wide))
  
  combat_corrected_data <- combat_corrected_wide %>% 
    pivot_longer(cols = (length(meta_cols) + 1):ncol(combat_corrected_wide),
                 names_to = "ROI", values_to = "Y")
  
  return(combat_corrected_data)
}

# function to run regression model per ROI
run_glm_per_roi <- function(data_long, predictor, covariates = c("AGE", "SEX"), random_effect = NULL) {
  library(dplyr)
  library(lme4)
  library(lmerTest)
  
  p_table <- data.frame(
    ROI = character(),
    T_value = numeric(),
    DF = numeric(),
    p_value = numeric(),
    Cohen_d = numeric(),
    stringsAsFactors = FALSE
  )
  
  for (roi in unique(data_long$ROI)) {
    roi_data <- data_long %>% filter(ROI == roi)
    predictors_str <- paste(c(predictor, covariates), collapse = " + ")
    
    if (!is.null(random_effect)) {
      # Mixed model
      formula_str <- paste0("Y ~ ", predictors_str, " + (1 | ", random_effect, ")")
      model <- lmer(as.formula(formula_str), data = roi_data)
    } else {
      # Simple GLM
      model <- lm(as.formula(paste("Y ~", predictors_str)), data = roi_data)
    }
    
    coef_row <- grep(paste0("^", predictor), rownames(coef(summary(model))), value = TRUE)
    t_value <- coef(summary(model))[coef_row, "t value"]
    
    if (!is.null(random_effect)) {
      df_val <- coef(summary(model))[coef_row, "df"]     # from lmerTest
    } else {
      df_val <- df.residual(model)                       # from lm
    }
    
    p_value <- coef(summary(model))[coef_row, "Pr(>|t|)"]
    cohen_d <- (2 * t_value) / sqrt(nrow(roi_data))
    
    p_table <- rbind(
      p_table,
      data.frame(
        ROI = roi,
        T_value = t_value,
        DF = df_val,
        p_value = p_value,
        Cohen_d = cohen_d
      )
    )
  }
  
  # Multiple comparison corrections
  p_table$Bonferoni_corr <- pmin(p_table$p_value * nrow(p_table), 1)
  p_table$FDR_corr <- p.adjust(p_table$p_value, method = "fdr")
  
  return(p_table)
}

run_all_rois_with_emmeans <- function(data_long, predictor, covariates = c("AGE", "SEX"), random_effect = "Sample/Subj") {
  library(lme4)
  library(lmerTest)
  library(emmeans)
  library(dplyr)
  
  # Build formula
  covariates_str <- paste(covariates, collapse = " + ")
  formula_str <- paste0("Y ~ ", predictor, " * ROI + ", covariates_str, " + (1 | ", random_effect, ")")
  model <- lmer(as.formula(formula_str), data = data_long)
  
  # Detect if predictor is continuous
  is_cont <- is.numeric(data_long[[predictor]]) && length(unique(data_long[[predictor]])) > 5
  
  # Helper: pick the right test statistic column
  pick_stat_col <- function(df) {
    if ("t.ratio" %in% names(df)) return("t.ratio")
    if ("z.ratio" %in% names(df)) return("z.ratio")
    stop("No t.ratio or z.ratio column found.")
  }
  
  # Helper: pick CI columns dynamically
  pick_CI_cols <- function(df) {
    lower <- intersect(c("lower.CL", "asymp.LCL"), colnames(df))
    upper <- intersect(c("upper.CL", "asymp.UCL"), colnames(df))
    if (length(lower) == 0 | length(upper) == 0) stop("No CI columns found.")
    return(list(lower = lower[1], upper = upper[1]))
  }
  
  if (!is_cont) {
    # Categorical predictor: pairwise comparisons within ROI
    contrast_formula <- as.formula(paste("pairwise ~", predictor, "| ROI"))
    emm <- emmeans(model, specs = contrast_formula, adjust = "none")
    
    contrast_results <- as.data.frame(emm$contrasts)
    ci_contrasts <- as.data.frame(confint(emm$contrasts))   # extract CI separately
    
    stat_col <- pick_stat_col(contrast_results)
    
    # Rename CI columns
    ci_cols <- pick_CI_cols(ci_contrasts)
    ci_contrasts <- ci_contrasts %>%
      rename(
        ROI = ROI,
        Lower_CL = !!ci_cols$lower,
        Upper_CL = !!ci_cols$upper
      ) %>%
      select(ROI, Lower_CL, Upper_CL)
    
    # Build final table by joining
    p_table <- contrast_results %>%
      rename(
        ROI = ROI,
        Estimate = estimate,
        SE = SE,
        DF = df,
        T_value = !!stat_col,
        p_value = p.value
      ) %>%
      left_join(ci_contrasts, by = "ROI") %>%
      select(ROI, Estimate, SE, DF, Lower_CL, Upper_CL, T_value, p_value)
  } else {
    # Continuous predictor: slopes per ROI
    trends <- emtrends(model, specs = ~ ROI, var = predictor)
    slope_tests <- as.data.frame(test(trends))
    ci_trends <- as.data.frame(confint(trends))
    
    stat_col <- pick_stat_col(slope_tests)
    est_col <- grep("\\.trend$", colnames(slope_tests), value = TRUE)
    ci_cols <- pick_CI_cols(ci_trends)
    
    # Join CI with slope tests
    ci_trends <- ci_trends %>%
      rename(
        ROI = ROI,
        Lower_CL = !!ci_cols$lower,
        Upper_CL = !!ci_cols$upper
      ) %>%
      select(ROI, Lower_CL, Upper_CL)
    
    p_table <- slope_tests %>%
      rename(
        ROI = ROI,
        Estimate = all_of(est_col),
        SE = SE,
        DF = df,
        T_value = !!stat_col,
        p_value = p.value
      ) %>%
      left_join(ci_trends, by = "ROI") %>%
      select(ROI, Estimate, SE, DF, Lower_CL, Upper_CL, T_value, p_value)
  }
  
  return(p_table)
}

#########################################
#######         Analyses          #######
#########################################

setwd("/data/anw/anw-work/NP/projects/data_ENIGMA_OCD/ENIGMA_TASK/analysis/CBT_response")

for (contrast in c("INHIBITION","ERROR")){
  for (region in c("ROI","Schaefer200")){
    for (predictor in c("ResponderStatus","RemissionStatus","deltaYBOCS")){
      print(contrast)
      print(region)
      print(predictor)
      
      data_wide = read.csv(paste0("Features/features_Inhibitory_domain_",contrast,"_",region,".csv"))
      data_wide$Sample <- as.factor(data_wide$Sample)
      data_wide$ResponderStatus <- as.factor(data_wide$ResponderStatus)
      data_wide$RemissionStatus <- as.factor(data_wide$RemissionStatus)
      
      data_long = data_wide  %>% 
        pivot_longer(
          cols = c(16:ncol(data_wide)), 
          names_to = "ROI",
          values_to = "Y"
        )
      
      # Set covariates depending on predictor
      if (predictor == "deltaYBOCS") {
        covariates <- c("AGE", "SEX", "SevYBOCS_pre")
        combat_formula <- as.formula(paste("~ AGE + SEX + SevYBOCS_pre +", predictor))
        combat_formula_med <- as.formula(paste("~ AGE + SEX + Medication + SevYBOCS_pre +", predictor))
      } else {
        data_long[[predictor]] <- relevel(factor(data_long[[predictor]]), ref = "1")
        covariates <- c("AGE", "SEX")
        combat_formula <- as.formula(paste("~ AGE + SEX +", predictor))
        combat_formula_med <- as.formula(paste("~ AGE + SEX + Medication +", predictor))
      }
      
      ### no COMBAT correction
      p_table <- run_glm_per_roi(data_long, predictor = predictor, covariates = covariates,random_effect = "Sample")
      p_table_all_ROIs <- run_all_rois_with_emmeans(data_long, predictor=predictor, covariates = covariates, random_effect = "Sample/Subj")
      write.csv(p_table %>% arrange(FDR_corr),paste0("Regression_results/",contrast,"_",region,"_",predictor,".csv"))
      write.csv(p_table_all_ROIs %>% arrange(p_value),paste0("Regression_results/",contrast,"_",region,"_",predictor,"_OMNIBUS.csv"))
        
      ### COMBAT correction
      combat_data <- run_combat(data_wide, roi_start_col = 16, covariates_formula = combat_formula, batch_column = "Sample")
      
      p_table_combat <- run_glm_per_roi(combat_data, predictor = predictor, covariates = covariates)
      write.csv(p_table_combat %>% arrange(FDR_corr),paste0("Regression_results/",contrast,"_",region,"_",predictor,"_COMBAT.csv"))

      # Omnibus sensitivity test
      p_table_combat_all_ROIs <- run_all_rois_with_emmeans(combat_data, predictor=predictor, covariates = covariates, random_effect = "Subj")
      write.csv(p_table_combat_all_ROIs %>% arrange(p_value),paste0("Regression_results/",contrast,"_",region,"_",predictor,"_COMBAT_OMNIBUS.csv"))
      
      # Medication covariate sensitivity test
      data_wide_clean <- data_wide %>% tidyr::drop_na(all_of("Medication"))
      combat_data_med <- run_combat(data_wide_clean, roi_start_col = 16, covariates_formula = combat_formula_med, batch_column = "Sample")
      p_table_medication <- run_glm_per_roi(combat_data_med, predictor = predictor, covariates = append(covariates, "Medication"))
      write.csv(p_table_medication %>% arrange(p_value),paste0("Regression_results/",contrast,"_",region,"_",predictor,"_COMBAT_Medication.csv"))
      
    }
  }
}

#########################################
######      Prep data for RBA     #######
#########################################

setwd("/data/anw/anw-work/NP/projects/data_ENIGMA_OCD/ENIGMA_TASK/analysis/CBT_response/Features")

for (contrast in c("INHIBITION","ERROR")){
  for (region in c("Schaefer200","ROI")){
    data_wide = read.csv(paste0("features_Inhibitory_domain_",contrast,"_",region,".csv"))
    
  
    # ----- Rename ROI columns (wide format) -----
    if (region == "Schaefer200") {
      roi_names <- colnames(data_wide)[16:ncol(data_wide)]
    
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
      
      # Apply renamed ROI columns to data_wide
      colnames(data_wide)[16:ncol(data_wide)] <- roi_names
    }
    
    # ------------------------------------------------------------
    
    data_long = data_wide %>%
      pivot_longer(
        cols = 16:ncol(data_wide),
        names_to = "ROI",
        values_to = "Y"
      )
    
    for (predictor in c("response","remission","deltaYBOCS")){
      
      # Set covariates depending on predictor
      if (predictor == "deltaYBOCS") {
        combat_formula <- as.formula(paste("~ AGE + SEX + SevYBOCS_pre +", predictor))
        selected_vars <- c("Sample", "Subj", "AGE", "SEX", "SevYBOCS_pre", predictor, "ROI", "Y")
      } else if (predictor == "response"){
        combat_formula <- as.formula(paste("~ AGE + SEX + ResponderStatus"))
        selected_vars <- c("Sample", "Subj", "AGE", "SEX", "ResponderStatus", "ROI", "Y")
      } else if (predictor == "remission"){
        combat_formula <- as.formula(paste("~ AGE + SEX + RemissionStatus"))
        selected_vars <- c("Sample", "Subj", "AGE", "SEX", "RemissionStatus", "ROI", "Y")        
      }
      
      # ------ Without ComBat correction ------------
      input_RBA <- data_long %>%
        dplyr::select(all_of(selected_vars))
      
      write.table(input_RBA, file = paste("RBA_input_",contrast, "_", region,"_",predictor,".txt",sep=""), sep = "\t", row.names = FALSE)
      
      # -------- WITH ComBat correction -------------
      selected_vars_combat <- selected_vars[ !selected_vars == 'Sample']
      
      combat_data <- run_combat(data_wide, roi_start_col = 16, covariates_formula = combat_formula, batch_column = "Sample")
      
      input_RBA_combat <- combat_data %>%
        dplyr::select(all_of(selected_vars_combat))
      
      write.table(input_RBA_combat, file = paste("RBA_input_",contrast, "_", region,"_",predictor,"_COMBAT.txt",sep=""), sep = "\t", row.names = FALSE)
    }
  }
}


################################################################################################################################
#######    Reviewer feedback: Re-do analyses with baseline C-YBOCS as covariate for response/remission as well          #######
################################################################################################################################

setwd("/data/anw/anw-work/NP/projects/data_ENIGMA_OCD/ENIGMA_TASK/analysis/CBT_response")

for (contrast in c("INHIBITION","ERROR")){
  for (region in c("ROI","Schaefer200")){
    for (predictor in c("ResponderStatus", "RemissionStatus")){
      print(contrast)
      print(region)
      print(predictor)
    
      data_wide = read.csv(paste0("Features/features_Inhibitory_domain_",contrast,"_",region,".csv"))
      data_wide$Sample <- as.factor(data_wide$Sample)
      data_wide$ResponderStatus <- as.factor(data_wide$ResponderStatus)
      data_wide$RemissionStatus <- as.factor(data_wide$RemissionStatus)
      
      data_long = data_wide  %>% 
        pivot_longer(
          cols = c(16:ncol(data_wide)), 
          names_to = "ROI",
          values_to = "Y"
        )
      
      # Set covariates to include baseline YBOCS as predictor in all models
      covariates <- c("AGE", "SEX", "SevYBOCS_pre")
      data_long[[predictor]] <- relevel(factor(data_long[[predictor]]), ref = "1")
     
      ### COMBAT correction
      combat_formula <- as.formula(paste("~ AGE + SEX + SevYBOCS_pre +", predictor))
      combat_data <- run_combat(data_wide, roi_start_col = 16, covariates_formula = combat_formula, batch_column = "Sample")
      
      p_table_combat <- run_glm_per_roi(combat_data, predictor = predictor, covariates = covariates)
      write.csv(p_table_combat %>% arrange(FDR_corr),paste0("Regression_results/",contrast,"_",region,"_",predictor,"_COMBAT_withBaselineYBOCS.csv"))
      
    }
  }
}

####################################################################################
#######    Reviewer feedback: Re-do analyses excluding Flanker task          #######
####################################################################################

setwd("/data/anw/anw-work/NP/projects/data_ENIGMA_OCD/ENIGMA_TASK/analysis/CBT_response")

for (contrast in c("INHIBITION","ERROR")){
  for (region in c("ROI","Schaefer200")){
    for (predictor in c("ResponderStatus","RemissionStatus","deltaYBOCS")){
      print(contrast)
      print(region)
      print(predictor)
      
      data_wide = read.csv(paste0("Features/features_Inhibitory_domain_",contrast,"_",region,".csv"))
      data_wide$Sample <- as.factor(data_wide$Sample)
      data_wide$ResponderStatus <- as.factor(data_wide$ResponderStatus)
      data_wide$RemissionStatus <- as.factor(data_wide$RemissionStatus)

      # Remove Flanker task
      data_wide = data_wide[data_wide$TASK != "FLANKER", ]
      data_wide$Sample <- droplevels(data_wide$Sample)
      
      data_long = data_wide  %>% 
        pivot_longer(
          cols = c(16:ncol(data_wide)), 
          names_to = "ROI",
          values_to = "Y"
        )
      
      # Set covariates depending on predictor
      if (predictor == "deltaYBOCS") {
        covariates <- c("AGE", "SEX", "SevYBOCS_pre")
        combat_formula <- as.formula(paste("~ AGE + SEX + SevYBOCS_pre +", predictor))
      } else {
        data_long[[predictor]] <- relevel(factor(data_long[[predictor]]), ref = "1")
        covariates <- c("AGE", "SEX")
        combat_formula <- as.formula(paste("~ AGE + SEX +", predictor))
      }

      ### COMBAT correction
      combat_data <- run_combat(data_wide, roi_start_col = 16, covariates_formula = combat_formula, batch_column = "Sample")
      
      p_table_combat <- run_glm_per_roi(combat_data, predictor = predictor, covariates = covariates)
      write.csv(p_table_combat %>% arrange(FDR_corr),paste0("Regression_results/",contrast,"_",region,"_",predictor,"_COMBAT_NoFlanker.csv"))
      
    }
  }
}

