# Predicting cognitive-behavioral therapy outcomes in obsessive-compulsive disorder from inhibitory control neural activity: A mega-analysis and machine learning study from the ENIGMA-OCD consortium

This repository accompanies the ENIGMA-OCD manuscript available in [this preprint](https://www.medrxiv.org/content/10.64898/2026.03.13.26348316v1) on MedRxiv. It contains all scripts used for multimodal data preprocessing and quality control.

### Structure

 -  `1_create_input_features.py`
 -  `2_univariate_CBT_response_analyses.R`
 -  `2-1_create_plots_univariate_sensitivity_analyses.R`
 -  `3-1a_syntax_RBA_ROI.sh`
 -  `3-1b_syntax_RBA_ROI_COMBAT.sh`
 -  `3-1c_submit_sbatch_RBA_ROI.sh`
 -  `3-2a_syntax_RBA_whole-brain.sh`
 -  `3-2b_syntax_RBA_whole-brain_COMBAT.sh`
 -  `3-2c_submit_sbatch_RBA_whole-brain.sh`
 -  `4a_improve_RBA_ridge_plots_ROI.R`
 -  `4b_improve_RBA_ridge_plots_whole-brain.R`
 -  `4c_extract_P_plus_values_SchaeferMelbourne_from_RBA_output.R`
 -  `4d_enigma-toolbox-RBA_Schaefer200.py`
 -  `4e_create_3D_niftis_RBA_Melbourne32.sh`
 -  `4f_MRIcroGL_render.py`
 -  `4g_enigma-toolbox-Univariate_Schaefer200.py`
 -  `4h_create_3D_niftis_Univariate_Melbourne32.sh`
 -  `4i_MRIcroGL_Univariate_render.py`
 -  `5_quantify_missing_activation_data.R`
 -  `6_demographic_tables.R`
 -  `7_tb-fMRI-predict-outcome.ipynb`
 -  `8_ML_plotting.R`
   
### Acknowledgements 

The ENIGMA-Obsessive Compulsive Disorder Working-Group gratefully acknowledges support from the International Obsessive-Compulsive Disorder Foundation with the Innovator Award of 2021 awarded to Odile van den Heuvel and Chris Vriend. 

### Authors
Laurens van den Mortel and Nadza Dzinalija

### References

- [Preprint on MedRxiv.org](https://doi.org/10.64898/2026.03.13.26348316)
```
Džinalija, N., van den Heuvel, O. A., Simpson, H. B., Ivanov, I., Alonso, P., Bertolin, S., Bruin, W., Fortea, L., Fullana, M. A., Hagen, K., Hansen, B., Huijser, C., Kvale, G., Martinez-Zalacain, I., Menchon, J. M., Ousdal, O. T., Soriano-Mas, C., van der Straten, A. L., Thomopoulos, S. I., Thorsen, A. L., Vilajosana, E., ENIGMA-OCD Consortium, Stein, D. J., Thompson, P. M., Veer, I. M., Vriend, C., & van de Mortel, L. A. (2026). *Predicting cognitive-behavioral therapy outcomes in obsessive-compulsive disorder from inhibitory control neural activity: A mega-analysis and machine learning study from the ENIGMA-OCD consortium*. medRxiv. https://doi.org/10.64898/2026.03.13.26348316
```
