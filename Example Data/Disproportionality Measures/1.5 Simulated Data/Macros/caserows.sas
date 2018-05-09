/* Creates &outds from &inds to contain one row per Case_N
	by putting &prod_level and &event_level values in space delimited list */
%macro caserows(inds,outds,prod_level,event_level);

	proc sql noprint;
		create table tevent as select distinct Case_N, &event_level. from &inds.;
		create table tdrug as select distinct Case_N, &prod_level. from &inds.;
	quit;
	data tevent;
		length Events $500.;
			do until(last.Case_N);
				set tevent;
				by Case_N;
				Events=catx(' ',Events,&event_level.);
			end;
		drop EventName;
	run;
	data tdrug;
		length Drugs $500.;
			do until(last.Case_N);
				set tdrug;
				by Case_N;
				Drugs=catx(' ',Drugs,&prod_level.);
			end;
		drop DrugName;
	run;
	proc sql noprint;
		create table &outds. as
			select a.Case_N, a.Drugs, b.Events from
				(select * from tdrug) a
				left outer join
				(select * from tevent) b
				on a.Case_N=b.Case_N
		;
		drop table tevent, tdrug;
	quit;

%mend caserows;
