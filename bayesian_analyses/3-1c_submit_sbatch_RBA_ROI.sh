#!/bin/bash

### N.Dzinalija VUmc 2023
### The 3-1a_syntax_RBA_ROI.sh script is run 
### for each contrast and model using this script. 

scriptdir=/scratch/anw/nddzinalija

for contrast in INHIBITION ERROR; do 

    for model in response remission deltaYBOCS; do

        sbatch --output RBA_${contrast}_${model}.log ${scriptdir}/3-1a_syntax_RBA_ROI.sh ${contrast} ${model}
        sbatch --output RBA_${contrast}_${model}_COMBAT.log ${scriptdir}/3-1b_syntax_RBA_ROI_COMBAT.sh ${contrast} ${model}
        
    done
done
