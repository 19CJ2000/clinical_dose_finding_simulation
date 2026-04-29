*============================================*;
/* Descriptive Analysis (Brief)              */
/* adsl, adlb, and adtte simulated data      */
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

* Import ADTTE table;
proc import datafile="Z:\0-SAS Work\0-SDR Project\adtte_final.csv"
    out= adtte
    dbms=csv
    replace;
    getnames=yes;
run;


* Check table contents;
proc contents data=adsl; run;
proc contents data=adlb; run;
proc contents data=adtte; run;

* Preview first 50 rows;
proc print data=adsl(obs=50); run;
proc print data=adlb(obs=50); run;
proc print data=adtte(obs=50); run;



* Total subjects by treatment group;
proc freq data=adsl;
  tables TRTGRP;
run;


* Population flags; 
proc freq data=adsl;
  tables ITTFL PPFL SAFFL / nocum;
run;

* Dropout and event summaries;
proc freq data=adsl;
  tables DROPOUTFL*TRTGRP EVENTFL*TRTGRP;
run;


*Baseline Characteristics (ADSL): Continuous: Age & Baseline LVEF;
proc means data=adsl mean std min max;
  class TRTGRP;
  var AGE BASELVEF;
run;

* Baseline Characteristics (ADSL): Categorical: Sex & Race;
proc freq data=adsl;
  tables SEX*TRTGRP RACE*TRTGRP / nocum nopercent;
run;


* Mean LVEF and Change from Baseline by Visit;
proc means data=adlb mean std n;
  class TRTGRP AVISIT;
  var AVAL CHG;
run;


* Event and Censoring Summary by Treatment Group;
proc freq data=adtte;
    tables (CNSR CNSRTYPE) * TRTGRP / nocum nopercent nocol;
    title 'Event and Censoring Summary by Treatment Group';
run;


* AVAL (Months) Summary by Treatment Group;
proc means data=ADTTE n mean min max;
    class TRTGRP;
    var AVAL;
    title 'AVAL (Months) Summary by Treatment Group';
run;

