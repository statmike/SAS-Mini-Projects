/*
Compute Summary Counts, Rates, and Signal Scores for PRR based on independence Model
	This file expects the code in "2-Create 2x2.sas" to have run.
		This includes the macro create2x2 which creates work.signal_2x2.
	Inputs:
		ds = dataset name that contains the prod_level, event_level as N11, N12, N21, N22 variables created by "2-Create 2x2.sas"
		prod_level = the column with product or drug codes
			you can use a column that stands for product_characteristic combinations like Product/LOT
			Before feeding the macro create a concatenation of the value you want to feed the macro
		event_level = the column with the event codes
		Z_alpha = 1.96 for 95%, 1.645 for 90%, 2.326 for 98%, 2.576 for 99%
	Output will be Signal_PRR in work library	
*/

%macro disproportionality(ds,outds,prod_level,event_level,Z_alpha,EBGM=N);

	/*******************************************************************
	 * Section 1: Determine type of analysis: Stratification versus none                                          
	 *******************************************************************/
	proc sort data = &ds.; by &prod_level. &event_level.; run;
	data &outds.;
		set &ds.; 
		by &prod_level &event_level; 
		
		Prod_Total = sum(of N11, N12);
		Event_Total = sum(of N11, N21);
		Total = sum(of N11, N12, N21, N22);		
			
			*******************************************************************************************;
			**REFERENCE ARTICLE: [EVANS SJW, WALLER PC, et al. Pharmacoepidemiology and Drug Safety, 2001(10):483-486]**;
			**Calculate Proportional reporting rate for IR(i-drug)/IR(o-drug) based on 2x2 table***;
			**Computations based on Actual Reactions Count. Standard Error or PRR calculated on a logarithmic scale. ****;
			**Reference: Katz D, Baptista J, Aspen SP, et. al. Biometrics, 1978(34): 469-474 **; 		
			**Correct for bias due to possibble small cell count and using large-sample standard error**;
			**Add 0.5 to each cell value in a 2 x 2 table. Reference: Zweiful 1967, Haldane 1955 **;
			***************************************************************************************************;
		/* a reference: http://www.ncbi.nlm.nih.gov/pmc/articles/PMC3834930/ */
		**Calculate RR or RRR: Relative Reporting Ratio**;
			if (N11>0 and N21>0) or (N11>0 and N12>0) then RR = (N11*(Total))/((Prod_Total)+(Event_Total));
			else RR=.;
		** Calculate ROR: Reporting Odds Ratio **;
			if (N12>0 and N21>0) then ROR=(N11*N22)/(N12*N21);
			else ROR=.;
		** Calculate IC: Information Component **;
			if TOTAL>0 then IC=log2((N11+0.5)/((Prod_Total*Event_Total/TOTAL)+0.5));
			else IC=.;
		** Calculate PRR: Proportion Reporting Rate **;
		if (N11>0 and N21>0) then do;
			PRR =( N11/(Prod_Total) )/(N21/(N21+N22));
			LNPRR_SE=sqrt((1/N11) - (1/(Prod_Total)) + (1/N21) - (1/(N21+N22)));
			PRR_LCL =exp(log(PRR) - &Z_alpha. * LNPRR_SE);
			PRR_UCL =exp(log(PRR) + &Z_alpha. * LNPRR_SE);
		end;		
		else do;
			PRR=.; LNPRR_SE=.; prr_lcl=.; prr_ucl=.;
		end;

		***Calculate chi-square and p-value for each 2x2 Drug-Event table**;
		EXP11=Prod_Total*Event_Total/Total;
		EXP12=Prod_Total*(Total-Event_Total)/Total; 
		EXP21=Event_Total*(Total-Prod_Total)/Total;
		EXP22=(Total-Event_Total)*(Total-Prod_Total)/Total; 

		IF (PRR ^=.) THEN DO;
			PRR_CHISQ =	((N11-EXP11)**2)/EXP11 + ((N12-EXP12)**2)/EXP12 + 
						((N21-EXP21)**2)/EXP21 + ((N22-EXP22)**2)/EXP22 ;
			PRR_PVALUE=1-PROBCHI(PRR_CHISQ,1);
			PRR_E11 = (Prod_Total) * N21/(N21+N22);
			PRR_SRR = (N11 + 0.5) / (PRR_E11 + 0.5);
		END;
		ELSE DO;
			PRR_CHISQ =.; PRR_PVALUE=.; 
			PRR_E11   =.; PRR_SRR   =.;
		END;

		FORMAT PRR_PVALUE PVALUE6.4 PRR_CHISQ  RR ROR IC PRR PRR_LCL PRR_UCL 12.3;
		LABEL;
	RUN;
	
	%if &EBGM=Y %then %do;
		%EBGM(&outds,&outds,DrugName,EventName);
	%end;
%mend disproportionality;



