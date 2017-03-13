#Simulating Data for Spontaneous Adverse Events

##Background
When problems, adverse events, occur while taking a drug or using a medical device, they should be reported to the company that created them.  This is called a spontanous report.  Databases of the reports are mined to uncover potential issues where an event is potentially driven by the use of the drug or device.  Given that these databases only contain responses and are missing all the instances of no event with the drug or device, a different type of analysis is used to find abnormal combinations of drug/event.  These types of analysis are called disproportionality measures.  An overview of common ones of these and how to calculate them can be found in [Disproportionality Measures](../../.)

##Method of Simulation
To get a simulated sample with meaningful representations of drug/event combinations and representative frequencies, a dataset of coded real adverse events data is used to create distributions: `drug_event_example.sas7bdat` in [/example input data](../).  This sample data is missing case information so a distribution of expected number of unique events per case is created within the simulation.

* `drug_event_example.sas7bdat` is a coded dataset created from a real adverse event database with 385,734 drug/event combinations

  |DrugName|EventName|Nij|
  |---|---|---|

    * `DrugName` is a coded value for a drug of the form `DrugX` where `X` is a series of 1 or more captital letters
    * `EventName` is a coded value for a adverse event of the form `EventX` where `X` is a series of 1 or more capital letters
    * `Nij` is the count of occurences for the combination of `DrugName` and `EventName` - this is the `N11` value

##How to Simulate Cases
The code found in [`%simulate_cases`](./simulate_cases.sas) is used to create simulated adverse event databases.  To use this code you need to edit rows 24-29:
```SAS
/* specify output location for the two ouput files - also expects drug_event_example.sas7bdat to be located here */
	libname sim 'C:\PROJECTS\SAS-Mini-Projects\Disproportionality Measures\example input data';
/* specify parameters for data creation */
	%let NCases=10000; /* how many cases to genereate */
	%let FileStart=Sample; /* will be the start of the output filenames - X_Cases.sas7bdat, X_Case_Rows.sas7bdat */
	%let SEED=54321; /* specify a seed value for repeatability */
```

This will create `sample_case_rows.sas7bdat` and `sample_cases.sas7bdat` within [/Disproportionality Measures/example input data/](../):
* `sample_case_rows.sas7bdat` is a 1 row per case file with 10,000 cases

  |Case_N|DrugName|Events|
  |---|---|---|

    * `Case_N` is an indentifier for a unique adverse event case
    * `DrugName` is a coded value for a drug of the form `DrugX` where `X` is a series of 1 or more capital letters
    * `Events` is a string of 1 or more space delimittted coded values for adverse events of the form `EventX` where `X` is a series of 1 or more capital letters

* `sample_cases.sas7bdat` is long version of `sample_case_rows.sas7bdat` where each `Event` string has been parsed into a single row for each `EventName` for a total of 31,451 drug/event occurences (reports).

  |Case_N|DrugName|EventName|
  |---|---|---|

    * `Case_N` is an indentifier for a unique adverse event case
    * `DrugName` is a coded value for a drug of the form `DrugX` where `X` is a series of 1 or more captital letters
    * `EventName` is a coded value for a adverse event of the form `EventX` where `X` is a series of 1 or more capital letters