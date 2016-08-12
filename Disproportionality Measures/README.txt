
Run everything from your code as a call to %disproportionality
	You will need your data in the form of 2x2 tables for each drug/event combination
	These 2x2 tables can be calcualted by first running %create2x2
		This takes a table of the form Drug/Event/Nij and creates Drug/Event/N11/N12/N21/N22
	Alternatively you could run %EBGM alone rather than through %disproportionality
	
Example of this code can be found in "run from here.sas"
	An example dataset is provided: drug_event_example.sas7bdat
		has columns DrugName, Event_Name, Nij

/Macros
	%create2x2
		converts Drug/Event/Nij into Drug/Event/N11/N12/N22/N21
			N11 is the count for the Product/Event combination
			N12 is the count for the Product and non-Events
			N21 is the count for the Event and Control Products
			N22 is the count for the control event/product combinations
	%disproportionality
		converts input data from %create2x2 by adding columsn for disproportionality metrics
		open EBGM=Y is required to request EBGM metrics (by default EBGM=N) - This option will make run time longer
	%ebgm
		Macro that uses Proc MCMC to estimate parameters and then calculates EBGM metrics
		This macro can be run alone or request through %disproportionality
	
Call Tree:
	%create2x2
	%disproportionality
		%ebgm
	%ebgm
			
Data Structure:
	Need documenting
		
