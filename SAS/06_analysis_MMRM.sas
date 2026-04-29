*============================================*;
/* PRIMARY ENDPOINT ANALYSIS                 */
/* MMRM + MCP-Mod                            */
*============================================*;

* Import ADSL table; 
proc import datafile="Z:\0-SAS Work\0-SDR Project\adsl_final.csv"
    out= adsl
    dbms=csv
	replace;
    getnames=yes;
run;

* Import ADLB table;
proc import datafile="Z:\0-SAS Work\0-SDR Project\adlb_final.csv"
    out= adlb
    dbms=csv
	replace;
    getnames=yes;
	guessingrows=max;  * needed for TRTGRP;
run;



*----------------------------------------------;
/* Step 1 - Prep ADLB for MMRM  */
*----------------------------------------------;
* Fix ADLB variable classes for MMRM; 
data adlb_fixed;
    set adlb;
    CHG_num = input(CHG, best32.);   * CHG was imported as chr instead of num; 
    AVAL_num = input(AVAL, best32.); * AVAL was imported as chr instead of num;
    drop CHG AVAL;
    rename CHG_num = CHG
           AVAL_num = AVAL;
run;
proc contents data=adlb_fixed; run;


* Ensure adsl and adlb sorted together; 
proc sort data=adsl out=adsl_sorted;
    by USUBJID;
run;

proc sort data=adlb_fixed out=adlb_sorted;
    by USUBJID;
run;


* Merge demographics into ADLB;
data mmrm_data;
    merge adlb_sorted (in=a)
          adsl_sorted (in=b keep=USUBJID AGE SEX RACE);
    by USUBJID;
    if a;
    if AVISIT ne "Baseline";
run;



*----------------------------------------------;
/* Step 2 - MMRM                              */
/* Captures LSMeans, pairwise diffs           */
*----------------------------------------------;

ODS OUTPUT lsmeans=_lsmeans 
		   diffs=_diffs 
	       tests =_tests 
           solutionf=_solutf;        

proc mixed data=mmrm_data method=reml;
    class USUBJID
          SEX(ref='Male')
          RACE(ref='White')
          TRTGRP(ref='Placebo')
          AVISIT(ref='Month 2');
    model CHG = AGE SEX RACE BASE TRTGRP AVISIT TRTGRP*AVISIT
              / solution ddfm=kr;
    repeated AVISIT / subject=USUBJID type=un r;
    lsmeans TRTGRP*AVISIT / cl COV PDIFF=all;
run;

ods output close;


*----------------------------------------------;
/* Step 3 - Extract Month 6 point estimates   */
*----------------------------------------------;

data _est;
    set _lsmeans;
    if AVISIT = "Month 6";

    if TRTGRP = "Placebo"      then dose = 0;
    if TRTGRP = "Drug X 5 mg"  then dose = 5;
    if TRTGRP = "Drug X 10 mg" then dose = 10;
    if TRTGRP = "Drug X 25 mg" then dose = 25;
    if TRTGRP = "Drug X 50 mg" then dose = 50;

    estimate = Estimate;
    keep dose TRTGRP estimate StdErr;
run;

proc sort data=_est; by dose; run;

proc print data=_est;
    title "Month 6 LSMeans - Point Estimates for MCP-Mod";
run;


*----------------------------------------------;
/* Step 4 - Extract pairwise diffs Month 6    */
*----------------------------------------------;

data _diffs;
    set _diffs;
    if AVISIT = "Month 6" and _AVISIT = "Month 6";
    keep TRTGRP _TRTGRP Estimate StdErr;
run;

proc print data=_diffs;
    title "Month 6 Pairwise Differences - Covariance Input";
run;

*----------------------------------------------;
/* Step 5 - Extract cov matrix at Month 6 */
*----------------------------------------------;

* Keep only Month 6 rows;
* And only the Cov columns corresponding to Month 6;
* Column numbers depend on ordering - confirm from proc print above;
data _cov;
    set _lsmeans;
    if AVISIT = "Month 6";
    keep TRTGRP dose Cov14 Cov8 Cov2 Cov5 Cov11;  
run;


proc print data=_cov;
    title "Covariance Matrix - Month 6";
run;



*----------------------------------------------;
/* Step 6 - Export _est, _diffs, and _cov to R */
/* Conduct MCP-Mod in R                        */
*----------------------------------------------;
* Export estimates;
proc export data=_est
    outfile="Z:\0-SAS Work\0-SDR Project\mcpmod_est.csv"
    dbms=csv 
    replace;
run;

* Export pairwise differences;
proc export data=_diffs
    outfile="Z:\0-SAS Work\0-SDR Project\mcpmod_diff.csv"
    dbms=csv 
    replace;
run;

* Export month 6 covariance matrix;
proc export data=_cov
    outfile="Z:\0-SAS Work\0-SDR Project\mcpmod_cov.csv"
    dbms=csv 
    replace;
run;

