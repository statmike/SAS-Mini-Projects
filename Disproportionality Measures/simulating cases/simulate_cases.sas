/*
	this file contains the code, including local macros, to create simulated datasets with 10,000 cases under four scenarios:
			1 - single product and single event
			2 - single product and multiple events
			3 - multiple products and single event
			4 - multiple products and multiple events

	these are the datasets that get created in library sim:
		EX1.sas7bdat - independent pairs of product/event
				each row is product/event pair where rows are considered independent
		EX2_LONG.sas7bdat - cases with a single product and multiple events
				each row is a product/event pair and multiple rows for multiple events are grouped by a case
		EX2_WIDE.sas7bdat - cases with a single product and multiple events
				each row is a case with product and a column containing a delimited list of associated events
		EX3_LONG.sas7bdat - cases with multiple products and a single event
		 		each row is a product/event pair and multiple rows for multiple products are grouped by a case
		EX3_WIDE.sas7bdat - cases with multiple products and a single event
		 		each row is a case with event and a column containing a delimited list of associated products
		EX4_LONG.sas7bdat - cases with multiple products and multiple events
				each row is a product/event pair and multiple rows for multiple products and events are grouped by a case
		EX4_WIDE.sas7bdat - cases with multiple products and multiple events
				each row is a case with columns containing a delimited list of products and a delimited list of events

	This is an input file with known distributions for a set of drugs and events
		drug_event_example.sas7bdat

	The simulated cases do the following:


*/

/* specify output location for the ouput files (sim_out) and the expected input file drug_event_example.sas7bdat (sim_in) */
		libname sim_in 'C:\PROJECTS\SAS-Mini-Projects\Disproportionality Measures\simulating cases';
		libname sim_out 'C:\PROJECTS\SAS-Mini-Projects\Disproportionality Measures\simulating cases\example input data';

/* specify parameters for data creation */
		%let NCases=10000; /* how many cases to genereate */
		%let SEED=54321; /* specify a seed value for repeatability */

/* create information tables: drug_event, drugs, events */
		Proc sql;
		/* add percentage to events within drugs - the DE_percent will represent the % of reports for that Drug that are the specific event */
			create table drug_event as
				select a.DrugName, a.EventName, a.Nij as DE_COUNT, b.D_COUNT, a.Nij/b.D_COUNT as DE_PERCENT, a.Nij/c.E_Count as ED_PERCENT, C.E_COUNT, a.TOTAL
				from
					(select DrugName, EventName, Nij, sum(Nij) as TOTAL from sim_in.drug_event_example) a
					left outer join
					(select DrugName, sum(Nij) as D_COUNT from sim_in.drug_event_example group by DrugName) b
					on a.DrugName=b.DrugName
					left outer join
					(select EventName, sum(Nij) as E_COUNT from sim_in.drug_event_example group by EventName) c
					on a.EventName=c.EventName
				order by a.DrugName, a.EventName
			;
		/* Drugs table with column D_PERCENT = proportion of reports that are for the specific drug */
			create table drugs as
				select distinct DrugName, D_COUNT, TOTAL, D_COUNT/TOTAL as D_PERCENT
				from drug_event
			;
		/* Evemts table with column E_PERCENT = proportion of reports that are for the specific event */
			create table events as
				select distinct EventName, E_COUNT, TOTAL, E_COUNT/TOTAL as E_PERCENT
				from drug_event
			;
		quit;

/* create base case with first drug(s): &OUTDS with Case_N, DrugName */
		%macro basecase(outds,reps,n_drugs);

			proc sql noprint;
				select D_Percent into :D_PCT separated by ' ' from drugs;
				select "'"||strip(DrugName)||"'" into :DRUGS separated by ' ' from drugs;
				select count(*) into :COUNT from drugs;
			quit;
			data basecase;
				array drugs [&COUNT.] $ _TEMPORARY_ (&DRUGS.);
				array p [&COUNT.] _TEMPORARY_ (&D_PCT.);
				call streaminit(&seed.);
				do Case_N = 1 to &reps.;
					if &n_drugs.<0 then n_drugs=rand("Table",.3,.3,.2,.10,.05,.03,.02);
						else n_drugs=&n_drugs.;
					do nd = 1 to n_drugs;
						DrugName=drugs[rand("Table", of p[*])];
						output;
					end;
				end;
				drop nd n_drugs;
			run;
			proc sql;
				create table &outds. as select distinct Case_n, DrugName from basecase;
				drop table basecase;
			quit;

		%mend basecase;

