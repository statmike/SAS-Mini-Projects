/* code to read a directory, find .sas files, open and replace strings, save */



filename DIRLIST pipe 'dir "D:\CODE To Change Text in Directory\stp" /s';
data dirlist;
     length buffer $256 ;
     infile dirlist length=reclen ;
     input buffer $varying256. reclen ;
		buffer=strip(buffer);
		if substr(buffer,1,9)='Directory' then mark=1;
		if reverse(substr(strip(reverse(buffer)),1,4))='.sas' then mark=2;
		if mark=. then delete;
		if mark=1 then buffer=substr(buffer,14);
		if mark=2 then do;
			buffer=strip(substr(buffer,21));
			buffer=substr(buffer,indexc(buffer,' ')+1);
		end;
run;


data dirlist; set dirlist; retain directory;
	if mark=1 then directory=buffer;
	if mark=1 then delete;
	rename buffer=file;
	drop mark;
	full=strip(directory)||'\'||strip(buffer);
run;



data _null_;
	set dirlist;
	*if _n_=5 then do;
	call execute('
					data read;
						infile "'||full||'" lrecl=250 pad ;
						input @1 str $char250.;
					run;'||
					"data _null_;
						set read;

						str = trim( str );
						length_of_line = length( str );

						str=tranwrd(str,'C:\','D:\');"||

						'file "'||full||'";
						put  str $varying250. length_of_line;
					run;
				');
	*end;
run;
