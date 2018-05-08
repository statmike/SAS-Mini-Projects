# Simulating Data for Spontaneous Adverse Events

---

## Background

When problems, adverse events, occur while taking a drug or using a medical device, they should be reported to the company that created them.  This is called a spontaneous report.  Databases of the reports are mined to uncover possible issues where an event is potentially driven by the use of the drug or device.  Given that these databases only contain responses and are missing all the instances of no event with the drug or device, a different type of analysis is used to find abnormal combinations of drug/event.  These types of analysis are called disproportionality measures.  An overview of common ones of these and how to calculate them can be found in [Disproportionality Measures](../../Disproportionality%20Measures/)

---

## Method of Simulation
To get a simulated sample with meaningful representations of drug/event combinations and representative frequencies, a dataset of coded real adverse events data is used to create distributions: `drug_event_example.sas7bdat`.  This sample data is missing case information so a distribution of expected number of unique events per case is created within the simulation.  By sampling from these distributions the requested number of cases can be simulated.

The simulation code is used to create 4 different example scenarios for adverse event databases.  Each of these differ by the type of information with a case.  
* Example 1 (EX1): each case is a single pair with one drug and one event
* Example 2 (EX2): each case is made up of a single drug and a group of one or more events
* Example 3 (EX3): each case is made up of a group of one or more drugs and a single event
* Example 4 (EX4): each case is made up of a group of one or more drugs and a group of one or more events

---

### Input Data for Simulation
The file `drug_event_example.sas7bdat` is a coded dataset created from a real adverse event database with 385,734 drug/event combinations.

|DrugName|EventName|Nij|
|---|---|---|

   * `DrugName` is a coded value for a drug of the form `DrugX` where `X` is a series of 1 or more captital letters
   * `EventName` is a coded value for a adverse event of the form `EventX` where `X` is a series of 1 or more capital letters
   * `Nij` is the count of occurences for the combination of `DrugName` and `EventName` - this is the `N11` value

**Rather than using the provided file, a similar file could be constructed from an adverse event database and used with this simulation code.**

---

### Output Data from Simulation
The following summarizes each example and the file formats for the output.  A table with the first 5 cases (`Case_N`) is included for review.  These files can be found in subfolder [`examples`](./examples)
* Example 1 (EX1): each case is a single pair with one drug and one event
  * `ex1.sas7bdat`

|Case_N|DrugName|EventName|
|---|---|---|
|1|DrugCJD|EventBBH|
|2|DrugEFG|EventHI|
|3|DrugHAI|EventJBB|
|4|DrugBBJ|EventCIB|
|5|DrugCBC|EventBBB|

* Example 2 (EX2): each case is made up of a single drug and a group of one or more events
  * `ex2_long.sas7bdat`

|Case_N|DrugName|EventName|
|---|---|---|
|1|DrugCJD|EventBBH|
|1|DrugCJD|EventBJI|
|2|DrugEFG|EventCID|
|2|DrugEFG|EventEAA|
|3|DrugHAI|EventDFJ|
|4|DrugBBJ|EventEEH|
|4|DrugBBJ|EventFAD|
|5|DrugCBC|EventBBB|
|5|DrugCBC|EventCDA|
|5|DrugCBC|EventCDG|
|5|DrugCBC|EventCFC|
|5|DrugCBC|EventCID|
|5|DrugCBC|EventCII|
|5|DrugCBC|EventDEE|
|5|DrugCBC|EventEFG|
|5|DrugCBC|EventIEA|
|5|DrugCBC|EventIFB|
|5|DrugCBC|EventJAE|
|5|DrugCBC|EventJEA|
|5|DrugCBC|EventJEH|


  * `ex2.sas7bdat`

|Case_N|DrugName|Events|
|---|---|---|
|1|DrugCJD|EventBBH EventBJI
|2|DrugEFG|EventCID EventEAA
|3|DrugHAI|EventDFJ
|4|DrugBBJ|EventEEH EventFAD
|5|DrugCBC|EventBBB EventCDA EventCDG EventCFC EventCID EventCII EventDEE EventEFG EventIEA EventIFB EventJAE EventJEA EventJEH


* Example 3 (EX3): each case is made up of a group of one or more drugs and a single event
  * `ex3_long.sas7bdat`

|Case_N|DrugName|EventName|
|---|---|---|
|1|DrugCJD|EventBBH
|1|DrugEED|EventBBH
|2|DrugBAEE|EventHI
|2|DrugBAGH|EventHI
|2|DrugBBCF|EventHI
|2|DrugEFG|EventHI
|2|DrugHGB|EventHI
|3|DrugEDC|EventJBB
|3|DrugFIB|EventJBB
|3|DrugHAI|EventJBB
|4|DrugBBJ|EventCIB
|4|DrugGBB|EventCIB
|5|DrugBBEG|EventBBB
|5|DrugCBC|EventBBB
|5|DrugDGB|EventBBB
|5|DrugEEA|EventBBB
|5|DrugJJ|EventBBB

  * `ex3.sas7bdat`

