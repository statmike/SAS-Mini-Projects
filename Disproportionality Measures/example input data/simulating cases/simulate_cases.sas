/* this file contains the code, including local macros, to create a simulated dataset with cases of adverse events
	
	This file has already be used to create 10,000 cases and those files can be found in:
		C:\PROJECTS\SAS-Mini-Projects\Disproportionality Measures\example input data\
			sample_cases.sas7bdat -  1 row per case with events listed in Events column with space delimitter
			sample_case_rows.sas7bdat - 1 row for each EventName in each Case_N
			
	This file uses 
		C:\PROJECTS\SAS-Mini-Projects\Disproportionality Measures\example input data\drug_event_example.sas7bdat
		The distritions of drugs and drug\events from this file are used in the simulation
		
	The simulated cases do the following:
		%sim_signal(10000); request 10000 cases
			builds a case file with 1 row per case
				assigns a drug by randomly sampling from the distribution of drugs in drug_event_example.sas7bdat
				assigns a number of events from a provided distribution - see and alter code below - uses table distribution
				calls %add_event to create events for the case
					looks at the distribution of events for the cases randomly selected drug within drug_event_example.sas7bdat
					assigns events (with replacement) for the requested number of events
					removes duplicate events due to random sampling with replacement

*/

/* specify output location for the two ouput files - also expects drug_event_example to be located here */
	libname sim 'C:\PROJECTS\SAS-Mini-Projects\Disproportionality Measures\example input data';
/* specify parameters for data creation */
	%let NCases=10000; /* how many cases to genereate */
	%let FileStart=Sample; /* will be the start of the output filenames - X_Cases, X_Case_Rows */
	%let SEED=54321; /* specify a seed value for repeatability */

Proc sql;
/* add percentage to events within drugs - the DE_percent will represent the % of reports for that Drug that are the specific event */
	create table drug_event as
		select a.DrugName, a.EventName, a.Nij as DE_COUNT, b.D_COUNT, a.Nij/b.D_COUNT as DE_PERCENT, C.E_COUNT, a.TOTAL
		from
			(select DrugName, EventName, Nij, sum(Nij) as TOTAL from sim.drug_event_example) a
			left outer join
			(select DrugName, sum(Nij) as D_COUNT from sim.drug_event_example group by DrugName) b
			on a.DrugName=b.DrugName
			left outer join
			(select EventName, sum(Nij) as E_COUNT from sim.drug_event_example group by EventName) c
			on a.EventName=c.EventName
		order by a.DrugName, a.EventName
	;
/* Drugs table with column D_PERCENT = proportion of reports that are for the specific drug */
	create table drugs as
		select distinct DrugName, D_COUNT, TOTAL, D_COUNT/TOTAL as D_PERCENT
		from drug_event
	;
quit;


/* creates table sample_drugs with Case_N, DrugName, EventName */
%macro sim_signal(reps);

	proc sql noprint;
		select D_Percent into :D_PCT separated by ' ' from drugs;
		select "'"||strip(DrugName)||"'" into :DRUGS separated by ' ' from drugs;
		select count(*) into :COUNT from drugs;
	quit;
	data sample_drugs;
		array drugs [&COUNT.] $ _TEMPORARY_ (&DRUGS.);
		array p [&COUNT.] _TEMPORARY_ (&D_PCT.);
		call streaminit(%eval(&SEED.+1));
		do Case_N = 1 to &reps.;
			DrugName=drugs[rand("Table", of p[*])];
			/* my example database does not have case info so have to create distribution of number of events per cases */
			N_EVENTS=rand("Table",.4,.2,.1,.05,.05,.05,.05,.05,.01,.01,.01,.01,.01);
			output;
		end;
	run;
	proc freq data=sample_drugs;
		table N_Events / plots=FreqPlot(scale=percent);
	run;
	
	%do i = 1 %to &reps.;
	    /* add events to the case with this macro call */
		%add_events(&i.);
	%end;
	
%mend sim_signal;

		/* for each Case_N in sample_drugs created by %sim_signal add Events - this is called multiple times to create a case */
		%macro add_events(i);
			/* called by %sim_signal, adds an event to a case */
			proc sql noprint;
				select DrugName, N_Events 
					into :DrugName, :N_EVENTS
					from sample_drugs
					where Case_N=&i.
				;
			quit;
		
			proc sql noprint;
				select DE_Percent into :DE_PCT separated by ' ' from drug_event where DrugName="&DrugName.";
				select "'"||strip(EventName)||"'" into :EVENTS separated by ' ' from drug_event where DrugName="&DrugName.";
				select count(*) into :COUNT from drug_event where DrugName="&DrugName.";	
			quit;
			
			data sample_events;
				array events [&COUNT.] $ _TEMPORARY_ (&EVENTS.);
				array p [&COUNT.]  _TEMPORARY_ (&DE_PCT.);
				call streaminit(&SEED.);
				Case_N=&i.;
				do EVENT_N = 1 to &N_EVENTS.;
					EventName=events[rand("Table", of p[*])];
					output;
				end;
			run;
			
			proc sql noprint undo_policy=NONE;
				create table sample_events as
					select distinct Case_N, EventName
					from sample_events
				;
				create table sample as
					select a.Case_N, a.DrugName, B.EventName from
						(select Case_N, DrugName from sample_drugs where Case_N=&i.) a
						left outer join
						(select Case_N, EventName from sample_events where Case_N=&i.) b
						on a.Case_N=b.Case_N
				;
			quit;
			
			%if &i=1 %then %do;
				data Sample_Cases; set sample; run;
			%end;
			%else %do;
				proc append base=Sample_Cases data=Sample; run;
			%end;
		
		%mend add_events;


/* this will run for a long time
	turning off notes and source code in the log as it will get very long otherwise
*/
options nosource nonotes;
	%sim_signal(&Ncases.);
options source notes;

/* move Sample_Cases to permanent library and clean up work */
proc sql noprint;
	create table sim.Sample_Cases as
		select * from Sample_Cases
	;
	drop table drugs;
	drop table sample_drugs;
	drop table drug_event;
	drop table sample_events;
	drop table sample;
	drop table Sample_Cases;
quit;

/* create a table with 1 row per case 
	the following has also been turned into a macro: /Macros/%cases_to_caserows
*/
data sim.Sample_Case_Rows;
	retain Case_N DrugName Events;
	length Events $300.;
		do until(last.Case_N);
			set sim.Sample_Cases;
			by Case_N;
			Events=catx(' ',Events,EventName);
		end;
	drop EventName;
run;
