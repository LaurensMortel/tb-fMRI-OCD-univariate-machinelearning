### Nadza Dzinalija Sept 2023

### NOTE: script works with R/4.1.3 (this is where all packages work correctly)

### After RBA has run, takes .RData files that have been output and produces improved ridgeplots with ROIs in custom order
### with custom labels. Other improvements (over ridgeplots output by RBA itself) are switching order of HC and OCD (if needed) 
### so patients are always graphed to the right, controls to the left of 0 trend line, and re-coloring ridges so that only
### strong evidence is in color and weaker evidence is grey.

### Works together with ridge_alphabet.R function that should be in the same folder and takes output of 9a_ROI_jackknife_raincloud_plots.R
### in form of range files containing range of P+ values in jackknife ROI analyses, to be added to figures here

# To troubleshoot:
# Step 1: inspect first the 'input' variable that is made in the for loop below
# Step 2: the colnames(input) should have the custom names you want the ROIs to have
#         IMPORTANT: this should be in the order in which they appear in RBA, NOT the order you want them to have        

setwd("~/my-scratch/data_ENIGMA_OCD/ENIGMA_TASK/scripts/CBT_response")

source("ridge_alphabet.R")

for (contrast in c("INHIBITION","ERROR")){  

  ROIfile <- read.csv(c(paste0("~/my-scratch/data_ENIGMA_OCD/ENIGMA_TASK/analysis/Inhibitory_domain/merged/",contrast,"/RBA_input_",contrast,"_ROI.txt")))
  ROIs <- sort(unique(ROIfile$ROI), method = "radix") # sort ROIs by current RBA sorting (uppercase first)
  ROIs <- gsub("_l$", " (L)", ROIs)
  ROIs <- gsub("_r$", " (R)", ROIs)
  ROIs <- gsub("_b$", " (B)", ROIs)
  ROIs <- gsub("Occipital", "Occ. lobe", ROIs)
  
  for (model in c("response", "remission", "deltaYBOCS")){
    
      directories <- c(paste0("~/my-scratch/data_ENIGMA_OCD/ENIGMA_TASK/analysis/CBT_response/RBA/ROI/", contrast, "/", model),
                       paste0("~/my-scratch/data_ENIGMA_OCD/ENIGMA_TASK/analysis/CBT_response/RBA/ROI/", contrast, "/", model,"/COMBAT"))
      
      for (dir in directories){
        if (file.exists(dir)){
          setwd(dir)
    
          Rdatafile<-list.files(pattern = ".RData")
          load(Rdatafile)
          
          if(any(!is.na(lop$EOIq) == TRUE)){
            
            #### For continuous data
            input <- ps0
            
            colnames(input) <- ROIs
            input <- input[,order(colnames(input))]
      
            # put a digit separated with a - before the ROI name to be able to sort them how you want with ridge_alphabet
            newcolnames<-paste(seq_along(colnames(input)),colnames(input),sep="-")
            colnames(input)<-newcolnames
            
            label <- paste0(contrast,"_",lop$EOIq)
                        
            range_file <- paste0(getwd(),"/Leave_one_site_out/",label,"_P_plus_range.csv")
    
            if (file.exists(range_file)) {
              ridge_alphabet(input, labx = label, range_file = range_file, xlim = NULL, wi = 12, hi = 14)
            } else {
                ridge_alphabet(input,labx=label,range_file=NULL,xlim=NULL,wi=12,hi=14)
            }
           }   
      
            #### For categorical data
           
          if (any(!is.na(lop$EOIc) == TRUE)) for(ii in 1:length(lop$EOIc)) {
              for(jj in 1:(nl-1)) for(kk in (jj+1):nl) {
                if (lvl[jj] == "0"){
                  input <- psa[kk,,] - psa[jj,,]  
                  label <- paste0(contrast,"_", lop$EOIc[ii], '-', lvl[kk], '-vs-', lvl[jj])
                } else {
                  input <- psa[jj,,] - psa[kk,,]
                  label <- paste0(contrast, "_", lop$EOIc[ii], '-', lvl[jj], '-vs-', lvl[kk]) 
                }
                colnames(input) <- ROIs
                input <- input[,order(colnames(input))]
                newcolnames<-paste(seq_along(colnames(input)),colnames(input),sep="-")
                colnames(input)<-newcolnames
                
                range_file <- paste0(getwd(),"/Leave_one_site_out/",label,"_P_plus_range.csv")
                
                if (file.exists(range_file)) {
                  ridge_alphabet(input, labx = label, range_file = range_file, xlim = NULL, wi = 12, hi = 14)
                } else {
                  ridge_alphabet(input,labx=label,range_file=NULL,xlim=NULL,wi=12,hi=14)
                }  
              }
            }
          }
        }
    }
  }

