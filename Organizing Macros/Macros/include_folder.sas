%macro include_folder(dir,SUB=N,SOURCE2=N);

	/*
		This macro does a %include for all .sas files in the specified folder.
		The intended purpose is using the input &dir to specify a folder with files containing macros
		
		Additionally, changing the optional macro variable SUB to SUB=Y will cause the macro to look for all .sas files
			where the subpaths of the path specified by &dir contains a folder called macros (in any case).  
			This includes subfolders.
		
		Inputs:
			dir = path for with you want to %include .sas file
			SUB
				N = do not include subfolder and include all .sas files in the specified &dir
				Y = comb subfolders and include all .sas files in subfolders called macros (any case)
			SOURCE2
				N = default - does not use the option Source2 on the %include so log does not print contents of files
				Y = uses the option source2 on the %include so the log does print contents of files included
	*/
	
	%if &SUB=N %then %do;
		filename macdir "&dir";
		%if &SOURCE2=N %then %do;
			%include macdir('*.sas');
		%end;
		%else %if &SOURCE2=Y %then %do;
			%include macdir('*.sas') / source2;
		%end;
	%end;
	
	%else %if &SUB=Y %then %do;
		*filename maclist pipe 'dir "&dir.\*.sas" /s /b'; /* quotes are messed up */
		filename maclist pipe %unquote(%bquote(')dir "&dir.\*.sas" %bquote(/s /b'));
		data _null_; /* for debugging give this a name */
			infile maclist truncover;
			input maclist $200.;
			if index(lowcase(maclist),'\macros\')>0 then do;
				%if &SOURCE2=N %then %do;
					call execute(cats('%include ',quote(trim(maclist)),';'));
				%end;
				%else %if &SOURCE2=Y %then %do;
					call execute(cats('%include ',quote(trim(maclist)),' / source2;'));
				%end;
			end;
		run;
	%end;
	
%mend include_folder;
