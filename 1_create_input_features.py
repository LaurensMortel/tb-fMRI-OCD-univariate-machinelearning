#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
N, Dzinalija, May 2025, Amsterdam UMC

Prepares Schaefer atlas regional activation features and clinical covariates 
for each task-based functional domain for machine learning analyses.

For Emotional, Executive and Inhibitory domains, the contrasts to use are:
    Emotional = negative valence > neutral ("EMOgtNEUT")
    Executive = planning > baseline ("PLANNING")
    Inhibitory = response inhibition > action ("INHIBITION")

"""
import os
import pandas as pd
import numpy as np
from photonai.base import Hyperpipe, PipelineElement, OutputSettings, Switch, Preprocessing
from photonai.optimization import Categorical, IntegerRange, FloatRange
from sklearn.model_selection import StratifiedKFold
from sklearn.model_selection import LeaveOneGroupOut    

### Create feature files combining clinical and regional activation data

# Initialize dictionaries
input_features = {}

# Load CBT covariates 
base_dir="/data/anw/anw-work/NP/projects/data_ENIGMA_OCD/ENIGMA_TASK/analysis/"
CBT_covariates_file = "/data/anw/anw-work/NP/projects/data_ENIGMA_OCD/ENIGMA_TASK/analysis/CBT_response/CBT_covariates/CBT_covariates.csv"
CBT_covariates = pd.read_csv(CBT_covariates_file)
CBT_covariates = CBT_covariates.rename(columns={"Subject_ID_new": "Subj"})
CBT_covariates = CBT_covariates[["Subj", "tCBT", "dCBT", "typeCBT", "cMed", "SevYBOCS_pre", "SevYBOCS_post"]]

# Domain-to-contrast mapping
domain_contrast = {
    "Inhibitory_domain": ["INHIBITION", "ERROR"]
}

for domain, contrasts in domain_contrast.items():
    for contrast in contrasts:
        for region in ["Schaefer200","ROI"]:
            # Load activation data and clinical covariates 
            activation_dir = os.path.join(base_dir, domain, "merged", contrast)
            activation_file = os.path.join(activation_dir, f"RBA_input_{contrast}_{region}.txt")
            activation_long = pd.read_csv(activation_file)
            activation = activation_long.pivot(index="Subj", columns="ROI", values="Y").reset_index()
        
            clinical_covariates_file = os.path.join(base_dir,domain,"covariates/RBA_input_demographics_only.csv")
            clinical_covariates = pd.read_csv(clinical_covariates_file)
            if "AGEGROUP" in clinical_covariates.columns:
                clinical_covariates = clinical_covariates.drop(columns=["AGEGROUP"])
        
            # Merge clinical covariates, activation data, and CBT covariates
            merged = pd.merge(clinical_covariates, CBT_covariates, on="Subj", how="inner")
            merged = pd.merge(merged, activation, on="Subj", how="inner")
            
            # If SevYBOCS_pre is missing, replace with value from YBOCS
            merged["SevYBOCS_pre"] = merged["SevYBOCS_pre"].fillna(merged["YBOCS"])
        
            # Check whether minimum necessary data is present
            # Drop rows with missing SevYBOCS_pre or SevYBOCS_post
            merged = merged.dropna(subset=["SevYBOCS_pre", "SevYBOCS_post"])
            
            # Calculate delta Y-BOCS
            merged["deltaYBOCS"] = pd.to_numeric(merged.SevYBOCS_pre) - pd.to_numeric(merged.SevYBOCS_post)
            
            # Calculate response status (if YBOCS improved by at least 35% from pre-to-post)
            merged["ResponderStatus"] = ( ( merged.deltaYBOCS / pd.to_numeric(merged.SevYBOCS_pre) ) >= 0.35).astype(int)
            
            # Calculate remission status (if YBOCS at post-treatment is 12 or less)
            merged["RemissionStatus"] = (merged.SevYBOCS_post <= 12).astype(int)
            
            # Convert string variables to numeric (0-based)
            merged.SEX[merged.SEX=='m'] = 0
            merged.SEX[merged.SEX=='f'] = 1
            merged.AO[merged.AO=='Child'] = 0
            merged.AO[merged.AO=='Adult'] = 1
            merged.MED[merged.MED=='Unmed'] = 0
            merged.MED[merged.MED=='Med'] = 1
            merged['Sample'] = pd.Categorical(merged['Sample'])
            merged['Sample'] = merged['Sample'].cat.codes
            
            # Rename variables and reshuffle order of columns
            merged = merged.drop(columns=["YBOCS", "DX","cMed"], errors="ignore")
            merged = merged.rename(columns={"AO": "AgeOfOnset", "MED": "Medication"})
            move_cols = ["deltaYBOCS", "ResponderStatus", "RemissionStatus"]
            other_cols = merged.columns.difference(move_cols, sort=False).tolist()
            insert_at = other_cols.index("SevYBOCS_post") + 1
            new_col_order = other_cols[:insert_at] + move_cols + other_cols[insert_at:]
            merged = merged[new_col_order]
            
            # Store final merged data
            input_features[f"{domain}_{contrast}"] = merged
            
            # Save features dataframe
            merged.to_csv(os.path.join("/data/anw/anw-work/NP/projects/data_ENIGMA_OCD/ENIGMA_TASK/analysis/CBT_response",f"features_{domain}_{contrast}_{region}.csv"),index=False)

    
    
# -------------------- GENERATED WITH PHOTON WIZARD (beta) ------------------------------
# Classifier using only imaging features (rows 15:247 in features)
            
# Define hyperpipe
hyperpipe = Hyperpipe('inhibitorydomain',
                      project_folder = '/data/anw/anw-work/NP/projects/data_ENIGMA_OCD/ENIGMA_TASK/analysis/CBT_response',
                      optimizer="random_grid_search",
                      optimizer_params={'n_configurations': 30},
                      metrics=['accuracy', 'balanced_accuracy', 'sensitivity', 'specificity'],
                      best_config_metric="balanced_accuracy",
                      outer_cv = LeaveOneGroupOut(),
                      inner_cv = StratifiedKFold(n_splits=5, shuffle=True))  
# Add transformer elements
preprocessing_pipe = Preprocessing()
hyperpipe += preprocessing_pipe
preprocessing_pipe += PipelineElement("LabelEncoder") 
                        
hyperpipe += PipelineElement("SimpleImputer", hyperparameters={}, 
                             test_disabled=False, missing_values=np.nan, strategy='mean', fill_value=0)
hyperpipe += PipelineElement("PCA", hyperparameters={}, 
                             test_disabled=False, n_components=0.8)
hyperpipe += PipelineElement("RandomForestClassifier", hyperparameters={}, n_estimators=50, criterion='gini', max_depth=None, min_samples_split=2, min_samples_leaf=1)

# Load data
df = pd.read_csv('/data/anw/anw-work/NP/projects/data_ENIGMA_OCD/ENIGMA_TASK/analysis/CBT_response/features_Inhibitory_domain.csv')
X = np.asarray(df.iloc[:, 15:246])
y = np.asarray(df.iloc[:, 248])
group_var = np.asarray(df.iloc[:, 0])

# Fit hyperpipe
hyperpipe.fit(X, y, groups=group_var)  





###Inhibition

# TBM_OCD
# Total: 14
# Responders: 10

# AMC_BASCULE
# Total: 27
# Responders: 18

# BARCELONA
# Total: 31
# Responders: 21

# IDIBELL_3T
# Total: 22
# Responders: 9

# BERGEN_B4DT
# Total: 36
# Responders: 30