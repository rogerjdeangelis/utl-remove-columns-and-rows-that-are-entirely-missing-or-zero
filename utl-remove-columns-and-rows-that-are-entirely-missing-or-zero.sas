StackOverflow: Remove columns and rows that are entirely missing or zero

    Two Solutions
           a. R   (elegant)
           b. SAS

github
https://tinyurl.com/w9ku2a7
https://github.com/rogerjdeangelis/utl-remove-columns-and-rows-that-are-entirely-missing-or-zero

stackoverflow
https://tinyurl.com/sb5wfjw
https://stackoverflow.com/questions/59556229/drop-both-row-and-column-satisfying-condition-in-symmetric-dataframe

Ronak Shah
https://stackoverflow.com/users/3962914/ronak-shah

*_                   _
(_)_ __  _ __  _   _| |_
| | '_ \| '_ \| | | | __|
| | | | | |_) | |_| | |_
|_|_| |_| .__/ \__,_|\__|
        |_|
;

data have;
 input v1-v5;
cards4;
1 1 0 1 1
2 2 0 2 2
0 0 0 0 0
3 3 0 3 3
4 4 0 4 4
;;;;
run;quit;


WORK.HAVE total obs=5


                 REMOVE
                 ******
Obs    V1    V2    V3    V4    V5

 1      1     1     0     1     1
 2      2     2     0     2     2

 3      0     0     0     0     0   ** REMOVE

 4      3     3     0     3     3
 5      4     4     0     4     4


*            _               _
  ___  _   _| |_ _ __  _   _| |_
 / _ \| | | | __| '_ \| | | | __|
| (_) | |_| | |_| |_) | |_| | |_
 \___/ \__,_|\__| .__/ \__,_|\__|
                |_|
;

WORK.WANT total obs=4

  V1    V2    V4    V5

   1     1     1     1
   2     2     2     2
   3     3     3     3
   4     4     4     4

*          _       _   _
 ___  ___ | |_   _| |_(_) ___  _ __  ___
/ __|/ _ \| | | | | __| |/ _ \| '_ \/ __|
\__ \ (_) | | |_| | |_| | (_) | | | \__ \
|___/\___/|_|\__,_|\__|_|\___/|_| |_|___/
 ____
|  _ \
| |_) |
|  _ <
|_| \_\

;
* pretty elegant;

 1. remove rows where number of zeroes across columns equals the number of columns
 2. remove columns where number of zeroes across rows equals the number of rows

* input;
libname sd1 "d:/sd1";
options validvarname=upcase;
data sd1.have;
 input v1-v6;
cards4;
1 1 0 1 1
2 2 0 2 2
0 0 0 0 0
3 3 0 3 3
4 4 0 4 4
;;;;
run;quit;


proc datasets lib=work;
 delete want;
run;quit;

%utlfkil(d:/xpt/want.xpt);

%utl_submit_r64('
library(haven);
library(SASxport);
have<-read_sas("d:/sd1/have.sas7bdat");
want<-have[rowSums(have == 0) != ncol(have), colSums(have == 0) != nrow(have)];
write.xport(want,file="d:/xpt/want.xpt");
');

libname xpt xport "d:/xpt/want.xpt";
data want;
  set xpt.want;
run;quit;
libname xpt clear;


*
 ___  __ _ ___
/ __|/ _` / __|
\__ \ (_| \__ \
|___/\__,_|___/

;

data have;
 input v1-v5;
cards4;
1 1 0 1 1
2 2 0 2 2
0 0 0 0 0
3 3 0 3 3
4 4 0 4 4
;;;;
run;quit;


data want;

   if _n_=0 then do; %let rc=%sysfunc(dosubl('
         * get columns to drop;
         proc transpose data=have out=havxpo;
         run;quit;
         data _null_;
            length drp $200;
            retain drp;
            set havXpo end=dne;
            if std(of _numeric_)=0 and max(of _numeric_)=0  then drp=catx(" ",drp,_name_);
            if dne then call symputx('drp',drp);
         run;quit;
         '));
   end;

   set have (drop=&drp);
   if std(of _numeric_)=0 and max(of _numeric_)=0 then delete;

run;quit;


