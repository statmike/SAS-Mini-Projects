%macro caserows(inds,outds);

	proc sql noprint;
		create table tevent as select distinct Case_N, EventName from &inds.;
		create table tdrug as select distinct Case_N, DrugName from &inds.;
	quit;
	data tevent;
		length Events $500.;
			do until(last.Case_N);
				set tevent;
				by Case_N;
				Events=catx(' ',Events,EventName);
			end;
		drop EventName;
	run;
	data tdrug;
		length Drugs $500.;
			do until(last.Case_N);
				set tdrug;
				by Case_N;
				Drugs=catx(' ',Drugs,DrugName);
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
