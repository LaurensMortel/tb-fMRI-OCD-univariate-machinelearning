# N, Dzinalija Jan 2024
# Script to create subcortical figure views in MRIcroGL, can only be run on Remote Desktop in MRIcroGL, not Luna.
# This script needs to be copy-pasted into MRIcroGL>Scripting and run  by command+R

# IMPORTANT: As the script essentially takes a screenshot of the viewing window in MRIcroGL, 
# remember to scroll to make the image as zoomed in as possible

# To obtain the coloring used in RBA, there is a rbacol.clut file that should be in the same directory as 
# this script and should be pasted into the \MRIcron\Resources\lut folder to make it findable by the script 

import gl

contrasts = ['INHIBITION', 'ERROR']
models = ['deltaYBOCS', 'RemissionStatus', 'ResponderStatus']
sides = ['left', 'right']

base_path = 'Z:\\01_projects\\21_Task-fMRI_in preparation\\CBT_response\\Results\\Univariate'

for contrast in contrasts:
    for model in models:
        for side in sides:
            gl.resetdefaults()
 
            filename = "{base_path}\\{contrast}\\{model}\\Whole-brain\\Subcortical\\{contrast}_Schaefer200_{model}_COMBAT_Melbourne32_3D.nii.gz".format(
                base_path=base_path, contrast=contrast, model=model
                )
            overlay_filename = "{base_path}\\{contrast}\\{model}\\Whole-brain\\Subcortical\\{contrast}_Schaefer200_{model}_COMBAT_Melbourne32_3D_{side}.nii.gz".format(
                base_path=base_path, contrast=contrast, model=model, side=side
            )

            gl.windowposition(0, 0,1414,955)
            gl.loadimage(filename)
            gl.overlayload(overlay_filename)  
            gl.minmax(0, 1, 5)
            gl.minmax(1, 0, 1) 
            gl.colorname(1, "Pvalcol")
            gl.shadername('Glass')
            gl.backcolor(255, 255, 255)
            gl.zerointensityinvisible(1,1)
            gl.viewsagittal(0)
            gl.bmpzoom(2)
            gl.savebmp(overlay_filename + '_view1.jpg')
            gl.viewsagittal(1)
            gl.bmpzoom(2)
            gl.savebmp(overlay_filename + '_view2.jpg')
