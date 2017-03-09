#Synopsis
The code in this project is used to calculate disproportionality measures on data such as spontaneously reported adverse events.

#Background
In drug adverse event complaints data every case is a response.  This makes signal detection, or finding abnormal drug/event combination, an exercise in finding disproportionately large drug/event reports.
Method for doing this are called disproportionality measures.  Before calculating disproportionality measures it is first important to calculate the information about drug/event combinations with the database such that for all drug/event combination you know:

* N11 is the count for the Product/Event combination
* N12 is the count for the Product and non-Events
* N21 is the count for the Event and Control Products
* N22 is the count for the control event/product combinations

Or

|Drug|Adverse Event|All other Adverse Events|Totals|
|---|---|---|---|
|Drug X|N11|N12|N1.|
|All other Drugs|N21|N22|N2.|
|Totals|N.1|N.2|N..|

#Quick Start - How it Works
Run everything from your code as a call to %disproportionality.
Alternatively, you could run %EBGM alone rather than through %disproportionality.
You will need your data in the form of 2x2 tables for each drug/event combination
These 2x2 tables can be calculated by first running %create2x2 or %create2x2fromcases
* %create2x2 - This takes a table of the form

|Drug|Event|Nij|
|---|---|---|

and creates

|Drug|Event|N11|N12|N21|N22|
|---|---|---|---|---|---|

* %create2x2fromcases - This takes a table of the form (shape=LONG) with one row per Case and Event

|Case|Drug|Event|
|---|---|---|

or a table of the form (shape=WIDE) with one row per Case and an Events column with a delimited list of unique Events during the Case

|Case|Drug|Events|
|---|---|---|

and creates

|Case|Drug|Event|N11|N12|N21|N22|
|---|---|---|---|---|---|---|

where each row is a case/event combination and the Nij are based on HERE MORE

#Details
##Cases versus Events
The distinction between the %create2x2 and %create2x2fromcases macros is very important.
MORE DOCUMENTATION HERE TO EXPLAIN BIAS CAUSED BY INCLUDING ALL DRUG/EVENT COMBOS FROM A SINGLE CASE INDEPENDENTLY

#Example
An example of running this code can be found in "run from here.sas"
Example datasets are provided:
* \example input data\drug_event_example.sas7bdat
  * A typical input dataset with 1 row per drug/event combination that includes a frequency/count for that combination.  Columns: 
    * DrugName - Name of the drug (coded for the sample data but derived from real data for interpretation)
    * EventName - Name of the event (coded for the sample data but derived from real data for interpretation)
    * Nij - The count (frequency) for the row Drug/Event combination
* \example input data\sample_cases.sas7bdat
  * A simulated dataset based on the information in drug_event_example.sas7bdat.  Each Case (Case_N) can have multiple events.  Only 1 drug per case in this simulation.  Columns:
    * Case_N - The ID for the Case.  A case can have multiple events.  In this data there is only 1 drug per case.
    * DrugName - Name of the drug (coded for the sample data but derived from real data for interpretation)
    * EventName - Name of the event (coded for the sample data but derived from real data for interpretation)
* \example input data\sample_case_rows.sas7bdat
  * A derivation of the sample_cases.sas7bdat data where each case (Case_N) is collapsed to a single row with a concatenated list of Events.  Columns:
    * Case_N - The ID for the Case.  A case can have multiple events.  In this data there is only 1 drug per case.
    * DrugName - Name of the drug (coded for the sample data but derived from real data for interpretation)
    * Events - I list of the Events delimited by spaces
* \example input data\textminedcases_train.sas7bdat
* \example input data\textminedcases_transaction.sas7bdat

#/Macros
* %create2x2 - uses input data where each row represents a drug/event combination
  * converts Drug/Event/N11 into Drug/Event/N11/N12/N22/N21
* %cases_to_caserows - converts Case/Drug/Event (where a case can have more than one row) to Case/Drug/Events (where Events is a space delimited list)
* %create2x2fromcases - uses input data where each row represents a case with 1 or more events
  * list=LONG - (default) converts Case/Drug/Event (where a case can have more than one row) to Case/Drug/Events (where Events is a list) then into Drug/Event/N11/N
  * calls the %cases_to_caserows macro
list=WIDE - skips conversion of case list in multiple rows to single row (%cases_to_caserows)
* %disproportionality
  * converts input data from %create2x2 by adding columns for disproportionality metrics
  * optional parameter EBGM=Y is required to request EBGM metrics (by default EBGM=N) - This option will make run time longer
* %ebgm
  * Macro that uses Proc MCMC to estimate parameters and then calculates EBGM metrics
  * This macro can be run alone or requested through %disproportionality

#Call Tree
* %create2x2
* %create2x2fromcases
  * %cases_to_caserows (can also be used standalone)
* %disproportionality
  * %ebgm (can also be used standalone)

#Simulating Cases
* \example input data\simulating cases\simulate_cases.sas
  * see notes in the simulate_cases.sas file
	  * COMPLETE AND DOCUMENT
		* creates the requested number of cases from the distributions of drugs and drug/event combination found in \example input data\drug_event_example.sas7bdat
		* This has already been used to create 10000 cases that can be found in \example input data\sample_cases.sas7bdat and \example input data\sample_case_rows.sas7bdat

#Text Mining for groups of events
See notes in "Text Mining Event Combinations Example.sas"
	
	
#Data Structure
Needs documenting
