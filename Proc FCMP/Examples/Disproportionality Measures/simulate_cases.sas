/* lineage
	original dispro
	parallel
	two here in this folder
		optimized original: sql
		hash version - no sql
	next.... FCMP of the HASH
	next.... DS2 of HASH and/or FCMP
	next Viya
*/


/* include the macros for building simulated cases (%basecase) and adding drugs (%add_drugs) and events (%add_events) */
		%include './Macros/basecase.sas';
		*%include './Macros/add_events.sas';
		*%include './Macros/add_drugs.sas';

/* specify output location for the ouput files (sim_out) and the expected input file drug_event_example.sas7bdat (sim_in) */
		libname sim_in '../../../Disproportionality Measures/simulating cases';
		libname sim_out './examples';

%LET NCases=10000;
/* not HASH
options nosource nonotes;
	%basecase(core,&NCases.,1);
		%add_events(core,EX1,1);
		%add_events(core,EX2_LONG,-1);
		%add_drugs(EX1,EX3_LONG,-1);
		%add_drugs(EX2_LONG,EX4_LONG,-1);
options source notes;
*/
/* with HASH */
%include './Macros/add_events_hash.sas';
%include './Macros/add_drugs_hash.sas';
*options nosource nonotes;
	%basecase(core,&NCases.,1);
		%add_events(core,EX1,1);
			*%add_events(EX1,EX1a,1);
			*%add_events(EX1a,EX1b,1);
		%add_events(core,EX2_LONG,-1);
		%add_drugs(EX1,EX3_LONG,-1);
		%add_drugs(EX2_LONG,EX4_LONG,-1);
options source notes;
/**/


/* create a table with 1 row per case */
data EX2;
	length Events $500.;
		do until(last.Case_N);
			set EX2_LONG;
			by Case_N;
			Events=catx(' ',Events,EventName);
		end;
	drop EventName;
run;
data EX3;
	length Drugs $500.;
		do until(last.Case_N);
			set EX3_LONG;
			by Case_N;
			Drugs=catx(' ',Drugs,DrugName);
		end;
	drop DrugName;
run;
data EX4;
	length Drugs $500. Events $500.;
		do until(last.Case_N);
			set EX4_LONG;
			by Case_N;
			Drugs=catx(' ',Drugs,DrugName);
			Events=catx(' ',Events,EventName);
		end;
	drop DrugName EventName;
run;

options compress=yes;

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
