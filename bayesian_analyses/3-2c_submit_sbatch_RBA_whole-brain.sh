#!/bin/bash

### N.Dzinalija VUmc 2023
### The 3-2a_syntax_RBA_whole-brain.sh and 3-2b_syntax_RBA_whole-brain_COMBAT.sh scripts are run 
### for each model of each contrast

scriptdir=/scratch/anw/nddzinalija

for contrast in INHIBITION ERROR; do

    for model in remission response deltaYBOCS; do

        sbatch --output RBA_Schaefer200_${contrast}_${model}.log ${scriptdir}/3-2a_syntax_RBA_whole-brain.sh ${contrast} ${model} 
        sbatch --output RBA_Schaefer200_${contrast}_${model}_COMBAT.log ${scriptdir}/3-2b_syntax_RBA_whole-brain_COMBAT.sh ${contrast} ${model}

    done

done