|Case_N|Drugs|EventName|
|---|---|---|
|1|DrugCJD DrugEED|EventBBH|
|2|DrugBAEE DrugBAGH DrugBBCF DrugEFG DrugHGB|EventHI|
|3|DrugEDC DrugFIB DrugHAI|EventJBB|
|4|DrugBBJ DrugGBB|EventCIB|
|5|DrugBBEG DrugCBC DrugDGB DrugEEA DrugJJ|EventBBB|

* Example 4 (EX4): each case is made up of a group of one or more drugs and a group of one or more events
  * `ex4.sas7bdat`

|Case_N|Drugs|Events|
|---|---|---|
|1|DrugBCDD DrugCJD|EventBJI EventBBH EventBJI|
|2|DrugEFG DrugFCH DrugIAG DrugIEE DrugJEC DrugJHF|EventCID EventEAA EventCID EventEAA EventCID EventCID EventEAA|
|3|DrugBBDA DrugEEI DrugGBB DrugHAI DrugIAG|EventDFJ EventDFJ EventDFJ EventDFJ EventDFJ|
|4|DrugBADG DrugBBF DrugBBJ DrugBDGE DrugCGG DrugGBB DrugGCD DrugGGH|EventEEH EventFAD EventEEH EventEEH EventFAD EventEEH EventEEH EventEEH EventEEH EventFAD|
|5|DrugBAB DrugBABD DrugBADG DrugBAEA DrugBAEI DrugBBEG DrugBBGC DrugBBIJ DrugBCAC DrugBCDH DrugBCFI DrugBDAG DrugBDDG DrugBDGG DrugBDJI DrugBF DrugCBC DrugCEA DrugCFH DrugDAJ DrugDEB DrugDEE DrugDFH DrugDGJ|EventCII EventCII EventCFC EventDEE EventBBB EventCDG EventJEH EventCDA EventCDA EventIEA EventCFC EventCDA EventDEE EventBBB EventIFB EventCID EventBBB EventCDA EventCDG EventCFC EventCID EventCII EventDEE EventEFG EventIEA EventIFB EventJAE EventJEA EventJEH EventBBB EventCDG EventBBB EventBBB|

---

### Code for Simulating Cases

#### Setup
The code found in [`simulate_cases`](./simulate_cases.sas) is used to create simulated adverse event databases.  To use this code you need to edit lines 31-42:
```SAS
/* include the macros for building simulated cases (%basecase) and adding drugs (%add_drugs) and events (%add_events) */
		%include './Macros/basecase.sas';
		%include './Macros/add_events.sas';
		%include './Macros/add_drugs.sas';

/* specify output location for the ouput files (sim_out) and the expected input file drug_event_example.sas7bdat (sim_in) */
		libname sim_in 'C:\PROJECTS\SAS-Mini-Projects\Disproportionality Measures\simulating cases';
		libname sim_out 'C:\PROJECTS\SAS-Mini-Projects\Disproportionality Measures\simulating cases\examples';

/* specify parameters for data creation */
		%let NCases=10000; /* how many cases to genereate */
```

#### Running
Running the code as is will create the sample data for the example scenarios mentions above: EX1, EX2, EX3, and EX4.  The long versions of these example scenarios are created with the macro calls on lines 73-77:
```sas
%basecase(core,&NCases.,1);
	%add_events(core,EX1,1);
	%add_events(core,EX2_LONG,-1);
	%add_drugs(EX1,EX3_LONG,-1);
	%add_drugs(EX2_LONG,EX4_LONG,-1);
```
The formatting of these output data and the creation of the single row per case versions is accomplished by the remaining lines of code.

#### Expected Run Time (and suggestions to make it faster)
The examples all include 10,000 cases.  This run of the code took about 1 hour 45 minutes on workstation without competing jobs.  There are several steps that could be taken to make the code run more efficiently.
* Parallelization of the simulated cases with `RSUBMIT` statements (SAS/CONNECT Software)
  * Create batches of simulated cases with separate calls to the macros
  * Combine the separate batches and finish processing
* Parallelization with `RSUBMIT` statements (SAS/CONNECT Software)

  1. Run the First macro call that creates the dataset `core`
  ```SAS
  %basecase(core,&NCases.,1);
  ```
  2. Run the second and third macros at the same time in separate `RSUBMIT` blocks
  ```SAS
  %add_events(core,EX1,1);
  %add_events(core,EX2_LONG,-1);
  ```
  3. Once Step 2 is finished, run the fourth and fifth macros at the same time in separate `RSUBMIT` blocks
  ```sas
  %add_drugs(EX1,EX3_LONG,-1);
  %add_drugs(EX2_LONG,EX4_LONG,-1);
  ```
