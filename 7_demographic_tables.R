### N.Dzinalija VUmc 2025

### Creates:
### Demographics stats and tables for CBT response analyses (per sample and total across samples)

# Covariate codes
# ----------------
  
#  Sample: 0=AMC_Bascule; 1=Barcelona; 2=Bergen; 3=IDIBELL; 4=AMC_TBM
#  Sex: 0=male; 1=female
#  Task: 0=SST; 1=Flanker
#  AgeOfOnset: 0=Child-onset (<18); 1=Adult-onset (18+)
#  Medication: 0=Unmedicated; 1=Medicated
#  ResponderStatus: 0=<35% YBOCS reduction; 1=>35% YBOCS reduction
#  RemissionStatus: 0=Post-YBOCS >12; 1=Post-YBOCS <12

library(readxl)
library(dplyr)
library(tidyverse)
library(knitr)

# Read in RBA input file for main contrast of interest
setwd("/data/anw/anw-work/NP/projects/data_ENIGMA_OCD/ENIGMA_TASK/analysis/CBT_response")
df <- read.csv("features_Inhibitory_domain.csv")

covs = df

##############################
### Calculate demographics ###
##############################

create_summary_table <- function(subset_df) {
  OCD = subset_df
  total_OCD = nrow(OCD)
  
  #SEX
  OCD_male = sum(OCD$SEX=="0") 
  OCD_male_perc = round((OCD_male/total_OCD)*100,2)
  OCD_female = sum(OCD$SEX=="1")
  OCD_female_perc = round((OCD_female/total_OCD)*100,2)
  
  #Age
  OCD_age_mean = round(mean(OCD$AGE),2)
  OCD_age_sd = round(sd(OCD$AGE),2)
  
  #Age of onset
  OCD$AO_clean = ifelse(is.na(OCD$AgeOfOnset) | OCD$AgeOfOnset == "", "Missing", OCD$AgeOfOnset)
  table_AO = table(OCD$AO_clean)
  OCD_adult_onset = table_AO['1']
  OCD_adult_onset_perc = round((OCD_adult_onset/total_OCD)*100,2)
  
  OCD_child_onset = table_AO['0']
  OCD_child_onset_perc = round((OCD_child_onset/total_OCD)*100,2)
  
  OCD_missing_onset = table_AO['Missing']
  OCD_missing_onset_perc = round((OCD_missing_onset/total_OCD)*100,2)
  
  #Medication
  OCD$MED_clean = ifelse(is.na(OCD$Medication) | OCD$Medication == "", "Missing", OCD$Medication)
  table_MED = table(OCD$MED_clean)
  OCD_medicated = table_MED['1']
  OCD_medicated_perc = round((OCD_medicated/total_OCD)*100,2)
  
  OCD_unmedicated = table_MED['0']
  OCD_unmedicated_perc = round((OCD_unmedicated/total_OCD)*100,2)
  
  OCD_missing_med = table_MED["Missing"]
  OCD_missing_med_perc = round((OCD_missing_med/total_OCD)*100,2)
  
  #Severity YBOCS pre
  OCD_YBOCS_pre_mean = round(mean(OCD$SevYBOCS_pre,na.rm = TRUE),2)
  OCD_YBOCS_pre_sd = round(sd(OCD$SevYBOCS_pre,na.rm = TRUE),2)

  #Severity YBOCS post
  OCD_YBOCS_post_mean = round(mean(OCD$SevYBOCS_post,na.rm = TRUE),2)
  OCD_YBOCS_post_sd = round(sd(OCD$SevYBOCS_post,na.rm = TRUE),2)
  
  #T-test of pre-post YBOCS score
  t_test_YBOCS = t.test(OCD$SevYBOCS_pre, OCD$SevYBOCS_post, paired = TRUE)
  t_test_YBOCS_stat = round(t_test_YBOCS$statistic,2)
  t_test_YBOCS_dof = round(t_test_YBOCS$parameter)
  t_test_YBOCS_p = formatC(t_test_YBOCS$p.value, format = "e", digits = 2)
  
  #Responders (Delta YBOCS > 35%)
  OCD_responders = sum(OCD$ResponderStatus)
  OCD_responders_perc = round((OCD_responders/total_OCD)*100,2)

  #Remitters (YBOCS post <12)
  OCD_remitters = sum(OCD$RemissionStatus)
  OCD_remitters_perc = round((OCD_remitters/total_OCD)*100,2)
  
  ### Make summary table for all sites combined 
  summary_table = data.frame(Demographics = c("Sex", 
                                     "n female",
                                     "n male",
                                     "Age",
                                     "Age of onset",
                                     "n onset <18",
                                     "n onset >18",
                                     "missing data",
                                     "Medication",
                                     "n medicated",
                                     "n unmedicated",
                                     "missing data",
                                     "YBOCS pre CBT",
                                     "YBOCS post CBT",
                                     "Responders post CBT",
                                     "Remitters post CBT"), 
                            OCD = rep(NA,16),
                            Statistics = rep(NA,16),
                            stringsAsFactors = FALSE)

  summary_table$OCD = c("",
                            paste(OCD_female," (",OCD_female_perc,"%)",sep=""),
                            paste(OCD_male," (",OCD_male_perc,"%)",sep=""), 
                            paste(OCD_age_mean," (",OCD_age_sd,")",sep=""),
                            "",
                            paste(OCD_child_onset," (",OCD_child_onset_perc,"%)",sep=""),
                            paste(OCD_adult_onset," (",OCD_adult_onset_perc,"%)",sep=""),
                            paste(OCD_missing_onset," (",OCD_missing_onset_perc,"%)",sep=""),
                            "",
                            paste(OCD_medicated," (",OCD_medicated_perc,"%)",sep=""),
                            paste(OCD_unmedicated," (",OCD_unmedicated_perc,"%)",sep=""),
                            paste(OCD_missing_med," (",OCD_missing_med_perc,"%)",sep=""),
                            paste(OCD_YBOCS_pre_mean," (",OCD_YBOCS_pre_sd,")",sep=""),
                            paste(OCD_YBOCS_post_mean," (",OCD_YBOCS_post_sd,")",sep=""),
                            paste(OCD_responders," (",OCD_responders_perc,"%)",sep=""),
                            paste(OCD_remitters," (",OCD_remitters_perc,"%)",sep=""))
  
  
  summary_table$Statistics = c("",
                               "-",
                               "-",
                               "-",
                               "-",
                               "-",
                               "-",
                               "-",
                               "-",
                               "-",
                               "-",
                               "-",
                               "-",
                               paste("T(",t_test_YBOCS_dof,") = ",t_test_YBOCS_stat,", P = ",t_test_YBOCS_p,sep=""),
                               "-",
                               "-")
  
  return(summary_table)
}

