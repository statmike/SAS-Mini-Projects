
Run everything from your code as a call to %disproportionality
	You will need your data in the form of 2x2 tables for each drug/event combination
	These 2x2 tables can be calculated by first running %create2x2 or %create2x2fromcases
		%create2x2 - This takes a table of the form Drug/Event/Nij and creates Drug/Event/N11/N12/N21/N22
		%create2x2fromcases - This takes a table of the for Case/Drug/Event that can have more than one row for each case and create Case/Drug/Events where events is a space delimited list
	Alternatively, you could run %EBGM alone rather than through %disproportionality
	
Cases versus Events
	The distinction between the %create2x2 and %create2x2fromcases macros is very important.
	
	MORE DOCUMENTATION HERE TO EXPLAIN BIAS CAUSED BY INCLUDING ALL DRUG/EVENT COMBOS FROM A SINGLE CASE INDEPENDENTLY
	
Example of running this code can be found in "run from here.sas"
	example datasets are provided: 
		\example input data\drug_event_example.sas7bdat
			A typical input dataset with 1 row per drug/event combination that includes a frequency/count for that combination.
			Columns: 
				DrugName - Name of the drug (coded for the sample data but derived from real data for interpretation)
				EventName - Name of the event (coded for the sample data but derived from real data for interpretation)
				Nij - The count (frequency) for the row Drug/Event combination
		\example input data\sample_cases.sas7bdat
			A simulated dataset based on the information in drug_event_example.sas7bdat.  Each Case (Case_N) can have multiple events.  Only 1 drug per case in this simulation.
			Columns:
				Case_N - The ID for the Case.  A case can have multiple events.  In this data there is only 1 drug per case.
				DrugName - Name of the drug (coded for the sample data but derived from real data for interpretation)
				EventName - Name of the event (coded for the sample data but derived from real data for interpretation)
		\example input data\sample_case_rows.sas7bdat
			A derivation of the sample_cases.sas7bdat data where each case (Case_N) is collapsed to a single row with a concatenated list of Events.
			Columns:
				Case_N - The ID for the Case.  A case can have multiple events.  In this data there is only 1 drug per case.
				DrugName - Name of the drug (coded for the sample data but derived from real data for interpretation)
				Events - I list of the Events delimited by spaces
		\example input data\textminedcases_train.sas7bdat
		\example input data\textminedcases_transaction.sas7bdat
		
/Macros
	%create2x2 - uses input data where each row represents a drug/event combination
		converts Drug/Event/Nij into Drug/Event/N11/N12/N22/N21
			N11 is the count for the Product/Event combination
			N12 is the count for the Product and non-Events
			N21 is the count for the Event and Control Products
			N22 is the count for the control event/product combinations
	%cases_to_caserows - converts Case/Drug/Event (where a case can have more than one row) to Case/Drug/Events (where Events is a space delimited list)
	%create2x2fromcases - uses input data where each row represents a case with 1 or more events
		list=LONG - (default) converts Case/Drug/Event (where a case can have more than one row) to Case/Drug/Events (where Events is a list) then into Drug/Event/N11/N
			calls the %cases_to_caserows macro
		list=WIDE - skips conversion of case list in multiple rows to single row (%cases_to_caserows)
	%disproportionality
		converts input data from %create2x2 by adding columns for disproportionality metrics
		optional parameter EBGM=Y is required to request EBGM metrics (by default EBGM=N) - This option will make run time longer
	%ebgm
		Macro that uses Proc MCMC to estimate parameters and then calculates EBGM metrics
		This macro can be run alone or requested through %disproportionality
	
Call Tree:
	%create2x2
	%create2x2fromcases
		%cases_to_caserows (can also be used standalone)
	%disproportionality
		%ebgm
	%ebgm
	
Simulating Cases
	\example input data\simulating cases\simulate_cases.sas
	see notes in the simulate_cases.sas file
	COMPLETE AND DOCUMENT
		creates the requested number of cases from the distributions of drugs and drug/event combination found in \example input data\drug_event_example.sas7bdat
		This has already been used to create 10000 cases that can be found in \example input data\sample_cases.sas7bdat and \example input data\sample_case_rows.sas7bdat

Text Mining for groups of events
	see notes in "Text Mining Event Combinations Example.sas"
	
	
Data Structure:
	Needs documenting
		
