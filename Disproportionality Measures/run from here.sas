/*
NOTE:
	EBGM metrics can be added to the output through the %disproportionality macro or called separately through %EBGM
	When EBGM is requested it can take awhile to execute - the example data provided runs around 30 minutes on my laptop
	You can tinker with the MCMC settings within the %EBGM macro - specifically nmc=10000 thin=5 can be altered
	
	The disproportionality macro will preserve the input dataset columns and add columns:
		Prod_Total
		Event_Total
		Total
		RR
		ROR
		IC
		PRR
		LNPRR_SE
		PRR_LCL
		PRR_UCL
		EXP11
		EXP12
		EXP21
		EXP22
		PRR_CHISQ
		PRR_PVALUE
		PRR_E11
		PRR_SRR
		These are added when EBGM=Y
			EBGM_Unadj
			EBGM
			EBGM05
			EBGM95
*/

libname signal 'C:\PROJECTS\SAS-Mini-Projects\Disproportionality Measures\example input data';

/* use the drug_event_example data that has DrugName\EventName\Nij 
	this assumes all events are independent
	for case level data see the next example below
*/
%create2x2(signal.drug_event_example,Signal_2x2,DrugName,EventName,Nij);
%disproportionality(Signal_2x2,Signal_disproportionality,DrugName,EventName,1.96,EBGM=N);
	/*
	to call just the EBGM macro you can directly call the %EBGM macro
	%EBGM(Signal_2x2,Signal_EBGM,DrugName,EventName);
	*/

/* use the sample_cases data that has Case_N\DrugName\EventName
	this evaluates events without double counting cases
*/
%create2x2fromcases(signal.sample_cases,Signal_2x2_cases,case_n,DrugName,EventName,shape=LONG);
%disproportionality(Signal_2x2_cases,Signal_Cases_disproportionality,DrugName,EventName,1.96,EBGM=N);




/* use the sample_cases data while ignoring the case and compare the results for PRR between the two methods */
data sample_cases; set signal.sample_cases; Nij=1; run;
%create2x2(sample_cases,Signal_2x2,DrugName,EventName,Nij);
%disproportionality(Signal_2x2,Signal_2x2_disproportionality,DrugName,EventName,1.96,EBGM=N);

		Proc sql;
			create table compare_cases as
				select a.DrugName, a.EventName, a.PRR as PRR_CASE, b.PRR as PRR_2x2, a.PRR-b.PRR as PRR_DIFF
					from
						(select DrugName, EventName, PRR from signal_cases_disproportionality) a
						left outer join
						(select DrugName, EventName, PRR from signal_2x2_disproportionality) b
						on a.DrugName=b.DrugName and a.EventName=b.EventName
			;
		quit;
		proc univariate data=compare_cases;
			var PRR_DIFF;
		run;
		data compare_cases; set compare_cases; split=(PRR_DIFF>100 or PRR_DIFF<-100); run;
		proc sgplot data=compare_cases;
			title 'Difference in PRR: Cases minus Independent';
			histogram PRR_DIFF;
		run;
		proc sgplot data=compare_cases;
			title 'Difference in PRR: Cases minus Independent';
			title2 'Data inside abs(100)';
			where split=0;
			histogram PRR_DIFF;
		run;
			proc sgplot data=compare_cases;
			title 'Difference in PRR: Cases minus Independent';
			title2 'Data outside abs(100)';
			where split=1;
			histogram PRR_DIFF;
		run;
