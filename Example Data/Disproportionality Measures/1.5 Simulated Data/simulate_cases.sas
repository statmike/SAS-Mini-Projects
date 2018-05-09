
/* include the macros for building simulated cases (%basecase) and adding drugs (%add_drugs) and events (%add_events) */
		%include './Macros/basecase.sas';
		%include './Macros/add_events.sas';
		%include './Macros/add_drugs.sas';
		%include './Macros/caserows.sas';

/* specify output location for the ouput files (sim_out) and the expected input file drug_event_example.sas7bdat (sim_in) */
		libname sim_in '../Input Data';
		libname sim_out './examples';

%LET NCases=10000;

options nosource nonotes;
	%basecase(core,&NCases.,1);
		%add_events(core,EX1,1);
		%add_events(core,EX2_LONG,-1);
		%add_drugs(EX1,EX3_LONG,-1);
		%add_drugs(EX2_LONG,EX4_LONG,-1);
options source notes;

%caserows(EX2_LONG,EX2);
%caserows(EX3_LONG,EX3);
%caserows(EX4_LONG,EX4);

options compress=yes;

/* move Sample_Cases to permanent library and clean up work */
proc sql noprint;
	create table sim_out.EX1 as select Case_N, DrugName as Drugs, EventName as Events from EX1;
	create table sim_out.EX2_LONG as select Case_N, DrugName as Drugs, EventName as Events from EX2_LONG;
	create table sim_out.EX3_LONG as select Case_N, DrugName as Drugs, EventName as Events from EX3_LONG;
	create table sim_out.EX2 as select * from EX2;
	create table sim_out.EX3 as select * from EX3;
	create table sim_out.EX4 as select * from EX4;
	drop table core;
	drop table core EX1, EX2, EX3, EX2_LONG, EX3_LONG, EX4, EX4_LONG;
quit;
