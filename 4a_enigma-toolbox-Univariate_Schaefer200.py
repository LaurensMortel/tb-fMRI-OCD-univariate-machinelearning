#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
N, Dzinalija, Oct 2023

Uses P+ values extracted from RBA output (using 4c_extract_P_plus_values_SchaeferMelbourne_from_RBA_output.R script) to 
plot Schaefer 200-parcels using enigma-toolbox onto cortical atlas

Activate enigma-toolbox using:
module load Anaconda3
conda activate /scratch/anw/share-np/enigma_toolbox 

"""


import os
import glob
import numpy as np
import pandas as pd
import nibabel as nib
import enigmatoolbox
from enigmatoolbox.utils.parcellation import parcel_to_surface
from enigmatoolbox.plotting import plot_cortical
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors
import matplotlib.cm as cm


# Define custom colormap colors and boundaries and create a ListedColormap 
custom_red = (0.403921568627451, 0.0, 0.12156862745098039, 1.0)
custom_blue = (0.0196078431372549, 0.18823529411764706, 0.3803921568627451, 1.0)
colors = [(0, 'white'),(0.0001, custom_blue), (0.05, 'cyan'), (0.05, 'grey'),(0.95, 'grey'),(0.95, 'yellow'),(1,custom_red)]
custom_cmap = mcolors.LinearSegmentedColormap.from_list('custom_cmap', colors, N=10000)
cm.unregister_cmap('RBA_color_scheme_cmap')
cm.register_cmap(name='RBA_color_scheme_cmap', cmap=custom_cmap)

# Read in Schaefer 200 atlas regions in the order they need to be in for enigma toolbox
df_S200=pd.read_csv('/data/anw/anw-work/NP/projects/data_ENIGMA_OCD/ENIGMA_TASK/analysis/Emotional_domain/ROIs/Schaefer_cortical_Melbourne_subcortx/Schaefer_200/Schaefer200_labels.txt', header=None,index_col=[0],usecols=[0],delim_whitespace=True)

base_dir='/data/anw/anw-work/NP/projects/data_ENIGMA_OCD/ENIGMA_TASK/analysis/CBT_response/Regression_results'

#create mask to exclude subcortical regions
fsa5_lh_mask=pd.read_csv('/scratch/anw/share-np/enigma_toolbox/ENIGMA/enigmatoolbox/datasets/surfaces/fsa5_lh_mask.csv',header=None)
fsa5_rh_mask=pd.read_csv('/scratch/anw/share-np/enigma_toolbox/ENIGMA/enigmatoolbox/datasets/surfaces/fsa5_rh_mask.csv',header=None)
combined_masks = np.concatenate((fsa5_lh_mask, fsa5_rh_mask), axis=0)
combined_masks = np.array(combined_masks, dtype=bool)
combined_masks=combined_masks.reshape(-1)


for atlas in  ["Schaefer200"]:
    for contrast in ["INHIBITION","ERROR"]:
        for model in ["ResponderStatus","RemissionStatus","deltaYBOCS"]:
                file_path = os.path.join(base_dir)  
               
                os.chdir(file_path)
                
                pattern = f"{contrast}_{atlas}_{model}_COMBAT.csv"

                matching_files = glob.glob(os.path.join(base_dir, pattern))
                    
                if matching_files: 
                    for file in matching_files:
                        # Extract the desired portion of the filename
                        filename = os.path.basename(file)
                        basename = os.path.splitext(pattern)[0]  
                   
                        # load P-values from file
                        df = pd.read_csv(file,sep=",",header=0,usecols=["ROI", "T_value", "FDR_corr"],index_col="ROI") 
                        
                        # Compute “strength” of significance and directionality
                        sig_thresh = 0.05
                        df['FDR_scaled'] = 0.5
                        mask_pos = (df['T_value'] > 0) & (df['FDR_corr'] < sig_thresh)
                        df.loc[mask_pos, 'FDR_scaled'] = 1 - df.loc[mask_pos, 'FDR_corr']
                        mask_neg = (df['T_value'] < 0) & (df['FDR_corr'] < sig_thresh)
                        df.loc[mask_neg, 'FDR_scaled'] = df.loc[mask_neg, 'FDR_corr']

                        # Merge df_reset with df_S200 on column 1
                        merged_df = df_S200.merge(df[['FDR_scaled']], left_on=[0], right_on=['ROI'])
                            
                        # You can drop the additional column 1 if you don't need it
                        merged_df=merged_df.set_index(['key_0'])
                        S200Pplus=merged_df.to_numpy().reshape(-1)
                                                
                        # impute very low P+ value in case of 0 value
                        S200Pplus[S200Pplus<0.01]=0.01
                            
                        # Map parcellated data to the surface
                        Plus_d_fsa5 = parcel_to_surface(S200Pplus, 'schaefer_200_fsa5',mask=combined_masks,fill=0)
                            
                        # Project the results on the surface brain
                        plot_cortical(array_name=Plus_d_fsa5, surface_name="fsa5", size=(1600, 800),
                                    cmap='RBA_color_scheme_cmap',color_bar=True, color_range=(0.0, 1.0),
                                    screenshot=True,transparent_bg=False,filename=f'{basename}_enigma_toolbox.jpg')


# Create a colorbar with custom ticks and title
colorbar_ticks = [0, 0.1, 0.9, 1]
cmap = plt.get_cmap('RBA_color_scheme_cmap')  # Use the same colormap as the figure
norm = mcolors.Normalize(vmin=0, vmax=1)  # Normalize the colorbar to the same range
sm = plt.cm.ScalarMappable(cmap=cmap, norm=norm)
sm.set_array([])  # Dummy array for the ScalarMappable

cbar_ax = plt.gcf().add_axes([0.92, 0.15, 0.02, 0.7])  # Adjust position and size
cbar = plt.colorbar(sm, cax=cbar_ax, ticks=colorbar_ticks)
cbar.set_label('')  # Clear the default label
cbar_ax.text(0.5, 1.05, 'P+', horizontalalignment='center', verticalalignment='center', transform=cbar_ax.transAxes)

os.chdir(base_dir)
plt.savefig(f'{pattern}_enigma_toolbox_colorbar.jpg', dpi=300, bbox_inches='tight')
plt.show()
