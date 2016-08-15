%macro combine_macros(dir,file=allmacros,SUB=N);

	/*
		This macro combines all .sas files in the specified folder into a single file called allmacros.sas
		The intended purpose is using the input &dir to specify a folder with files containing macros
		
		Additionally, changing the optional macro variable SUB to SUB=Y will cause the macro to look for all .sas files
			where the subpaths of the path specified by &dir contains a folder called macros (in any case).  
			This includes subfolders.
		
		Inputs:
			dir = path for with you want to combine .sas file
			SUB
				N = do not include subfolder and include all .sas files in the specified &dir
				Y = comb subfolders and include all .sas files in subfolders called macros (any case)
					this includes the current folder if called 'Macros'
	*/
	
	*filename maclist pipe 'dir "&dir.\*.sas" /s /b'; /* quotes are messed up */
	filename maclist pipe %unquote(%bquote(')dir "&dir.\*.sas" %bquote(/s /b'));
	data tempmaclist;
		infile maclist truncover;
		input maclist $200.;
		if "&sub."='Y' and index(lowcase(maclist),'\macros\')>0 then output;
		/* need to filter to just the requested folder if SUB=N */
		else if "&sub."='N' then do;
			checkstr=substr(maclist,length("&dir.")+2); /* +2 to move forward and skip the \ */
			if index(checkstr,'.sas7bdat')=0 and index(checkstr,'\')=0 then output;
		end;
		drop checkstr;
	run;
	*proc print data=tempmaclist; run;
	proc sql noprint;
		select "'"||strip(maclist)||"'" into :maclist separated by ' ' from tempmaclist;
		select count(*) into :maclistsize from tempmaclist;
	quit;
	/* the following loop removes the current output file - this turns out to not be needed as the output will overwrite if it already exist */
	%if &maclistsize.>0 %then %do;
		data _null_;
		    fname="tempfile";
		    rc=filename(fname,"&dir.\&file..sas");
		    if rc = 0 and fexist(fname) then
		       rc=fdelete(fname);
		    rc=filename(fname);		
		run;
	%end;
	%put &maclist;
	%put &maclistsize;
	filename maclist (&maclist.);
	data tempmaclist;
		infile maclist truncover;
		input maclist $250.;
	run;
	/* output the code to a file */
	data _null_;
		set tempmaclist;
		file "&dir.\&file..sas";
		put maclist;
	run;
	proc sql;
		drop table tempmaclist;
	quit;
	
%mend combine_macros;