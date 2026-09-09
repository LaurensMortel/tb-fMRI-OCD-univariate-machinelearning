#!/bin/bash

# N, Dzinalija, Oct 2023

# Creates single 3D nifti image of all regions in Melbourne 32-region (Scale 2) Subcortical atlas
# for easier visualisation (not with ENIGMA toolbox but with MRIcroGL)

module load fsl

base_dir=/data/anw/anw-work/NP/projects/data_ENIGMA_OCD/ENIGMA_TASK/analysis/CBT_response/Regression_results
Melbourne_dir=/scratch/anw/nddzinalija/Original_names
left_hem=/data/anw/anw-work/NP/projects/data_ENIGMA_OCD/MNI152NLin2009/MNI152NLin2009cAsym/tpl-MNI152NLin2009cAsym_res-02_desc-brain_T1w_binarized_left_hemisphere.nii.gz
right_hem=/data/anw/anw-work/NP/projects/data_ENIGMA_OCD/MNI152NLin2009/MNI152NLin2009cAsym/tpl-MNI152NLin2009cAsym_res-02_desc-brain_T1w_binarized_right_hemisphere.nii.gz

for atlas in 200; do
    for contrast in INHIBITION ERROR; do
        for model in ResponderStatus RemissionStatus deltaYBOCS; do
            for file in ${base_dir}/${contrast}_Schaefer${atlas}_${model}_COMBAT.csv; do

                if [[ -f "$file" ]]; then
                    mkdir -p ${base_dir}/${contrast}
                    mkdir -p ${base_dir}/${contrast}/${model}
                    mkdir -p ${base_dir}/${contrast}/${model}/Subcortical
                    subcortical_dir=${base_dir}/${contrast}/${model}/Subcortical
                
                    label="$(basename "${file%.csv}")"
                            
                    # multiply ROI nifti by P value
                    # Skip the first line (header) of P values file
                    tail -n +2 "${file}" | while IFS=',' read -r idx ROI T_value DF p_value Cohen_d Bonferoni_corr FDR_corr; do
                            
                        ROI="${ROI//\"/}"
                        nifti_file=${Melbourne_dir}/${ROI}.nii.gz
                        if [[ -f ${nifti_file} ]]; then
                            # if FDR_corr value is so low that its rounded down to 0 then nothing gets graphed, so need to replace for a low value instead
                            if (( $(echo "$FDR_corr < 0.01" | bc -l) )); then 
                                FDR_corr=0.01
                            fi
                                    
                            fslmaths ${nifti_file} -mul ${FDR_corr} ${subcortical_dir}/${ROI}_FDR_corr.nii.gz
                        fi

                    done
                            
                    # create single 3D image from all ROI niftis
                    roi_files=($(find ${subcortical_dir} -type f -name "*.nii.gz"))

                    base_roi=${roi_files[0]}
                    for ((i = 1; i < ${#roi_files[@]}; i++)); do
                        fslmaths ${base_roi} -add ${roi_files[i]} ${base_roi}
                    done

                    mv ${base_roi} ${subcortical_dir}/${label}_Melbourne32_3D.nii.gz
                    echo "${label}_Melbourne32_3D.nii.gz created"
                            
                    # multiply 3D image by each hemispheres mask to make it easier to get medial views of subcortex
                    fslmaths ${subcortical_dir}/${label}_Melbourne32_3D.nii.gz -mul ${left_hem} ${subcortical_dir}/${label}_Melbourne32_3D_left.nii.gz
                    fslmaths ${subcortical_dir}/${label}_Melbourne32_3D.nii.gz -mul ${right_hem} ${subcortical_dir}/${label}_Melbourne32_3D_right.nii.gz

                    echo "... and right and left hemispheres extracted" 
                            
                fi         
            done
        done                                                                                      
    done
done

