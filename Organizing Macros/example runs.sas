/* examples of running these macros */

%let dir=C:\PROJECTS\SAS-Mini-Projects\Disproportionality Measures;
options mprint;

/* include files in a folder */
	/* include files in specified folder - do not display source in log */
	%include_folder(&dir.\macros,SUB=N,SOURCE2=N);
	/* include files in specified folder - display source in log */
	%include_folder(&dir.\macros,SUB=N,SOURCE2=Y);
	/* include files in subfolders named macros - display source in log */
	%include_folder(&dir.,SUB=Y,SOURCE2=Y);
	/* include files in specified folder named macros and subfolders - display source in log */
	%include_folder(&dir.\macros,SUB=Y,SOURCE2=Y);
	
/* combine macros into a single file */
	/* create allmacros.sas file in macros folder - no subfolders */
	%combine_macros(&dir.\macros,file=allmacros,SUB=N);
	/* create allmacros.sas file in current folder - looks for macros subfolders */
	%combine_macros(&dir.,file=allmacros,SUB=Y);
	/* create allmacros.sas file in current folder - no subfolders or requirement for folder to be "macros" */
	%combine_macros(&dir.,file=allmacros,SUB=N);
	
/* define autocall locations */
	/* system level
			edit the !sasroot\nls\en\sasv9.cfg file
			look for -SET SASAUTOS
			add paths to the list
	*/
	/* session level
		OPTIONS SASAUTOS=("c:\myautocalls\dir" "SASEnvironment/sasMacro" SASAUTOS)
	*/
	%define_autocalls(&dir,sub=Y);
		/* example - these should now work 
			NOTE - if you try running a macro in a session and later add it to the SASAUTOS it will not be found until you have a new session
		*/
		libname signal 'C:\PROJECTS\SAS-Mini-Projects\Disproportionality Measures';
		%create2x2(signal.drug_event_example,Signal_2x2,DrugName,EventName,Nij);