* Use `Proc FCMP`!  The macros `%add_events` and `%add_drugs` each cycle through each row of the input datasets.  For each row they run a series of `Procs` and `Data Steps`.  By storing this work in function that is created with `Proc FCMP` these could be simply called within a single data step and take advantage of the row level processing in the data step.
  * Once a `Proc FCMP` function is being used at the row level in a SAS data step you could further parallelize the operation:
    * General: segment the input data and launch multiple processes with `RSUBMIT`
    * Use `Proc DS2` with `threads` to spread the computation over multiple cores
    * `Data Step` in SAS Viya to automatically spread the computation of multiple cores, even over multiple machines

---

### Review and Further uses for the provided code

#### Macro [`%basecase`](./Macros/basecase.sas)
* Create a dataset with columns `Case_N` and `DrugName`.  Creates the number of cases specified by the input `reps`.  Samples the number of drugs per case specified by input `n_drugs`.
* Inputs:
  * `outds` - the name for the output dataset.
    * This can be a libname.dataname value as well.
  * `reps` - specifies the number of cases to create.
    * This will result in `Case_N` value from 1 to `reps`.
  * `n_drugs` - specifies how many drugs to sample for each case.
    * Some cases may end up with fewer drugs if the same drug gets randomly selected multiple times as duplicates are removed.
    * specifying `-1` will trigger a random number of drugs to be sampled for the case and will result in 1 to 7 drugs being added to the case.
      * The distribution for this sampling can be found on line 80 and can be edited for the preferred behavior.
      ```sas
      if &n_drugs.<0 then n_drugs=rand("Table",.3,.3,.2,.10,.05,.03,.02);
      ```

#### Macro [`%add_events`](./Macros/add_events.sas)
* Modifies the input dataset by adding events for each distinct combination of `Case_N` and `DrugName`.  The events will be sampled from the distribution of known events reported for the drug.  If events are already in the input dataset they will be preserved and new events added without duplication.
* Inputs:
  * `inds` - the name of the input dataset.
    * Preferably, this is the output of `%basecase` but can be any dataset with required columns `Case_N` and `DrugName`.
    * Cannot be the same name as `outds`.
  * `outds` - the name of the output dataset.
    * Cannot be the same name as `inds`
  * 'N_EVENTS' - specifies the number events to sample and add for each distinct combination of `Case_N` and `DrugName`.
    * If the same `EventName` value is sampled multiple times it will only show up once as duplicates are removed
    * specifying `-1` will trigger a random number of events to be sampled for the scenario and will result in 1 to 13 events being added to the case.
      * The distribution for this sampling can be found on line 137 and can be edited for the preferred behavior.
      ```sas
      if &N_EVENTS.<0 then N_EVENTS=rand("Table",.3,.2,.15,.10,.05,.05,.05,.05,.01,.01,.01,.01,.01);
      ```

#### Macro [`%add_drugs`](./Macros/add_drugs.sas)
* Modifies the input dataset by adding drugs for each distinct combination of `Case_N` and `EventName`.  The drugss will be sampled from the distribution of known drugs reported for the event.  If drugs are already in the input dataset they will be preserved and new drugs added without duplication.
* Inputs:
  * `inds` - the name of the input dataset.
    * Required to have columns `Case_N` and `EventName`
    * Cannot be the same name as `outds`.
  * `outds` - the name of the output dataset.
    * Cannot be the same name as `inds`
  * 'N_DRUGS' - specifies the number drugs to sample and add for each distinct combination of `Case_N` and `EventName`.
    * If the same `DrugName` value is sampled multiple times it will only show up once as duplicates are removed
    * specifying `-1` will trigger a random number of drugs to be sampled for the scenario and will result in 1 to 7 drugs being added to the case.
      * The distribution for this sampling can be found on line 218 and can be edited for the preferred behavior.
      ```sas
      if &N_DRUGS.<0 then N_DRUGS=rand("Table",.3,.3,.2,.10,.05,.03,.02);
      ```

#### Further Notes on Macro Usage
* `%add_events` can be called multiple times.
  * It can be used to add events to any dataset with columns `Case_N` and `DrugName`
  * Will not duplicate values for `EventName` within a distinct combination of 'Case_N' and `DrugName`
* `%add_drugs` can be called multiple times.
  * It can be used to add drugs to any dataset with columns `Case_N` and `EventName`
  * Will not duplicate values for `DrugName` within a distinct combination of `Case_N` and `EventName`
* To create cases with multiple drugs and multiple events, simply add events first then drugs.  This is covered in Example 4 above.
