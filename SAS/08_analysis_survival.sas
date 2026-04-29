
*============================================*;
/* SECONDARY ENDPOINT ANALYSIS               */
/* Survival analyses                         */
*============================================*;

* Import ADTTE table;
proc import datafile="Z:\0-SAS Work\0-SDR Project\adtte_final.csv"
    out= adtte
    dbms=csv
    replace;
    getnames=yes;
run;



/*-------------------------------------------*/ 
/* KM CURVES                                 */
/*-------------------------------------------*/ 

/* --- KM Curves and Log-Rank Tests --- */

   * Get KM estimates (suppress the default plot so you can manually plot);
proc lifetest data=ADTTE
              plots=none
              method=km
              outsurv=KM_ESTIMATES;
    time AVAL * CNSR(1);
    strata TRTGRP / test=(logrank);
    title 'Kaplan-Meier — Log-Rank Test Across Dose Groups';
run;

   * Plot manually with truncated y-axis due to higher survival probability;
proc sgplot data=KM_ESTIMATES;
    step x=AVAL y=SURVIVAL / group=TRTGRP;
    yaxis min=0.8 max=1.0 label='Survival Probability';
    xaxis label='Time (Months)' values=(0 to 6 by 1);
    title 'Kaplan-Meier Survival Curves — Time to 3-Point MACE';
run;



/*-------------------------------------------*/ 
/* PH ASSUMPTION                             */
/*     PH test: Schoenfeld Residuals         */ 
/*     PH visualization: Log-Log Plots       */ 
/*-------------------------------------------*/ 

/* --- Schoenfeld Residuals --- */
ods graphics on;

proc phreg data=ADTTE;
    class TRTGRP (ref='Placebo') / param=ref;
    model AVAL * CNSR(1) = TRTGRP / ties=efron;
    output out=PH_RESIDS ressch=SCH_TRTGRP;
    assess ph / resample;
    title 'PH Assumption Test — Schoenfeld Residuals';
run;

ods graphics off;  * PH assumption holds across all doses (final table); 

/* --- Log-Log Survival Plot --- */
ods graphics on;

proc lifetest data=ADTTE plots=lls;
    time AVAL * CNSR(1);
    strata TRTGRP;
    title 'Log-Log Survival Plot — Visual Check of Proportional Hazards'; * PH assumption titters due to event sparcity; 
run;

ods graphics off;



/*-------------------------------------------*/ 
/* COX MODELS                                */
/*-------------------------------------------*/ 

/* Model A: Categorical dose — HR per arm vs placebo */
proc phreg data=ADTTE;
    class TRTGRP (ref='Placebo') / param=ref;
    model AVAL * CNSR(1) = TRTGRP / ties=efron rl;
    title 'Cox PH Model A — Categorical Dose (Reference: Placebo)';
run;

/* Model B: Continuous dose — linear dose-response in hazard */
proc phreg data=ADTTE;
    model AVAL * CNSR(1) = DOSE / ties=efron rl;
    title 'Cox PH Model B — Continuous Dose (Per 1 mg Increase)';
run;



/*-------------------------------------------*/ 
/* COX MODEL FOR DROPOUT                     */
/*    test whether dropout is non-randoM     */
/*-------------------------------------------*/ 

* create new dataset where:  
      event = dropped out (CNSRTYPE=1)
      censored = MACE event occurred (CNSRTYPE=0) or completed study (CNSRTYPE=2);  
data ADTTE_DROPOUT;
    set ADTTE;
    DROPOUT_EVENT = (CNSRTYPE = 1);
run;

* cox regression to determine dropout hazard across dose groups;  
proc phreg data=ADTTE_DROPOUT;
    class TRTGRP (ref='Placebo') / param=ref;
    model AVAL * DROPOUT_EVENT(0) = TRTGRP / ties=efron rl;
    title 'Cox Model for Dropout — Hazard of Leaving Study by Dose Group';
run;  * results: no strong evidence that dropout hazard differs across dose arms; 


ods graphics on;

proc lifetest data=ADTTE_DROPOUT
              plots=survival(atrisk nocensor);
    time AVAL * DROPOUT_EVENT(0);
    strata TRTGRP;
    title 'Cumulative Dropout Curves by Dose Group';
run;

ods graphics off;

* IPCW not needed due to uninformative dropout
