### Nadza Dzinalija Sept 2023

### After whole-brain RBA has run, takes .RData files that have been output and produces improved ridgeplots with ROIs in custom order
### with custom labels. 

### Works together with ridge_alphabet_whole_brain.R function that should be in the same folder
### Only difference with ridge_alphabet.R and 9b_improve_RBA_ridge_plots_ROI.R scripts is the size of the text and plot

# To troubleshoot:
# Step 1: inspect first the 'input' variable that is made in the for loop below
# Step 2: the colnames(input) should have the custom names you want the ROIs to have
#         IMPORTANT: this should be in the order in which they appear in RBA, NOT the order you want them to have        

library(gtools)

setwd("/data/anw/anw-work/NP/projects/data_ENIGMA_OCD/ENIGMA_TASK/scripts/CBT_response")

source("ridge_alphabet_whole_brain.R")

#load in original order of ROIs, otherwise find at bottom of script
rois_orignal_order <- read.csv("Whole-brain_parcels_original_order.csv", header = FALSE)$V1


for (contrast in c("INHIBITION","ERROR")){
  
  for (model in c("response", "remission", "deltaYBOCS")){
    
      directories <- c(paste0("/data/anw/anw-work/NP/projects/data_ENIGMA_OCD/ENIGMA_TASK/analysis/CBT_response/RBA/Whole-brain/Schaefer200/", contrast, "/", model),
      paste0("/data/anw/anw-work/NP/projects/data_ENIGMA_OCD/ENIGMA_TASK/analysis/CBT_response/RBA/Whole-brain/Schaefer200/", contrast, "/", model,"/COMBAT"))
      
      for (dir in directories){
        if (file.exists(dir)){
          setwd(dir)
        
          Rdatafile<-list.files(pattern = ".RData")
          load(Rdatafile)
          
          if(any(!is.na(lop$EOIq) == TRUE)){
            
            # For continuous data
            input <- ps0
            input <- input[,mixedorder(rois_orignal_order)]
            newcolnames<-paste(seq_along(colnames(input)),colnames(input),sep="-")
            colnames(input)<-newcolnames
            label <- paste0(contrast,"_",lop$EOIq)
            ridge_alphabet(input,labx=label,range_file=NULL,xlim=NULL,wi=12,hi=49)
            
            # For categorical data
          } 
          
          if (any(!is.na(lop$EOIc) == TRUE)) for(ii in 1:length(lop$EOIc)) {
            for(jj in 1:(nl-1)) for(kk in (jj+1):nl) {
              if (lvl[jj] == "0"){
                input <- psa[kk,,] - psa[jj,,]
                label <- paste0(contrast,"_", lop$EOIc[ii], '-', lvl[kk], '-vs-', lvl[jj])
              } else {
                input <- psa[jj,,] - psa[kk,,]
                label <- paste0(contrast, "_", lop$EOIc[ii], '-', lvl[jj], '-vs-', lvl[kk])
              }
                input <- input[,mixedorder(rois_orignal_order)]
                newcolnames<-paste(seq_along(colnames(input)),colnames(input),sep="-")
                colnames(input)<-newcolnames
                ridge_alphabet(input,labx=label,range_file=NULL,xlim=NULL,wi=12,hi=49)
          }
        }
      }
    }
  }
}




