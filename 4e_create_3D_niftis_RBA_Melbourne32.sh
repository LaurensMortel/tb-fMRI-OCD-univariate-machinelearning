#!/bin/bash

# N, Dzinalija, Oct 2023

# Creates single 3D nifti image of all regions in Melbourne 32-region (Scale 2) Subcortical atlas
# for easier visualisation (not with ENIGMA toolbox but with MRIcroGL)

module load fsl

base_dir=/data/anw/anw-work/NP/projects/data_ENIGMA_OCD/ENIGMA_TASK/analysis/CBT_response/RBA/Whole-brain
Melbourne_dir=/data/anw/anw-work/NP/projects/data_ENIGMA_OCD/ENIGMA_TASK/analysis/Emotional_domain/ROIs/Melbourne/Melbourne32
left_hem=/data/anw/anw-work/NP/projects/data_ENIGMA_OCD/MNI152NLin2009/MNI152NLin2009cAsym/tpl-MNI152NLin2009cAsym_res-02_desc-brain_T1w_binarized_left_hemisphere.nii.gz
right_hem=/data/anw/anw-work/NP/projects/data_ENIGMA_OCD/MNI152NLin2009/MNI152NLin2009cAsym/tpl-MNI152NLin2009cAsym_res-02_desc-brain_T1w_binarized_right_hemisphere.nii.gz

for atlas in 200; do
    for contrast in INHIBITION ERROR; do
        for model in response remission deltaYBOCS; do
            for directory in ${base_dir}/Schaefer${atlas}/${contrast}/${model} ${base_dir}/Schaefer${atlas}/${contrast}/${model}/COMBAT; do
            #for directory in ${base_dir}/Schaefer${atlas}/${contrast}/${model}; do

                cd ${directory}
                mkdir -p Subcortical
                subcortical_dir=${directory}/Subcortical

                matching_files=(*_P_plus_values.csv)

                if [ ${#matching_files[@]} -gt 0 ]; then
                    for file in ${matching_files[@]}; do

                        P_plus_file=$(basename ${file})
                        label="${P_plus_file%_P_plus_values.csv}"
                        mkdir -p ${subcortical_dir}/${label}
                            
                        # multiply ROI nifti by P plus value
                        # Skip the first line (header) of P_plus_file
                        tail -n +2 "${P_plus_file}" | while IFS=',' read -r ROI P_plus_value; do
                            
                            ROI="${ROI//\"/}"
                            nifti_file=${Melbourne_dir}/${ROI}.nii.gz
                            if [[ -f ${nifti_file} ]]; then
                                # if P_plus_value is so low that its rounded down to 0 then nothing gets graphed, so need to replace for a low value instead
                                if (( $(echo "$P_plus_value < 0.01" | bc -l) )); then 
                                    P_plus_value=0.01
                                fi
                                    
                                fslmaths ${nifti_file} -mul ${P_plus_value} ${subcortical_dir}/${label}/${ROI}_P_plus.nii.gz
                            fi

                        done
                            
                        # create single 3D image from all ROI niftis
                        roi_files=($(find ${subcortical_dir}/${label} -type f -name "*.nii.gz"))

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
                            
                    done 

                        
                fi
            done
        done                                                                                      
    done
done

