### Nadza Dzinalija Oct 2023

### Produces input for Enigma toolbox from Schaefer 200-parcel RBA analyses (P-plus values)

  
for (contrast in c("INHIBITION","ERROR")){
    
  for (model in c("response", "remission", "deltaYBOCS")){
    
        directories <- c(paste0("/data/anw/anw-work/NP/projects/data_ENIGMA_OCD/ENIGMA_TASK/analysis/CBT_response/RBA/Whole-brain/Schaefer200/", contrast, "/", model),
          paste0("/data/anw/anw-work/NP/projects/data_ENIGMA_OCD/ENIGMA_TASK/analysis/CBT_response/RBA/Whole-brain/Schaefer200/", contrast, "/", model,"/COMBAT"))
        
        for (dir in directories){
          if (file.exists(dir)){
            setwd(dir)
              
    
            Rdatafile <-list.files(pattern = ".RData")
            
            if (length(Rdatafile) == 1){
              load(Rdatafile)
              
              # Create an empty list to store input variables
              input_list <- list()  
              
              # For continuous data
              if(any(!is.na(lop$EOIq) == TRUE)){
                
                input <- ps0
                label <- paste0(contrast,"_",lop$EOIq)
                input_list[[label]] <- input
                
                
              } 
              
              # For categorical data
              if(any(!is.na(lop$EOIc) == TRUE)) for(ii in 1:length(lop$EOIc)) {
                
                for(jj in 1:(nl-1)) for(kk in (jj+1):nl) {
                  if (lvl[jj] == "0"){
                    input <- psa[kk,,] - psa[jj,,]
                    label <- paste0(contrast, "_", lop$EOIc[ii], '-', lvl[kk], '-vs-', lvl[jj])
                  } else {
                    input <- psa[jj,,] - psa[kk,,]
                    label <- paste0(contrast, "_", lop$EOIc[ii], '-', lvl[jj], '-vs-', lvl[kk])
                  }
                  
                  input_list[[label]] <- input
                }
              }
              
              # append processed input variables to P_plus_values_list
              for (input_name in names(input_list)) {
                input <- input_list[[input_name]]
                data <- data.frame(input)
                nobj = dim(data)[1]
                rois <- dimnames(input)[[2]]
                colnames(data) <- rois
                data_stats <- data.frame(ROI=rois)
                data_stats$P <- colSums(data > 0)/nobj
                
                ## Rename ROIs
                # 7 networks
                data_stats$ROI=gsub("Visual", "Vis", data_stats$ROI)
                data_stats$ROI=gsub("Somatomotor", "SomMot", data_stats$ROI)
                data_stats$ROI=gsub("Dorsal Attention", "DorsAttn", data_stats$ROI)
                data_stats$ROI=gsub("Salience / Ventral Attention", "SalVentAttn", data_stats$ROI)
                data_stats$ROI=gsub("Control", "Cont", data_stats$ROI)
                data_stats$ROI=gsub(" ", "_", data_stats$ROI)
          
                for (k in seq_along(data_stats$ROI)) {
                  if (grepl("_L$", data_stats$ROI[k])) {
                    data_stats$ROI[k] <- sub("(.*)_L$", "LH_\\1", data_stats$ROI[k])
                  } else if (grepl("_R$", data_stats$ROI[k])) {
                    data_stats$ROI[k] <- sub("(.*)_R$", "RH_\\1", data_stats$ROI[k])
                  }
                }
                
                data_stats$ROI=gsub("Hippocampus_Ant", "aHIP", data_stats$ROI)
                data_stats$ROI=gsub("Hippocampus_Post", "pHIP", data_stats$ROI)
                data_stats$ROI=gsub("Amygdala_Lat", "lAMY", data_stats$ROI)
                data_stats$ROI=gsub("Amygdala_Med", "mAMY", data_stats$ROI)
                data_stats$ROI=gsub("Thalamus_DorsopPost", "THA-DP", data_stats$ROI)
                data_stats$ROI=gsub("Thalamus_VentroPost", "THA-VP", data_stats$ROI)
                data_stats$ROI=gsub("Thalamus_VentroAnt", "THA-VA", data_stats$ROI)
                data_stats$ROI=gsub("Thalamus_DorsoAnt", "THA-DA", data_stats$ROI)
                data_stats$ROI=gsub("Nucleus_Accumbens shell", "NAc-shell", data_stats$ROI)
                data_stats$ROI=gsub("Nucleus_Accumbens core", "NAc-core", data_stats$ROI)
                data_stats$ROI=gsub("Globus_Pallidus Post", "pGP", data_stats$ROI)
                data_stats$ROI=gsub("Globus_Pallidus Ant", "aGP", data_stats$ROI)
                data_stats$ROI=gsub("Putamen_Ant", "aPUT", data_stats$ROI)
                data_stats$ROI=gsub("Putamen_Post", "pPUT", data_stats$ROI)
                data_stats$ROI=gsub("Caudate_Ant", "aCAU", data_stats$ROI)
                data_stats$ROI=gsub("Caudate_Post", "pCAU", data_stats$ROI)
      
                # write out csv with range of P+ values in leave-site-out jackknife analyses
                write.csv(data_stats,paste0(input_name,"_P_plus_values.csv"),row.names = FALSE)
              }
            }
          }
        }
      }
    }