### In case of lost order list: 
rois <- c(
  "Amygdala Lat L", "Amygdala Lat R", "Amygdala Med L", "Amygdala Med R", 
  "Caudate Ant L", "Caudate Ant R", "Caudate Post L", "Caudate Post R", 
  "Control Cing 1 L", "Control Cing 1 R", "Control Cing 2 L", "Control Cing 2 R", 
  "Control OFC 1 L", "Control PFCl 1 L", "Control PFCl 1 R", "Control PFCl 2 L", 
  "Control PFCl 2 R", "Control PFCl 3 L", "Control PFCl 3 R", "Control PFCl 4 L", 
  "Control PFCl 4 R", "Control PFCl 5 L", "Control PFCl 5 R", "Control PFCl 6 R", 
  "Control PFCl 7 R", "Control PFCmp 1 R", "Control PFCmp 2 R", "Control PFCv 1 R", 
  "Control Par 1 L", "Control Par 1 R", "Control Par 2 L", "Control Par 2 R", 
  "Control Par 3 L", "Control Par 3 R", "Control Temp 1 L", "Control Temp 1 R", 
  "Control pCun 1 L", "Control pCun 1 R", "Default PFC 1 L", "Default PFC 10 L", 
  "Default PFC 11 L", "Default PFC 12 L", "Default PFC 13 L", "Default PFC 2 L", 
  "Default PFC 3 L", "Default PFC 4 L", "Default PFC 5 L", "Default PFC 6 L", 
  "Default PFC 7 L", "Default PFC 8 L", "Default PFC 9 L", "Default PFCdPFCm 1 R", 
  "Default PFCdPFCm 2 R", "Default PFCdPFCm 3 R", "Default PFCdPFCm 4 R", 
  "Default PFCdPFCm 5 R", "Default PFCdPFCm 6 R", "Default PFCdPFCm 7 R", 
  "Default PFCv 1 R", "Default PHC 1 L", "Default Par 1 L", "Default Par 1 R", 
  "Default Par 2 L", "Default Par 2 R", "Default Par 3 L", "Default Par 3 R", 
  "Default Par 4 L", "Default Temp 1 L", "Default Temp 1 R", "Default Temp 2 L", 
  "Default Temp 2 R", "Default Temp 3 L", "Default Temp 3 R", "Default Temp 4 L", 
  "Default Temp 4 R", "Default Temp 5 L", "Default Temp 5 R", "Default pCunPCC 1 L", 
  "Default pCunPCC 1 R", "Default pCunPCC 2 L", "Default pCunPCC 2 R", 
  "Default pCunPCC 3 L", "Default pCunPCC 3 R", "Default pCunPCC 4 L", 
  "Dorsal Attention FEF 1 L", "Dorsal Attention FEF 1 R", "Dorsal Attention FEF 2 L", 
  "Dorsal Attention FEF 2 R", "Dorsal Attention Post 1 L", "Dorsal Attention Post 1 R", 
  "Dorsal Attention Post 10 L", "Dorsal Attention Post 10 R", "Dorsal Attention Post 2 L", 
  "Dorsal Attention Post 2 R", "Dorsal Attention Post 3 L", "Dorsal Attention Post 3 R", 
  "Dorsal Attention Post 4 L", "Dorsal Attention Post 4 R", "Dorsal Attention Post 5 L", 
  "Dorsal Attention Post 5 R", "Dorsal Attention Post 6 L", "Dorsal Attention Post 6 R", 
  "Dorsal Attention Post 7 L", "Dorsal Attention Post 7 R", "Dorsal Attention Post 8 L", 
  "Dorsal Attention Post 8 R", "Dorsal Attention Post 9 L", "Dorsal Attention Post 9 R", 
  "Dorsal Attention PrCv 1 L", "Dorsal Attention PrCv 1 R", "Globus Pallidus Ant L", 
  "Globus Pallidus Ant R", "Globus Pallidus Post L", "Globus Pallidus Post R", 
  "Hippocampus Ant L", "Hippocampus Ant R", "Hippocampus Post L", "Hippocampus Post R", 
  "Limbic OFC 1 L", "Limbic OFC 1 R", "Limbic OFC 2 L", "Limbic OFC 2 R", 
  "Limbic OFC 3 R", "Limbic TempPole 1 L", "Limbic TempPole 1 R", "Limbic TempPole 2 L", 
  "Limbic TempPole 2 R", "Limbic TempPole 3 L", "Limbic TempPole 3 R", 
  "Limbic TempPole 4 L", "Nucleus Accumbens core L", "Nucleus Accumbens core R", 
  "Nucleus Accumbens shell L", "Nucleus Accumbens shell R", "Putamen Ant L", 
  "Putamen Ant R", "Putamen Post L", "Putamen Post R", 
  "Salience / Ventral Attention FrOperIns 1 L", "Salience / Ventral Attention FrOperIns 1 R", 
  "Salience / Ventral Attention FrOperIns 2 L", "Salience / Ventral Attention FrOperIns 2 R", 
  "Salience / Ventral Attention FrOperIns 3 L", "Salience / Ventral Attention FrOperIns 3 R", 
  "Salience / Ventral Attention FrOperIns 4 L", "Salience / Ventral Attention FrOperIns 4 R", 
  "Salience / Ventral Attention Med 1 L", "Salience / Ventral Attention Med 1 R", 
  "Salience / Ventral Attention Med 2 L", "Salience / Ventral Attention Med 2 R", 
  "Salience / Ventral Attention Med 3 L", "Salience / Ventral Attention Med 3 R", 
  "Salience / Ventral Attention PFCl 1 L", "Salience / Ventral Attention ParOper 1 L", 
  "Salience / Ventral Attention ParOper 2 L", "Salience / Ventral Attention ParOper 3 L", 
  "Salience / Ventral Attention PrC 1 R", "Salience / Ventral Attention TempOccPar 1 R", 
  "Salience / Ventral Attention TempOccPar 2 R", "Salience / Ventral Attention TempOccPar 3 R", 
  "Somatomotor 1 L", "Somatomotor 1 R", "Somatomotor 10 L", "Somatomotor 10 R", 
  "Somatomotor 11 L", "Somatomotor 11 R", "Somatomotor 12 L", "Somatomotor 12 R", 
  "Somatomotor 13 L", "Somatomotor 13 R", "Somatomotor 14 L", "Somatomotor 14 R", 
  "Somatomotor 15 L", "Somatomotor 15 R", "Somatomotor 16 L", "Somatomotor 16 R", 
  "Somatomotor 17 R", "Somatomotor 18 R", "Somatomotor 19 R", "Somatomotor 2 L", 
  "Somatomotor 2 R", "Somatomotor 3 L", "Somatomotor 3 R", "Somatomotor 4 L", 
  "Somatomotor 4 R", "Somatomotor 5 L", "Somatomotor 5 R", "Somatomotor 6 L", 
  "Somatomotor 6 R", "Somatomotor 7 L", "Somatomotor 7 R", "Somatomotor 8 L", 
  "Somatomotor 8 R", "Somatomotor 9 L", "Somatomotor 9 R", "Thalamus DorsoAnt L", 
  "Thalamus DorsoAnt R", "Thalamus DorsopPost L", "Thalamus DorsopPost R", 
  "Thalamus VentroAnt L", "Thalamus VentroAnt R", "Thalamus VentroPost L", 
  "Thalamus VentroPost R", "Visual 1 L", "Visual 1 R", "Visual 10 L", 
  "Visual 10 R", "Visual 11 L", "Visual 11 R", "Visual 12 L", "Visual 12 R", 
  "Visual 13 L", "Visual 13 R", "Visual 14 L", "Visual 14 R", "Visual 15 R", 
  "Visual 2 L", "Visual 2 R", "Visual 3 L", "Visual 3 R", "Visual 4 L", 
  "Visual 4 R", "Visual 5 L", "Visual 5 R", "Visual 6 L", "Visual 6 R", 
  "Visual 7 L", "Visual 7 R", "Visual 8 L", "Visual 8 R", "Visual 9 L", 
  "Visual 9 R"
)

