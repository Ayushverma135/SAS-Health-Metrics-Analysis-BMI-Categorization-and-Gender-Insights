/*Import data from Excel sheets into SAS*/
filename reffile '/home/u63867400/sasuser.v94/Project 1/STAT.xlsx';
proc import datafile=reffile
dbms=xlsx
out=stat;
getnames=yes;
run;

filename reffile '/home/u63867400/sasuser.v94/Project 1/HIST.xlsx';
proc import datafile=reffile
dbms=xlsx
out=hist;
getnames=yes;
run;

filename reffile '/home/u63867400/sasuser.v94/Project 1/STUDHT.xlsx';
proc import datafile=reffile
dbms=xlsx
out=studht;
getnames=yes;
run;

/*Stack data from STAT and HIST*/
data stathist;
set stat hist;
run;

/*Merging STUDHT to STATHIST*/
proc sort data=stathist;
by name;
run;
proc sort data=studht;
by name;
run;
data statall;
merge stathist studht;
by name;
run;

/*Convert weight and height into metric system and calculate BMI and Categorize them*/
data statall1;
set statall;
weightkg=weight*.454;
heightmt=height*2.54/100;
bmi=weightkg/(heightmt*heightmt);
if bmi<18 then status='Underweight';
else if 18<=bmi<20 then status='Healthy';
else if 20<=bmi<22 then status='Overweight';
else if bmi>=22 then status='Obese';
run;

/*Generate pie chart for STATUS variable*/
proc chart data=statall1;
pie status;
run;


%macro myStat(var1,var2);
/*Create freq. dist. table */
proc freq data = statall1 noprint;
tables &var1*&var2 /out=myFreqTable;
run;

/*create report format*/
data myFreqTable1;
set myfreqtable;
value=cat(count,'(',round(percent,.01),'%)');
drop count percent;
run;

/*transposing variable*/
proc transpose data=myfreqtable1 out=t_myfreq;
by &var1;
id &var2;
var value;
run;

/*Create final report*/
title 'Report of Frequency Table';
proc print data=t_myfreq (drop=_name_);
run;

%mend;

%myStat(gender,status);
%myStat(status,gender);