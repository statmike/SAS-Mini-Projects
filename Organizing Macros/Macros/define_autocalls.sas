%macro define_autocalls(dir,sub=N,level=session);

	/*
		code to setup the system option
			OPTIONS SASAUTOS=("c:\myautocalls\dir" SASAUTOS)
			
		Inputs:
			dir = directory to add to SASAUTOS system option
			sub =
				N = add the provided directors in parameter &dir
				Y = comb the provided directory and sub directories for folders names Macros (any case)
					add these to the SASAUTOS systme option
			level=session
				only valid option at this time - not used 
	*/
	
	%if &SUB=N %then %do;
		OPTIONS SASAUTOS=("&dir." SASAUTOS);
	%end;
	
	%else %if &SUB=Y %then %do;
		*filename maclist pipe 'dir "&dir.\*.sas" /s /b'; /* quotes are messed up */
		filename maclist pipe %unquote(%bquote(')dir "&dir.\*.sas" %bquote(/s /b'));
		data tempmaclist;
			infile maclist truncover;
			input maclist $200.;
			if index(lowcase(maclist),'\macros\')>0;
			maclist=strip(maclist);
			*rmaclist=strip(reverse(maclist));
			*break_size=index(rmaclist,'\');
			*break_spot=length(maclist)-break_size;
			*maclist=substr(maclist,1,break_spot);
			maclist=substr(maclist,1,length(maclist)-index(strip(reverse(maclist)),'\'));
			*drop break: rmaclist;
		run;
		proc sql noprint;
			select distinct '"'||strip(maclist)||'"' into :maclist separated by ' ' from tempmaclist;
		quit;
		%put &maclist.;
		OPTION SASAUTOS=(&maclist. SASAUTOS);
		proc options option=sasautos; run;
		proc sql;
			drop table tempmaclist;
		quit;
	%end;	
	
%mend define_autocalls;