summary_table = create_summary_table(covs)
kable(summary_table)



######################################
### Demographics tables per sample ###
######################################

per_site=data.frame()
all_sites=data.frame()

covs$Sample=as.factor(covs$Sample)

for (sample in unique(covs$Sample)){
  print(sample)
  
  if (sample == "0"){
    sample_name = "Huyser_Amsterdam"
  } else if (sample == "1"){
    sample_name = "Fullana_Barcelona"
  } else if  (sample == "2"){
    sample_name = "Thorsen_Bergen"
  } else if  (sample == "3"){
    sample_name = "Menchon/Soriano-Mas_Barcelona"
  } else if  (sample == "4"){
    sample_name = "van Wingen_Amsterdam"
  }

  sub_sample=covs[covs$Sample==sample,]
  
  sub_sample_OCD_n = nrow(sub_sample)
  
  sub_sample_age_mean = round(mean(sub_sample$AGE),2)
  sub_sample_age_sd = round(sd(sub_sample$AGE),2)
  
  sub_sample_sex_male = sum(sub_sample$SEX=="0")
  sub_sample_sex_male_perc = round(sub_sample_sex_male/nrow(sub_sample)*100,2)
  
  sub_sample_child_onset = sum(sub_sample$AgeOfOnset=="0", na.rm = TRUE)
  sub_sample_child_onse_perc = round(sub_sample_child_onset/sub_sample_OCD_n*100,2)
  
  sub_sample_med = sum(sub_sample$Medication=="1", na.rm = TRUE)
  sub_sample_med_perc = round(sub_sample_med/sub_sample_OCD_n*100,2)
  
  sub_sample_ybocs_pre_mean = round(mean(sub_sample$SevYBOCS_pre, na.rm = TRUE),2)
  sub_sample_ybocs_pre_sd = round(sd(sub_sample$SevYBOCS_pre, na.rm = TRUE),2)
  
  sub_sample_ybocs_post_mean = round(mean(sub_sample$SevYBOCS_post, na.rm = TRUE),2)
  sub_sample_ybocs_post_sd = round(sd(sub_sample$SevYBOCS_post, na.rm = TRUE),2)
  
  sub_sample_responders = sum(sub_sample$ResponderStatus)
  sub_sample_responders_perc = round(sub_sample_responders/sub_sample_OCD_n*100,2)
  
  sub_sample_remitters = sum(sub_sample$RemissionStatus)
  sub_sample_remitters_perc = round(sub_sample_remitters/sub_sample_OCD_n*100,2)
  
  per_site=data.frame(sample_name,
                      sub_sample_OCD_n,
                      sub_sample_sex_male_perc,
                      paste(sub_sample_age_mean,"±",sub_sample_age_sd),
                      sub_sample_child_onse_perc,
                      sub_sample_med_perc,
                      paste(sub_sample_ybocs_pre_mean,"±",sub_sample_ybocs_pre_sd),
                      paste(sub_sample_ybocs_post_mean,"±",sub_sample_ybocs_post_sd),
                      sub_sample_responders_perc,
                      sub_sample_remitters_perc)
  
  all_sites=rbind(all_sites,per_site)
}

