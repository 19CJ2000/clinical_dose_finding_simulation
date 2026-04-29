#################################################################
# QUALITY CONTROL OF SIMULATED DATA (EXPORT AFTER)
#################################################################
# ----- PACKAGES ----- 
library(here)      # relative file importing

# ----- QC CHECKS ----- 

# QC Check 1: Merge integrity (Good = TRUE)
all(adsl_final$USUBJID %in% adlb_final$USUBJID)
all(adsl_final$USUBJID %in% adtte_final$USUBJID)

# QC Check 2: Visit counts after censoring (Good = even)
table(adlb_final$AVISIT, is.na(adlb_final$AVAL))

# QC Check 3: ITT population consistency (Good = TRUE)
sum(adsl_final$ITTFL=="Y") == N

# QC Check 4: Event rate by dose
mean(adtte_final$CNSR == 0)      # event rate
aggregate(CNSR == 0 ~ DOSE, data=adtte_final, mean)

# QC Check 5: Dropout rate by dose  
mean(adtte_final$CNSRTYPE == 1)  # dropout rate
aggregate(CNSRTYPE == 1 ~ DOSE, data=adtte_final, mean)

# QC Check 6: Admin censoring rate by dose  
aggregate(CNSRTYPE == 2 ~ DOSE, data=adtte_final, mean)

# QC Check 7: LVEF change by dose  
aggregate(CHG ~ DOSE, data=adlb_final[adlb_final$AVISIT=="Month 6", ], mean)




#################################################################
# EXPORT OF SIMULATED DATA (FOR SAS ANALYSIS)
#################################################################

# csv good compatibility with VMware for SAS
write.csv(adsl_final, here("data", "adsl_final.csv"))  
write.csv(adlb_final, here("data", "adlb_final.csv"))
write.csv(adtte_final, here("data", "adtte_final.csv"))