/* for each distinct (Case_N and DrugName) add EventName (&N_EVENTS): &OUTDS with Case_N, DrugName, EventName
		NOTES:
			run %basecase first to create the &inds
			requires different names for &inds and &outds
			you can call the macro iteratively to add more events
				%basecase(core,&NCases.,1);
					%add_events(core,EX1a,&NCases.,1);
					%add_events(EX1a,EX1b,&NCases.,1);
					%add_events(EX1b,EX1c,&NCases.,1);
					%add_events(EX1c,EX1d,&NCases.,-1);
*/
		%macro add_events(inds,outds,N_EVENTS);

			proc sql noprint;
				create table key as select distinct Case_N, DrugName from &inds.;
				select count(*) into :key from key;
			quit;
			data key; set key; key=_n_; run;

			%do i = 1 %to &key.;
					/* store in macro variables: case_n, DrugName, N_Events */
					proc sql noprint;
						select distinct Case_N, DrugName
							into :Case_N, :DrugName
							from key
							where key=&i.
						;
					quit;

					/* store DE_PCT, Events, COUNT macro variable from Drug_Event where DrugName is the drug on current Case_N*/
					proc sql noprint;
						select DE_Percent into :DE_PCT separated by ' ' from drug_event where DrugName="&DrugName.";
						select "'"||strip(EventName)||"'" into :EVENTS separated by ' ' from drug_event where DrugName="&DrugName.";
						select count(*) into :COUNT from drug_event where DrugName="&DrugName.";
					quit;

					data caseevents;
						array events [&COUNT.] $ _TEMPORARY_ (&EVENTS.);
						array p [&COUNT.]  _TEMPORARY_ (&DE_PCT.);
						call streaminit(-1);
						key=&i.;
						if &N_EVENTS.<0 then N_EVENTS=rand("Table",.3,.2,.15,.10,.05,.05,.05,.05,.01,.01,.01,.01,.01);
						else N_EVENTS=&N_EVENTS.;
						do EVENT_N = 1 to N_EVENTS;
							lookup=rand("Table", of p[*]);
								if lookup>&COUNT. then lookup=int(&COUNT.*rand("Uniform",0,1)+1);
							EventName=events[lookup];
							output;
						end;
						keep key EventName;
					run;

					proc sql noprint undo_policy=NONE;
						create table caseevents2 as
							select a.Case_N, a.DrugName, B.EventName from
									(select Case_N, DrugName, key from key where key=&i.) a
									left outer join
									(select distinct key, EventName from caseevents where key=&i.) b
									on a.key=b.key
						;
					quit;

					proc append base=add_events data=caseevents2; run;

			%end;

			proc sql;
				create table add_events_final as
					select * from &inds.
						union
						select * from add_events
					order by Case_N, DrugName, EventName
				;
				create table &outds. as select distinct Case_N, DrugName, EventName from add_events_final where EventName;
				drop table caseevents, caseevents2, add_events, add_events_final;
				drop table key;
			quit;

		%mend add_events;

