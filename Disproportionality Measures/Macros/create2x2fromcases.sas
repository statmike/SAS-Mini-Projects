/* create the Nij (2x2) tables from the input dataset
	Description of the 2 By 2 Margins
		N1* is the row for the Product
		N2* is the row for the "Other" values of product - the controls
		N*1 is the column for the Event
		N*2 is the column for the "Other" values of Event - the controls
	Description of the cells
		N11 is the count for the Product/Event combination
		N12 is the count for the Product and non-Events
		N21 is the count for the Event and Control Products
		N22 is the count for the control event/product combinations
	Method
		to save computation time the more simple calculations of N11, N1*, N*1, and Total are used to calculate:
		N12=N1*-N11
		N21=N*1-N11
		N22=Total-N11-N12-N21
	The create2x2fromcases macro expects case data
		ds =  dataset name
		outds = output dataset name
		case_level = the column with the case ID
		prod_level = the column with product or drug codes
			you can use a column that stands for product_characteristic combinations like Product/LOT
			Before feeding the macro, create a concatenation of the value you want to feed the macro
		event_level = the column with the event codes
		shape = 
			LONG - each row has 1 &event_level associated with the &case_level.  can have multiple rows per &case_level
				triggers the calling of the %cases_to_caserows macro to make a 1 row per case version of the data
			WIDE - each &case_level has 1 row with &event_level being a concatenated list of events space delimited
*/

%macro create2x2fromcases(ds,outds,case_level,prod_level,event_level,shape=LONG);

	%if &shape=LONG %then %do;
		%cases_to_caserows(&ds.,caserows,&case_level.,&prod_level.,&event_level.);
		/* the caserows dataset will return with columns:
				&case_level
				&prod_level
				Events
		*/
		proc sql;
			create table cases as
				select distinct &case_level., &prod_level., &event_level.
				from &ds.
			;
		quit;
	%end;
	%else %if &shape=WIDE %then %do;
		data caserows; set &ds.;
			Events=&event_level.;
		run;
		data cases;
			set caserows;
			do i = 1 by 1 while(scan(Events,i,' ')^=' ');
				&event_level.=scan(Events,i,' ');
				output;
			end;
		run;
		proc sql noprint undo_policy=NONE;
			create table cases as
				select distinct &case_level., &prod_level., &event_level.
				from cases
			;
		quit;
	%end;

	proc sql noprint;
		create table n11 as
			select &prod_level., &event_level., count(*) as N11
			from cases
			group by &prod_level., &event_level.
		;
		create table n1x as
			select &prod_level., count(*) as N1x
			from (select distinct &case_level., &prod_level. from cases)
			group by &prod_level.
		;
		create table nx1 as
			select &event_level., count(*) as Nx1
			from (select distinct &case_level., &event_level. from cases)
			group by &event_level.
		;
		select count(*) into :TOTAL 
			from (select distinct &case_level. from cases)
		;
		create table &outds as
			select a.&prod_level., a.&event_level., N11, (N1x-N11) as N12, (Nx1-N11) as N21, 
					&TOTAL.-(N1x-N11)-N11-(Nx1-N11) as N22 /*, &TOTAL as TOTAL */
			from work.n11 a, work.n1x d, work.nx1 e
			where
				a.&prod_level.=d.&prod_level.
				and
				a.&event_level.=e.&event_level.
		;
		drop table N11;
		drop table N1x;
		drop table Nx1;
		drop table cases;
		drop table caserows;
	quit;

%mend create2x2fromcases;




