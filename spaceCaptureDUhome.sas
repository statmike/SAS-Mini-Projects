options obs=max ls=140 nocenter replace=yes missing='' nospool bufsize=256k ubufsize=256k  bufno=16 nodate ;

libname outdd1 '/data/common/data';
run;

*** read all directories in _dir ***;

%let _tdate=%sysfunc(putn("&sysdate9"d,worddate20.));
%let _fdate=%sysfunc(putn("&sysdate9"d,yymmddn8.));

%sysexec du /home > du_home.txt;

data duHome(drop=x y line1 _size); 
  infile 'du_home.txt' missover lrecl=32767 length=l end=eof;  
  attrib _size       length=$8.
         _directory  length=$200.
  ;
 
   input @ ;
   input line1 $varying200. l;
   x=length(line1);
   y=index(line1,'/');
   if line1 in('.','..') then delete;
   _size=substr(line1,1,y-1);
   _directory=substr(line1,y,x-1);
   _owner=scan(substr(line1,y+1,x-1),2,'/');
   space=input(_size,best12.)*1000; 
   space_fmt=put(space,sizekmg.2);
   if _directory=trim('/home/'||_owner);
   _runDate=today();
   _runTime=put(time(),hhmm.);
run; 

proc sort data=duHome;
  by descending space;
run;

proc append base=outdd1.HomeDirSpace data=duHome FORCE ;
run;

proc sort data=outdd1.HomeDirSpace nodupkey;
  by _owner _runDate;
run;

proc print data=outdd1.HomeDirSpace;
  format _runDate yymmdd10.;
run;

data duhome;
  set duHome;
  where _owner ne 'bwasicak';
run;

PROC TEMPLATE;
  DEFINE STYLE myocean; 
    PARENT=styles.ocean;
    REPLACE TABLE FROM OUTPUT /
    FRAME = void
    RULES = rows
    CELLPADDING = 3pt
    CELLSPACING = 0.0pt
    BORDERWIDTH = 0.2pt;
  END;
RUN; 

ODS PDF FILE="/root/spacePDFs/Egsas04p_HomeDir_&_fdate..pdf" STYLE=myocean;

proc print data=duHome(obs=10) obs='*Rank' label split='*';
  title "Top Ten directorys for &_tdate";
  where _owner ne 'bwasicak';
  label _directory='/home*directory'
        _owner='*Owner'
        space_fmt='directory*space use'
        ;
  var _owner _directory space_fmt;
run;

ODS PDF CLOSE; 

****  put email here   ***; 
filename outbox email 'bob.wasicak@orbitz.com' lrecl=125; 
run;

data _null_;
  file outbox
    /* Overrides value in filename statement */
     /* to=('bob.wasicak@orbitz.com') */ 
     subject='Daily top ten space users'
     type="TEXT/HTML" 
     attach="/root/spacePDFs/Egsas04p_HomeDir_&_fdate..pdf" ; 
     put 'Bob,';
     put 'Today s  Top ten on the egsas04p.prod.orbitz.net server';
     put ////;
run;

%sysexec rm du_home.txt;
%sysexec rm spaceCaptureDUhome.lst;
%sysexec chmod 500 Egsas04p_HomeDir_*.pdf;
