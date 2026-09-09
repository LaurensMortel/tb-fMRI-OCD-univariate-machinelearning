#!/bin/bash

#SBATCH --job-name=RBA
#SBATCH --mem=4G
#SBATCH --partition=luna-cpu-long
#SBATCH --qos=anw-cpu-big
#SBATCH --cpus-per-task=32
#SBATCH --time=07-0:00:00

### N.Dzinalija VUmc 2023
### After 7_create_RBA_input_models.R has run, the resulting input RBA .txt files for each contrast
### and model are fed to this script through the 8-1b_submit_sbatch_RBA_ROI.sh 

# can run with 4 threads per chain
export APPTAINER_BIND="/data/anw/anw-work,/scratch"

contrast=${1}
model=${2}

RBA_dir=/scratch/anw/nddzinalija/CBT_RBA/ROI
RBA_input=/scratch/anw/nddzinalija/RBA_input/RBA_input_${contrast}_ROI_${model}_COMBAT.txt

cd ${RBA_dir}
mkdir -p ${contrast}
cd ${contrast}
mkdir -p ${model}
cd ${model}
mkdir -p COMBAT
cd COMBAT

if [ ${model} == "response" ]; then
  covariatesC=\"ResponderStatus,SEX\"
  covariatesQ=\"AGE\"
  standardize=\"AGE\"
  statmodel=\"1+ResponderStatus+SEX+AGE\"
  EofI=\"Intercept,ResponderStatus\"
elif [ ${model} == "remission" ]; then
  covariatesC=\"RemissionStatus,SEX\"
  covariatesQ=\"AGE\"
  standardize=\"AGE\"
  statmodel=\"1+RemissionStatus+SEX+AGE\"
  EofI=\"Intercept,RemissionStatus\"
elif [ ${model} == "deltaYBOCS" ]; then
  covariatesC=\"SEX\"
  covariatesQ=\"AGE,deltaYBOCS,SevYBOCS_pre\"
  standardize=\"AGE,deltaYBOCS,SevYBOCS_pre\"
  statmodel=\"1+deltaYBOCS+SevYBOCS_pre+SEX+AGE\"
  EofI=\"deltaYBOCS\"
else
  echo "Invalid model input. Supported values are 'response', 'remission', and 'deltaYBOCS'."
fi

eval "apptainer run /scratch/anw/share-np/AFNIr RBA \
-prefix ${contrast}_${model} \
-chains 8 \
-iterations 4000 \
-dataTable ${RBA_input} \
-cVars ${covariatesC} \
-qVars ${covariatesQ} \
-stdz ${standardize} \
-scale 10 \
-distROI 'student' \
-model ${statmodel} \
-EOI ${EofI} \
-ridgePlot 40 30  \
-WCP 4 \
-PDP 4 3 \
-MD \
-verb 1"
