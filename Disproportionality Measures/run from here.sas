/*
NOTE:
	EBGM metrics can be added to the output through the %disproportionality macro or called separately through %EBGM
	when EBGM is request is can take awhile to execute - the example data provided runs aroun 30 minutes on my laptop
	you can tinker with the MCMC setting within the %EBGM macro - specifically nmc=10000 thin=5 can be altered
	
	The disproportionality will preserve the input dataset and add columns:
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
		These added when EBGM=Y
			EBGM_Unadj
			EBGM
			EBGM05
			EBGM95
*/

libname signal 'C:\PROJECTS\SAS-Mini-Projects\Disproportionality Measures';
%create2x2(signal.drug_event_example,Signal_2x2,DrugName,EventName,Nij);
%disproportionality(Signal_2x2,Signal_disproportionality,DrugName, EventName, 1.96,EBGM=Y);

/*
to call just EBGM you can directly call the %EBGM macro
%EBGM(Signal_2x2,Signal_EBGM,DrugName,EventName);
*/