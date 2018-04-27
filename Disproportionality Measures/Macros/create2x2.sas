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
*/



%macro create2x2(inds,outds,case_level,prod_level,event_level);

	data events(rename=(holder=&event_level.));
		set &inds.;
		do i = 1 by 1 while(scan(&event_level.,i,' ')^=' ');
			holder=scan(&event_level.,i,' ');
			output;
		end;
		keep &case_level. holder;
	run;
	data prods(rename=(holder=&prod_level.));
		set &inds.;
		do i = 1 by 1 while(scan(&prod_level.,i,' ')^=' ');
			holder=scan(&prod_level.,i,' ');
			output;
		end;
		keep &case_level. holder;
	run;
	proc sql noprint undo_policy=NONE;
		create table events as
			select distinct &case_level., &event_level.
			from events
		;
		create table prods as
			select distinct &case_level., &prod_level.
			from prods
		;
		create table prod_event as
			select a.&case_level., a.&prod_level., b.&event_level.
			from
				prods a
				left outer join
				events b
			on a.&case_level.=b.&case_level.
			order by a.&case_level., a.&prod_level.
		;
	quit;

	proc sql noprint;
		create table n11 as
			select &prod_level., &event_level., count(*) as N11
			from prod_event
			group by &prod_level., &event_level.
		;
		create table n1x as
			select &prod_level., count(*) as N1x
			from prods
			group by &prod_level.
		;
		create table nx1 as
			select &event_level., count(*) as Nx1
			from events
			group by &event_level.
		;
		select count(*) into :TOTAL 
			from (select distinct &case_level. from prods)
		;
		create table &outds as
			select a.&prod_level., a.&event_level., N11, (N1x-N11) as N12, (Nx1-N11) as N21, 
					&TOTAL.-(N1x-N11)-N11-(Nx1-N11) as N22
			from work.n11 a, work.n1x b, work.nx1 c
			where
				a.&prod_level.=b.&prod_level.
				and
				a.&event_level.=c.&event_level.
		;
		drop table N11;
		drop table N1x;
		drop table Nx1;
		drop table events, prods, prod_event;
	quit;

%mend create2x2;



