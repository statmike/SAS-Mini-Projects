/* create the Nij (2x2) tables from the signal.sas7bdat dataset created by "1 - Read Data.sas" 
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
		to save computation time simple calculations of N11, N1*, N*1, and Total are used to calculate:
		N12=N1*-N11
		N21=N*1-N11
		N22=Total-N11-N12-N21
	The Macro Expects
		ds =  dataset name
		prod_level = the column with product or drug codes
			you can use a column that stands for product_characteristic combinations like Product/LOT
			Before feeding the macro create a concatenation of the value you want to feed the macro
		event_level = the column with the event codes
		countvar = column with the counts for the rows values of prod_level and event_level
			if your data is 1 row per event then create a column with value 1 to feed this place
	diagnostics to see duplicate entries
			proc sql;
				select count(*) from (Select distinct DrugName, EventName from signal.signal);
				select sum(Nij) from signal.signal;
			quit;
			proc sql;
				create table test as
					select drugname, eventname, count(*) as nrows
					from signal.signal
					group by drugname, eventname
				;
				create table test as select * from test where nrows>1; 
			quit;
*/

%macro create2x2(ds,outds,prod_level,event_level,countvar);
	Proc sql;
		create table work.n11 as
			select &prod_level, &event_level, sum(&countvar) as N11
			from &ds
			group by &prod_level, &event_level
		;
	quit;
	proc sql noprint;
		create table work.N1x as
			select &prod_level, sum(&countvar) as N1x
			from &ds
			group by &prod_level
		;
		create table work.Nx1 as
			select &event_level, sum(&countvar) as Nx1
			from &ds
			group by &event_level
		;
		select sum(&countvar) into :TOTAL from &ds;
		create table &outds as
			select a.&prod_level, a.&event_level, N11, (N1x-N11) as N12, (Nx1-N11) as N21, 
					&TOTAL-(N1x-N11)-N11-(Nx1-N11) as N22 /*, &TOTAL as TOTAL */
			from work.n11 a, work.n1x d, work.nx1 e
			where
				a.&prod_level=d.&prod_level
				and
				a.&event_level=e.&event_level
		;
		drop table N11;
		drop table N1x;
		drop table Nx1;
	quit;

%mend create2x2;