/* for each distinct (Case_N and EventName) add DrugName (&N_Drugs): &OUTDS with Case_N, DrugName, EventName
		NOTES:
			run %basecase first then
				run %add_events to create the &inds
			requires different names for inds and outds
			you can call the macro iteratively to add more drugs
				%basecase(core,&NCases.,1);
					%add_events(core,EX1,&NCases.,1);
					%add_drugs(EX1,EX1a,&NCases.,1);
					%add_drugs(EX1a,EX1b,&NCases.,1);
					%add_drugs(EX1b,EX1c,&NCases.,-1);
*/
		%macro add_drugs(inds,outds,N_DRUGS);

			proc sql noprint;
				create table key as select distinct Case_N, EventName from &inds.;
				select count(*) into :key from key;
			quit;
			data key; set key; key=_n_; run;

			%do i = 1 %to &key.;
					/* store in macro variables: case_n, DrugName, N_Events */
					proc sql noprint;
						select distinct Case_N, EventName
							into :Case_N, :EventName
							from key
							where key=&i.
						;
					quit;

					/* store ED_PCT, Events, COUNT macro variable from Drug_Event where DrugName is the drug on current Case_N*/
					proc sql noprint;
						select ED_Percent into :ED_PCT separated by ' ' from drug_event where EventName="&EventName.";
						select "'"||strip(DrugName)||"'" into :DRUGS separated by ' ' from drug_event where EventName="&EventName.";
						select count(*) into :COUNT from drug_event where EventName="&EventName.";
					quit;

					data caseevents;
						array drugs [&COUNT.] $ _TEMPORARY_ (&DRUGS.);
						array p [&COUNT.]  _TEMPORARY_ (&ED_PCT.);
						call streaminit(-1);
						key=&i.;
						if &N_DRUGS.<0 then N_DRUGS=rand("Table",.3,.3,.2,.10,.05,.03,.02);
						else N_DRUGS=&N_DRUGS.;
						do DRUG_N = 1 to N_DRUGS;
							lookup=rand("Table", of p[*]);
								if lookup>&COUNT. then lookup=int(&COUNT.*rand("Uniform",0,1)+1);
							DrugName=drugs[lookup];
							output;
						end;
						keep key DrugName;
					run;

					proc sql noprint undo_policy=NONE;
						create table caseevents2 as
							select a.Case_N, b.DrugName, a.EventName from
									(select Case_N, EventName, key from key where key=&i.) a
									left outer join
									(select distinct key, DrugName from caseevents where key=&i.) b
									on a.key=b.key
						;
					quit;

					proc append base=add_drugs data=caseevents2; run;

			%end;

			proc sql;
				create table add_drugs_final as
					select * from &inds.
						union
						select * from add_drugs
					order by Case_N, DrugName, EventName
				;
				create table &outds. as select distinct Case_N, DrugName, EventName from add_drugs_final where DrugName;
				drop table caseevents, caseevents2, add_drugs, add_drugs_final;
				drop table key;
			quit;

		%mend add_drugs;

options nosource nonotes;
%basecase(core,&NCases.,1);
	%add_events(core,EX1,1);
	%add_events(core,EX2_LONG,-1);
	%add_drugs(EX1,EX3_LONG,-1);
	%add_drugs(EX2_LONG,EX4_LONG,-1);
options source notes;




/* create a table with 1 row per case
	the following has also been turned into a macro: /Macros/%cases_to_caserows
*/
data EX2;
	length Events $300.;
		do until(last.Case_N);
			set EX2_LONG;
			by Case_N;
			Events=catx(' ',Events,EventName);
		end;
	drop EventName;
run;
data EX3;
	length Drugs $300.;
		do until(last.Case_N);
			set EX3_LONG;
			by Case_N;
			Drugs=catx(' ',Drugs,DrugName);
		end;
	drop DrugName;
run;
data EX4;
	length Drugs $300. Events $300.;
		do until(last.Case_N);
			set EX4_LONG;
			by Case_N;
			Drugs=catx(' ',Drugs,DrugName);
			Events=catx(' ',Events,EventName);
		end;
	drop DrugName EventName;
run;

/* move Sample_Cases to permanent library and clean up work */
proc sql noprint;
	create table sim_out.EX1 as
		select * from EX1
	;
	create table sim_out.EX2_LONG as
		select * from EX2_LONG
	;
	create table sim_out.EX3_LONG as
		select * from EX3_LONG
	;
	create table sim_out.EX2 as select Case_N, DrugName, Events from EX2;
	create table sim_out.EX3 as select Case_N, Drugs, EventName from EX3;
	create table sim_out.EX4 as select Case_N, Drugs, Events from EX4;
	drop table core;
	drop table drugs;
	drop table drug_event;
	drop table events;
	drop table EX1, EX2, EX3, EX2_LONG, EX3_LONG, EX4, EX4_LONG;
quit;
