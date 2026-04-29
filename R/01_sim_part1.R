#################################################################
# SIMULATION OF ADSL TABLE SKELETON (ADSL FINALIZED IN PART 3)
#################################################################

set.seed(777) # reproducibility

# ----- STUDY-LEVEL CONSTANTS -----
N <- 300
dose_levels <- c(0, 5, 10, 25, 50)
trt_labels  <- c("Placebo", "Drug X 5 mg", "Drug X 10 mg",
                 "Drug X 25 mg", "Drug X 50 mg")

adsl_skel <- data.frame(
  STUDYID = "DRUGX-PH2",
  USUBJID = sprintf("SUBJ-%03d", 1:N),
  TRTGRP  = rep(trt_labels, each = N / length(dose_levels)),
  DOSE    = rep(dose_levels, each = N / length(dose_levels))
)

# Randomize
adsl_skel <- adsl_skel[sample(1:N), ]
row.names(adsl_skel) <- NULL


# Baseline demographics
adsl_skel$AGE <- round(rnorm(N, 68, 6))
adsl_skel$AGE[adsl_skel$AGE < 50] <- 50
adsl_skel$SEX <- sample(c("Male","Female"), N, replace=TRUE, prob=c(0.4,0.6))
adsl_skel$RACE <- sample(c("Asian","White","Black"), N, replace=TRUE, prob=c(0.15,0.65,0.2))


# Baseline LVEF
adsl_skel$BASELVEF <- rnorm(
  N,
  mean = 45 +
    ifelse(adsl_skel$SEX=="Female",2,0) -
    0.1*(adsl_skel$AGE-68) +
    ifelse(adsl_skel$RACE=="Asian",1, ifelse(adsl_skel$RACE=="White",0,-1.5)),
  sd = 3  # lower SD to reduce noise
)
adsl_skel$BASELVEF[adsl_skel$BASELVEF < 30] <- 30
adsl_skel$BASELVEF[adsl_skel$BASELVEF > 60] <- 60


# ----- DATES & FLAGS -----
start_date <- as.Date("2024-01-01")  # study start 
adsl_skel$RANDDT <- start_date + sample(0:180, N, replace=TRUE)  

adsl_skel$ITTFL  <- "Y"  
adsl_skel$SAFFL  <- "Y"  
adsl_skel$PPFL   <- "Y"  


# Dropout placeholders
adsl_skel$DROPOUTFL <- "N"  # finalized in 03_simulation_adtte after adtte simulation 
adsl_skel$DROPOUTMO <- NA   # finalized in 03_simulation_adtte after adtte simulation 
adsl_skel$EVENTFL   <- 0    # finalized in 03_simulation_adtte after adtte simulation 
adsl_skel$EVENTMO   <- NA   # finalized in 03_simulation_adtte after adtte simulation 


# ----- ADSL (SKELETON) STRUCTURE CHECK -----
str(adsl_skel)

