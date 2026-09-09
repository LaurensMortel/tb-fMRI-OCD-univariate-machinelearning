# N, Dzinalija Jan 2024
# Script to create subcortical figure views in MRIcroGL, can only be run on Remote Desktop in MRIcroGL, not Luna.
# This script needs to be copy-pasted into MRIcroGL>Scripting and run  by command+R

# IMPORTANT: As the script essentially takes a screenshot of the viewing window in MRIcroGL, 
# remember to scroll to make the image as zoomed in as possible

# To obtain the coloring used in RBA, there is a rbacol.clut file that should be in the same directory as 
# this script and should be pasted into the \MRIcron\Resources\lut folder to make it findable by the script 

import gl

contrasts = ['INHIBITION', 'ERROR']
models = ['deltaYBOCS', 'remission', 'response']
sides = ['left', 'right']
subfolders = ['Subcortical', 'COMBAT\\Subcortical']

base_path = 'Z:\\01_projects\\21_Task-fMRI_in preparation\\CBT_response\\Results\\RBA\\Whole-brain\\Schaefer200'

for contrast in contrasts:
    for model in models:
        
        if model == 'response':
            submodels = ['Intercept', 'ResponderStatus-1-vs-0']
        elif model == 'remission':
            submodels = ['Intercept', 'RemissionStatus-1-vs-0']
        else:
            submodels = [None]  

        for submodel in submodels:
            for side in sides:
                for subfolder in subfolders:
                    gl.resetdefaults()

                    if model in ('response', 'remission'):
                        filename = "{base_path}\\{contrast}\\{model}\\{subfolder}\\{contrast}_{submodel}_Melbourne32_3D.nii.gz".format(
                            base_path=base_path, contrast=contrast, model=model, subfolder=subfolder, submodel=submodel
                        )
                        overlay_filename = "{base_path}\\{contrast}\\{model}\\{subfolder}\\{contrast}_{submodel}_Melbourne32_3D_{side}.nii.gz".format(
                            base_path=base_path, contrast=contrast, model=model, subfolder=subfolder, submodel=submodel, side=side
                        )
                    elif model == 'deltaYBOCS':
                        filename = "{base_path}\\{contrast}\\{model}\\{subfolder}\\{contrast}_{model}_Melbourne32_3D.nii.gz".format(
                            base_path=base_path, contrast=contrast, model=model, subfolder=subfolder
                        )
                        overlay_filename = "{base_path}\\{contrast}\\{model}\\{subfolder}\\{contrast}_{model}_Melbourne32_3D_{side}.nii.gz".format(
                            base_path=base_path, contrast=contrast, model=model, subfolder=subfolder, side=side
                        )

                    gl.windowposition(0, 0,1414,955)
                    gl.loadimage(filename)
                    gl.overlayload(overlay_filename)  
                    gl.minmax(0, 1, 5)
                    gl.minmax(1, 0, 1) 
                    gl.colorname(1, "rbacol")
                    gl.shadername('Glass')
                    gl.backcolor(255, 255, 255)
                    gl.zerointensityinvisible(1,1)
                    gl.viewsagittal(0)
                    gl.bmpzoom(2)
                    gl.savebmp(overlay_filename + '_view1.jpg')
                    gl.viewsagittal(1)
                    gl.bmpzoom(2)
                    gl.savebmp(overlay_filename + '_view2.jpg')