colnames(all_sites) = c("Sample",
                        "n OCD",
                        "% Male",
                        "Age (mean ± SD)",
                        "% Child onset OCD",
                        "% Medicated OCD",
                        "(C)Y-BOCS pre CBT (mean ± SD)",
                        "(C)Y-BOCS post CBT (mean ± SD)",
                        "% Responders",
                        "% Remitters")

kable(all_sites)
sum(all_sites$`n OCD`)


##############################################
### Demographics tables per clinical group ###
##############################################

covs_NoHC = covs[covs$AO != "HC",]


# By age of onset
  demographics_table_AO <- covs_NoHC %>%
  group_by(AO) %>%
  summarise(
    n = n(),
    n_female = sum(SEX == "f"),
    perc_female = round((n_female / n) * 100, 1),
    n_male = sum(SEX == "m"),
    perc_male = round((n_male / n) * 100, 1),
    mean_age = round(mean(AGE, na.rm = TRUE), 2),
    sd_age = round(sd(AGE, na.rm = TRUE), 2),
    n_under18 = sum(AGE < 18, na.rm = TRUE),
    perc_under18 = round((n_under18 / n) * 100, 1),
    n_18plus = sum(AGE >= 18, na.rm = TRUE),
    perc_18plus = round((n_18plus / n) * 100, 1),
    n_onset_under18 = sum(AO == "Child", na.rm = TRUE),
    perc_onset_under18 = round((n_onset_under18 / n) * 100, 1),
    n_onset_18plus = sum(AO == "Adult", na.rm = TRUE),
    perc_onset_18plus = round((n_onset_18plus / n) * 100, 1),
    n_ao_missing = sum(is.na(AO)),
    perc_missing = round((n_ao_missing / n) * 100, 1),
    n_medicated = sum(MED == "Med"),
    perc_medicated = round((n_medicated / n) * 100, 1),
    n_unmedicated = sum(MED == "Unmed"),
    perc_unmedicated = round((n_unmedicated / n) * 100, 1),
    n_med_missing = sum(is.na(MED)),
    perc_med_missing = round((n_med_missing / n) * 100, 1),
    mean_ybocs = round(mean(YBOCS, na.rm = TRUE), 2),
    sd_ybocs = round(sd(YBOCS, na.rm = TRUE), 2),
    n_ybocs_missing = sum(is.na(YBOCS)),
    perc_ybocs_missing = round((n_ybocs_missing / n) * 100, 1)
  )

# By medication status
covs_NoHC = covs[covs$MED != "HC",]
  
demographics_table_MED <- covs_NoHC %>%
  group_by(MED) %>%
  summarise(
    n = n(),
    n_female = sum(SEX == "f"),
    perc_female = round((n_female / n) * 100, 1),
    n_male = sum(SEX == "m"),
    perc_male = round((n_male / n) * 100, 1),
    mean_age = round(mean(AGE, na.rm = TRUE), 2),
    sd_age = round(sd(AGE, na.rm = TRUE), 2),
    n_under18 = sum(AGE < 18, na.rm = TRUE),
    perc_under18 = round((n_under18 / n) * 100, 1),
    n_18plus = sum(AGE >= 18, na.rm = TRUE),
    perc_18plus = round((n_18plus / n) * 100, 1),
    n_onset_under18 = sum(AO == "Child", na.rm = TRUE),
    perc_onset_under18 = round((n_onset_under18 / n) * 100, 1),
    n_onset_18plus = sum(AO == "Adult", na.rm = TRUE),
    perc_onset_18plus = round((n_onset_18plus / n) * 100, 1),
    n_ao_missing = sum(is.na(AO)),
    perc_missing = round((n_ao_missing / n) * 100, 1),
    n_medicated = sum(MED == "Med"),
    perc_medicated = round((n_medicated / n) * 100, 1),
    n_unmedicated = sum(MED == "Unmed"),
    perc_unmedicated = round((n_unmedicated / n) * 100, 1),
    n_med_missing = sum(is.na(MED)),
    perc_med_missing = round((n_med_missing / n) * 100, 1),
    mean_ybocs = round(mean(YBOCS, na.rm = TRUE), 2),
    sd_ybocs = round(sd(YBOCS, na.rm = TRUE), 2),
    n_ybocs_missing = sum(is.na(YBOCS)),
    perc_ybocs_missing = round((n_ybocs_missing / n) * 100, 1)
  )


       



