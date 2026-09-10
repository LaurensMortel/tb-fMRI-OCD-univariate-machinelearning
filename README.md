# Predicting cognitive-behavioral therapy outcomes in obsessive-compulsive disorder from inhibitory control neural activity: A mega-analysis and machine learning study from the ENIGMA-OCD consortium

This repository accompanies the ENIGMA-OCD manuscript available in [this preprint](https://www.medrxiv.org/content/10.64898/2026.03.13.26348316v1) on MedRxiv. It contains all scripts used for multimodal data preprocessing and quality control.

This project is part of a larger ENIGMA-OCD analysis of inhibitory control task activation in OCD (see [Dzinalija et al. (2025), *BioRxiv preprint*](https://doi.org/10.1101/2025.10.22.683868). The scripts in this repository take the processed, quality-controlled, and parcellated functional MRI data extracted in the previous project as the starting point for univariate and machine learning analysis. For details of the MRI data pre-processing and processing pipeline, as well as the corresponding code, please refer to [this repository](https://github.com/nadza-dz/task-based-fMRI-processing-pipeline-ENIGMA-OCD).

### Structure

 -  `1_create_input_features.py`                            Data preparation 
 -  `2_univariate_CBT_outcome_analyses.R`                   Univariate analyses
 -  `3_create_plots_univariate_sensitivity_analyses.R`      Plotting of univariate sensitivity analyses
 -  `4a_enigma-toolbox-Univariate_Schaefer200.py`           Univariate whole-brain cortical results visualization
 -  `4b_create_3D_niftis_Univariate_Melbourne32.sh`         Univariate whole-brain subcortical results prep for visualization 
 -  `4c_MRIcroGL_Univariate_render.py`                      Univariate whole-brain subcortical results visualization 
 -  `5_quantify_missing_activation_data.R`                  Quality control: missing data
 -  `6_ML_CBT_outcome_prediction.ipynb`                     Machine learning analyses
 -  `7_demographic_tables.R`                                Demographic data tables
 -  `9_ML_plotting.R`                                       Machine learning results visualization
   
 `bayesian_analyses/`                                       Bayesian analyses and data visualization

 -  `1-1a_syntax_RBA_ROI.sh`                                Bayesian ROI analysis syntax
 -  `1-1b_syntax_RBA_ROI_COMBAT.sh`                         Bayesian ROI analysis syntax - COMBAT-corrected
 -  `2-1c_submit_sbatch_RBA_ROI.sh`                         Bayesian ROI analysis submission script
 -  `2-2a_syntax_RBA_whole-brain.sh`                        Bayesian whole-brain analysis syntax
 -  `2-2b_syntax_RBA_whole-brain_COMBAT.sh`                 Bayesian whole-brain analysis syntax - COMBAT-corrected
 -  `2-2c_submit_sbatch_RBA_whole-brain.sh`                 Bayesian whole-brain analysis submission script
 -  `3a_improve_RBA_ridge_plots_ROI.R`                      Bayesian ROI results visualization
 -  `3b_improve_RBA_ridge_plots_whole-brain.R`              Bayesian whole-brain results visualization 
 -  `3c_extract_P_plus_values_SchaeferMelbourne_from_RBA_output.R`  Bayesian whole-brain cortical results prep for visualization 
 -  `3d_enigma-toolbox-RBA_Schaefer200.py`                  Bayesian whole-brain cortical results visualization 
 -  `3e_create_3D_niftis_RBA_Melbourne32.sh`                Bayesian ROI subcortical results prep visualization
 -  `3f_MRIcroGL_render.py`                                 Bayesian ROI subcortical results visualization 
   
### Acknowledgements 

The ENIGMA-Obsessive Compulsive Disorder Working-Group gratefully acknowledges support from the International Obsessive-Compulsive Disorder Foundation with the Innovator Award of 2021 awarded to Odile van den Heuvel and Chris Vriend. 

### Authors
Laurens van den Mortel and Nadza Dzinalija

### References

- [Preprint on MedRxiv.org](https://doi.org/10.64898/2026.03.13.26348316)
```
Džinalija, N., van den Heuvel, O. A., Simpson, H. B., Ivanov, I., Alonso, P., Bertolin, S., Bruin, W., Fortea, L., Fullana, M. A., Hagen, K., Hansen, B., Huijser, C., Kvale, G., Martinez-Zalacain, I., Menchon, J. M., Ousdal, O. T., Soriano-Mas, C., van der Straten, A. L., Thomopoulos, S. I., Thorsen, A. L., Vilajosana, E., ENIGMA-OCD Consortium, Stein, D. J., Thompson, P. M., Veer, I. M., Vriend, C., & van de Mortel, L. A. (2026). *Predicting cognitive-behavioral therapy outcomes in obsessive-compulsive disorder from inhibitory control neural activity: A mega-analysis and machine learning study from the ENIGMA-OCD consortium*. medRxiv. https://doi.org/10.64898/2026.03.13.26348316
```
