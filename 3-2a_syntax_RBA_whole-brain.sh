#!/bin/bash

#SBATCH --job-name=RBA_whole-brain
#SBATCH --mem=4G
#SBATCH --partition=luna-cpu-long
#SBATCH --qos=anw-cpu-big
#SBATCH --cpus-per-task=32
#SBATCH --time=1-0:00:00

### N.Dzinalija VUmc 2023
### After 7_create_RBA_input_models.R has run, the resulting input RBA .txt files for each contrast
### and model are fed to this script through the 8-3b_submit_sbatch_RBA_ROI_whole-brain.sh 

export APPTAINER_BIND="/data/anw/anw-work,/scratch"

contrast=${1}
model=${2}
group=${3}
atlas=${4}

RBA_dir=/scratch/anw/nddzinalija/CBT_RBA/Whole-brain
RBA_input=/scratch/anw/nddzinalija/RBA_input/RBA_input_${contrast}_Schaefer200_${model}.txt

cd ${RBA_dir}
mkdir -p Schaefer200
cd Schaefer200
mkdir -p ${contrast}
cd ${contrast}
mkdir -p ${model}
cd ${model}

if [ ${model} == "response" ]; then
  covariatesC=\"Sample,ResponderStatus,SEX\"
  covariatesQ=\"AGE\"
  standardize=\"AGE\"
  statmodel=\"1+Sample+ResponderStatus+SEX+AGE\"
  EofI=\"Intercept,ResponderStatus\"
elif [ ${model} == "remission" ]; then
  covariatesC=\"Sample,RemissionStatus,SEX\"
  covariatesQ=\"AGE\"
  standardize=\"AGE\"
  statmodel=\"1+Sample+RemissionStatus+SEX+AGE\"
  EofI=\"Intercept,RemissionStatus\"
elif [ ${model} == "deltaYBOCS" ]; then
  covariatesC=\"Sample,SEX\"
  covariatesQ=\"AGE,deltaYBOCS,SevYBOCS_pre\"
  standardize=\"AGE,deltaYBOCS,SevYBOCS_pre\"
  statmodel=\"1+Sample+deltaYBOCS+SevYBOCS_pre+SEX+AGE\"
  EofI=\"deltaYBOCS\"
else
  echo "Invalid model input. Supported values are 'response', 'remission', and 'deltaYBOCS'."
fi

eval "apptainer run /scratch/anw/share-np/AFNIr RBA \
-prefix Schaefer200_${contrast}_${model} \
-chains 4 \
-iterations 4000 \
-dataTable ${RBA_input} \
-cVars ${covariatesC} \
-qVars ${covariatesQ} \
-stdz ${standardize} \
-scale 10 \
-model ${statmodel} \
-EOI ${EofI} \
-ridgePlot 40 30  \
-WCP 6 \
-MD \
-verb 1"
