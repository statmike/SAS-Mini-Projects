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

ods html5;
ods graphics on;

/* include the macros */
%include './Macros/create2x2.sas';
%include './Macros/disproportionality.sas';
%include './Macros/EBGM.sas';

/* define a library where the input data is located.  This library points to the simulated data example */
/* 10,000 Cases - does not work well for EBGM */
  *libname sim_in '../Example Data/Disproportionality Measures/1 - Simulated Data/examples';
/* 250,000 Cases */
  *libname sim_in '../Example Data/Disproportionality Measures/2 - Parallel/examples';
/* 500,000 Cases */
  libname sim_in '../Example Data/Disproportionality Measures/3 - HASH/examples';

/* Example 1 - Each case is a single pair with one drug and one event*/
        /* Create the 2x2 tables from the drug/event pairs */
        %create2x2(sim_in.ex1,ex1,Case_N,DrugName,EventName);
        /* add the disproportionality measures to the 2x2 data */
        %disproportionality(ex1,ex1a,DrugName,EventName,1.96,EBGM=N);
        /* add the disporportionality measures, including EBGM, to the 2x2 data */
        %disproportionality(ex1,ex1b,DrugName,EventName,1.96,EBGM=Y);
        /* add just the EBGM measures to the 2x2 data */
        %EBGM(ex1a,ex1a,DrugName,EventName);


/* Example 2 - each case is made up of a single drug and a group of one or more events */
        /* Wide Data where events are a delimited list */
                /* Create the 2x2 tables and add the disproportionality measures including EBGM */
                %create2x2(sim_in.ex2,ex2,Case_N,DrugName,Events);
                %disproportionality(ex2,ex2,DrugName,Events,1.96,EBGM=Y);

        /* Long Data where the drug/event pairs are on separate rows linked by the Case_N variable */
                /* Create the 2x2 tables and add the disproportionality measures including EBGM */
                %create2x2(sim_in.ex2_long,ex2_long,Case_N,DrugName,EventName);
                %disproportionality(ex2_long,ex2_long,DrugName,EventName,1.96,EBGM=Y);


/* Example 3 - each case is made up of a group of one or more drugs and a single event */
        /* Wide Data where drugs are a delimited list */
                /* Create the 2x2 tables and add the disproportionality measures including EBGM */
                %create2x2(sim_in.ex3,ex3,Case_N,Drugs,EventName);
                %disproportionality(ex3,ex3,Drugs,EventName,1.96,EBGM=Y);

        /* Long Data where the drug/event pairs are on separate rows linked by the Case_N variable */
                /* Create the 2x2 tables and add the disproportionality measures including EBGM */
                %create2x2(sim_in.ex3_long,ex3_long,Case_N,DrugName,EventName);
                %disproportionality(ex3_long,ex3_long,DrugName,EventName,1.96,EBGM=Y);


/* Example 4 - each case is made up of a group of one or more drugs and a group of one or more events */
        /* In this scenario, only wide data will work.  Drugs and Events are each provided in delimited list where each row is a distinct case */
        %create2x2(sim_in.ex4,ex4,Case_N,Drugs,Events);
        %disproportionality(ex4,ex4,Drugs,Events,1.96,EBGM=Y);
