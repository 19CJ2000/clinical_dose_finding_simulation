#################################################################
# SIMULATION OF ADTTE FINAL TABLE (ADSL/ADLB FINALIZATION AFTER)
#################################################################

set.seed(777) # reproducibility

# ---- ADMINISTRATIVE CENSORING ----
admin_censor_time <- 6  # Study end (months)



# ---- PLAUSIBLE DROPOUT PROBABILITY (BRIEF) ----

# function of age and baseline LVEF
risk_drop <- 0.03*adsl_skel$AGE -         # age increases dropout risk modestly (OR ~1.35 per 10y) 
             0.04*adsl_skel$BASELVEF      # better baseline function reduces dropout (OR ~0.67 per 10%)

p_dropout <- plogis(-3 + risk_drop)



# ---- PLAUSIBLE EVENT PROBABILITY (BRIEF) ----
risk_event <- 0.04*adsl_skel$AGE - 
              0.06*adsl_skel$BASELVEF  

p_event <- plogis(-2 + risk_event)



# ---- DROP OUT ASSIGNMENT ---- 

# subject-level Bernoulli process
drop_flag <- rbinom(N, size = 1, prob = p_dropout)
n_dropouts <- sum(drop_flag)
dropout_indices <- which(drop_flag == 1)

# Assign dropout times (uniformly between 0 and 6 months)
possible_dropout_months <- c(2, 4)
drop_time <- rep(admin_censor_time, N)
drop_time[drop_flag == 1] <- runif(sum(drop_flag), 0, admin_censor_time)



# ---- EVENT ASSIGNMENT ---- 

# subject-level Bernoulli process
event_flag <- rbinom(N, size = 1, prob = p_event)

n_events <- sum(event_flag)

event_indices <- which(event_flag == 1)

# Assign event times (uniformly between 0 and 6 months)
event_time <- rep(admin_censor_time, N)
event_time[event_flag == 1] <- runif(sum(event_flag), 0, admin_censor_time)



# ---- OBSERVED TIME  ---- 
aval <- pmin(event_time, drop_time, admin_censor_time)  # account for dropout

cnsr <- ifelse(event_flag == 1 & event_time <= drop_time, 0, 1)  # 0=event, 1=censor

# ---- CENSOR TYPE ASSIGNMENT ----
CNSRTYPE <- rep(2, N)  # default = administrative censoring
CNSRTYPE[drop_time < event_time & drop_time < admin_censor_time] <- 1  # dropout
CNSRTYPE[cnsr == 0] <- 0  # event

# ---- BUILD ADTTE ----
adtte_final <- data.frame(
  STUDYID  = adsl_skel$STUDYID,
  USUBJID  = adsl_skel$USUBJID,
  TRTGRP   = adsl_skel$TRTGRP,
  DOSE     = adsl_skel$DOSE,
  PARAMCD  = "TDMACE",
  PARAM    = "Time to 3-point MACE (Months)",
  AVAL     = round(aval, 2),
  CNSR     = cnsr,
  CNSRTYPE = CNSRTYPE
)


# ----- ADTTE FINAL STRUCTURE CHECK -----
str(adtte_final)



#################################################################
# UPDATE ADSL AND ADLB WITH ADTTE DROPOUT INFO 
#################################################################

# ----- ADSL -----
adsl_final <- merge(
  adsl_skel,
  adtte_final[, c("USUBJID","AVAL","CNSR","CNSRTYPE")],
  by="USUBJID",
  all.x=TRUE
)

names(adsl_final)[names(adsl_final)=="AVAL"] <- "FUPTIME"

adsl_final$DROPOUTFL <- ifelse(adsl_final$CNSR==1 & adsl_final$CNSRTYPE==1, "Y", "N")
adsl_final$DROPOUTMO <- ifelse(adsl_final$DROPOUTFL=="Y", adsl_final$FUPTIME, NA)
adsl_final$EVENTFL   <- ifelse(adsl_final$CNSR==0 & adsl_final$CNSRTYPE==0, 1, 0)
adsl_final$EVENTMO   <- ifelse(adsl_final$EVENTFL==1, adsl_final$FUPTIME, NA)
adsl_final$PPFL      <- ifelse(adsl_final$DROPOUTFL=="N" & adsl_final$EVENTFL==0, "Y", "N")

# ----- ADSL FINAL STRUCTURE CHECK -----
str(adsl_final)




# ----- ADLB -----
adlb_final <- merge(
  adlb_skel,
  adsl_final[, c("USUBJID","FUPTIME")],
  by="USUBJID",
  all.x=TRUE
)

adlb_final$AVAL[adlb_final$AVISITN > adlb_final$FUPTIME] <- NA
adlb_final$CHG[adlb_final$AVISITN > adlb_final$FUPTIME]  <- NA

adlb_final$FUPTIME <- NULL

# ----- ADLB FINAL STRUCTURE CHECK -----
str(adlb_final)