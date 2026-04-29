#################################################################
# MCP-MOD WITH _EST AND _COV TABLE PRODUCED FROM SAS MMRM 
#################################################################
# ----- PACKAGES ----- 
library(here)         # relative file importing
library(tidyverse)    # syntax simplicity
library(DoseFinding)  # MCP-Mod analysis 


# ----- DATA IMPORT -----

est <- read.csv(here("data", "mcpmod_est.csv"))
str(est)

diff <- read.csv(here("data", "mcpmod_diff.csv"))
str(diff)

cov <- read.csv(here("data", "mcpmod_cov.csv"))
str(cov)

# Trim covariance matrix
cov <- cov %>%
  mutate(TRTGRP = factor(TRTGRP,  # order by dose and Cov column order (to maintain matrix symmetry)
                         levels = c("Placebo", "Drug X 5 mg", 
                                    "Drug X 10 mg", "Drug X 25 mg", 
                                    "Drug X 50 mg"))) %>%  
  arrange(TRTGRP) %>%
  select(Cov14, Cov8, Cov2, Cov5, Cov11)   # maintain matrix symmetry 
cov <- as.matrix(cov) # convert object to matrix 
cov 


##################################################################
# SAP / TRIAL DESIGN STAGE
##################################################################

# Extract Month 6 LSmeans from SAS MMRM 
pboeff <- est$Estimate[est$dose == 0] # placebo LSMean at Month 6 (0 mg)
pboeff

acteff <- est$Estimate[est$dose == 50] # max active LSMean at Month 6 (50mg)
acteff 


# Build pre-specified candidate models
quad    <- guesst(d = 25, p = 0.90, "quadratic")                        # Effect peaks early around 20mg then dips noticeably at 50mg
exp     <- guesst(d = 35, p = 0.3, "exponential", Maxd = 50)            # Slow rise, most effect concentrated at high doses
emax    <- guesst(d = 10, p = 0.5, "emax")                              # At dose 10mg, expect 50% of max effect - steep early rise
sigemax <- guesst(d = c(10, 25), p = c(0.3, 0.9), "sigEmax")            # Moderate S-shape, gradual transition zone 10-25mg
logis   <- guesst(d = c(20, 30), p = c(0.2, 0.8), model = "logistic")   # Sharp threshold, steep switch concentrated around 20-30mg


# Assemble and examine candidate models 
my.model <- Mods(linear      = NULL,
                 quadratic    = quad,
                 exponential  = exp,
                 emax         = emax,
                 sigEmax      = sigemax,
                 logistic     = logis,
                 doses        = est$dose,
                 placEff      = pboeff,
                 maxEff       = acteff)

plot(my.model) # candidate models 


# Multiple Contrasts Test: Use MCTtest to test the null hypothesis (curve = non-flat)
 # If at least one dose-response model is statistically significant, rejecting the null hypothesis of 
 # a flat dose-response curve is indicating a benefit of the drug over placebo.
set.seed(777) 

contMatnew <- optContr(my.model, S=cov)

mct_test <- MCTtest(dose=dose, resp=Estimate, data=est, my.model, S=cov,
                   type = "general",
                   placAdj = FALSE, df = Inf,
                   critV = TRUE, pVal = TRUE, alpha = 0.025,
                   alternative = c("one.sided"), na.action = na.fail,
                   mvtcontrol = mvtnorm.control(), contMat = contMatnew)

mct_test


# model parameter estimation needs to be done for each model separately
fit_linear      <- fitMod(dose=dose, resp=Estimate, data=est, S=cov, model='linear',      type="general")
fit_quadratic   <- fitMod(dose=dose, resp=Estimate, data=est, S=cov, model='quadratic',   type="general")
fit_exponential <- fitMod(dose=dose, resp=Estimate, data=est, S=cov, model='exponential', type="general")
fit_emax        <- fitMod(dose=dose, resp=Estimate, data=est, S=cov, model='emax',        type="general")
fit_sigEmax     <- fitMod(dose=dose, resp=Estimate, data=est, S=cov, model='sigEmax',     type="general")
fit_logistic    <- fitMod(dose=dose, resp=Estimate, data=est, S=cov, model='logistic',    type="general")

plot(fit_linear,      CI = T, plotData = 'meansCI', level=0.95)
plot(fit_quadratic,   CI = T, plotData = 'meansCI', level=0.95)
plot(fit_exponential, CI = T, plotData = 'meansCI', level=0.95)
plot(fit_emax,        CI = T, plotData = 'meansCI', level=0.95)
plot(fit_sigEmax,     CI = T, plotData = 'meansCI', level=0.95)
plot(fit_logistic,    CI = T, plotData = 'meansCI', level=0.95)



# MCP-Mod: results provide the estimated target dose to achieve 4% LVEF improvement under each model:
set.seed(777) 
resultAIC <- MCPMod(dose=dose, resp=Estimate, data=est, my.model, S=cov,
                    type="general", critV=T, alpha=0.025, 
                    alternative=c("one.sided"), 
                    Delta=4,                  # the dose that achieves a 4% (clinically meaningful) improvement in LVEF.
                    selModel=c("AIC"))

resultAIC$selMod  # Emax selected by AIC as best fitting model (consistant w/ simulation logic)
resultAIC$doseEst # Emax estimate of 19.69 mg to achieve 4% increase in LVEF over 6 months. 

# The selected Emax model and estimated target dose align with the true data-generating mechanism (ED50 = 15), demonstrating recovery of the underlying dose-response.

