#################################################################
# SIMULATION OF ADLB TABLE SKELETON (ADLB FINALIZED IN PART 3)
#################################################################

set.seed(777) # reproducibility

# ---- STUDY PARAMETERS -----
Emax  <- 6
ED50  <- 15
sigma <- 6      

# Visits
visit_months <- c(0, 2, 4, 6)
visit_labels <- c("Baseline", "Month 2", "Month 4", "Month 6")
time_frac    <- c(0, 0.4, 0.75, 1)  # fraction of full Emax

visit_df <- data.frame(
  AVISIT  = visit_labels,
  AVISITN = visit_months,
  TIMEFRAC = time_frac
)

# Expand into longitudinal table
adlb_skel <- merge(adsl_skel, visit_df, by=NULL)
adlb_skel <- adlb_skel[order(adlb_skel$USUBJID, adlb_skel$AVISITN), ]
row.names(adlb_skel) <- NULL


# ---- TRUE DOSE-RESPONSE (EMAX) ----
adlb_skel$TRT_EFFECT_M6 <- with(adlb_skel, Emax * DOSE / (ED50 + DOSE))


# ---- OBSERVED LVEF ----
adlb_skel$AVAL <- with(adlb_skel,
                  BASELVEF +
                    TIMEFRAC * TRT_EFFECT_M6 +
                    rnorm(nrow(adlb_skel), mean=0, sd=sigma)
)

# Truncate physiologic bounds
adlb_skel$AVAL[adlb_skel$AVAL < 25] <- 25
adlb_skel$AVAL[adlb_skel$AVAL > 70] <- 70

# Baseline / change
adlb_skel$BASE <- rep(adsl_skel$BASELVEF, each=length(visit_months))
adlb_skel$CHG  <- adlb_skel$AVAL - adlb_skel$BASE
adlb_skel$AVAL[adlb_skel$AVISIT=="Baseline"] <- adlb_skel$BASE[adlb_skel$AVISIT=="Baseline"]
adlb_skel$CHG[adlb_skel$AVISIT=="Baseline"] <- 0

# Keep only needed columns
adlb_skel <- adlb_skel[, c("STUDYID","USUBJID","TRTGRP","DOSE","AVISIT","AVISITN","BASE","AVAL","CHG")]


# ----- ADLB (SKELETON) STRUCTURE CHECK -----
str(adlb_skel)

