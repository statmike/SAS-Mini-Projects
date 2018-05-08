# How to Get Started:

* [`examples.sas`](examples.sas) demonstrates running the **macros** for different **data scenarios** using **simulated data**:
  * **Macros**
    * [`create2x2`](./Macros/create2x2.sas)
      * converts a file of adverse event cases into a dataset with drug/event pairs and the associated 2x2 table data (N11, N12, N21, N22)
    * [`disproportionality.sas`](./Macros/disproportionality.sas)
      * calculates many common disproportionality measures and adds them to the input table of drug/event pairs and 2x2 table data
    * [`ebgm.sas`](./Macros/ebgm.sas)
      * caculates EBGM measures and adds them to the input table of drug/event pairs and 2x2 table data
  * **Data scenarios**
    * The `example.sas` code has examples of running the macros with data in different scenarios.  These scenarios are covered in more detail in the `simulating cases` [readme](../Example%20Data/Disproportionality%20Measures/readme.md) file
      * Example 1 (EX1): each case is a single pair with one drug and one event
      * Example 2 (EX2): each case is made up of a single drug and a group of one or more events
      * Example 3 (EX3): each case is made up of a group of one or more drugs and a single event
      * Example 4 (EX4): each case is made up of a group of one or more drugs and a group of one or more events

  * **Simulated Data**
    * The `simulating cases` [readme](../Example%20Data/Disproportionality%20Measures/readme.md) file covers the details of how the simulated adverse event datasets are created and how the macros within that code could be used to simulate additional scenarios. This includes simulating cases based on adverse event databases you have access to.

---

# Updates needed below here

---
---
---
---
---

New outline:
 synopsis
 getting started
 background
 macros
  create 2x2
  disproportionality
  ebgm
 Examples
 Future Development ideas
  graphics and tables for review

 ---

## Synopsis
The code in this project is used to calculate disproportionality measures on data such as spontaneously reported adverse events.

## Background
In drug adverse event complaints data every case is a response.  This makes signal detection, or finding abnormal drug/event combinations, an exercise in finding disproportionately large drug/event reports.
Methods for doing this are called disproportionality measures.  Before calculating disproportionality measures it is first important to calculate the information about drug/event combinations within the database such that for all drug/event combination you know:

* N11 is the count for the Product/Event combination
* N12 is the count for the Product and non-Events
* N21 is the count for the Event and Control Products
* N22 is the count for the control event/product combinations

In other words, this table for each drug/event combination

|Drug|Adverse Event|All other Adverse Events|Totals|
|---|---|---|---|
|Drug X|N11|N12|N1.|
|All other Drugs|N21|N22|N2.|
|Totals|N.1|N.2|N..|

Sidebar or Drug and Event variables:
> For the purpose of this writeup I am using the terms *Drug* and *Event* as those are the most common terms for this type of work.  For the calculations you can just as easily replace *Drug* with your entity of interest such as a medical device or a procedure.  Also, *Event* could be any categorical information you are analyzing with *Drug*.  For instance, *Event* could be the combination of `Product + LOT`.

## Quick Start - How it Works
Run everything from your code as a call to `%disproportionality`. Alternatively, if you just want EBGM, you could run `%EBGM` alone rather than through %disproportionality.

You will need your data in the form of 2x2 tables for each drug/event combination.
These 2x2 tables can be calculated by first running `%create2x2` or `%create2x2fromcases`
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

  where each row is a case/drug/event combination and the *Nij* are based on HERE MORE

## Details
### Cases versus Events
The distinction between the %create2x2 and %create2x2fromcases macros is very important.
MORE DOCUMENTATION HERE TO EXPLAIN BIAS CAUSED BY INCLUDING ALL DRUG/EVENT COMBOS FROM A SINGLE CASE INDEPENDENTLY

# Example
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

## /Macros
* %create2x2 - uses input data where each row represents a drug/event combination
  * converts Drug/Event/N11 into Drug/Event/N11/N12/N22/N21
* %disproportionality
  * converts input data from %create2x2 by adding columns for disproportionality metrics
  * optional parameter EBGM=Y is required to request EBGM metrics (by default EBGM=N) - This option will make run time longer
* %ebgm
  * Macro that uses Proc MCMC to estimate parameters and then calculates EBGM metrics
  * This macro can be run alone or requested through %disproportionality

## Call Tree
* %create2x2
* %disproportionality
  * %ebgm (can also be used standalone)

## Sample Data
This repository comes with sample data for running the code in the [`/example input data`](./example input data/):
* `drug_event_example.sas7bdat` is a coded dataset created from a real adverse event database with 385,734 drug/event combinations

  |DrugName|EventName|Nij|
  |---|---|---|

    * `DrugName` is a coded value for a drug of the form `DrugX` where `X` is a series of 1 or more captital letters
    * `EventName` is a coded value for a adverse event of the form `EventX` where `X` is a series of 1 or more capital letters
    * `Nij` is the count of occurences for the combination of `DrugName` and `EventName` - this is the `N11` value

* `sample_case_rows.sas7bdat` is a 1 row per case file with 10,000 cases

  |Case_N|DrugName|Events|
  |---|---|---|

    * `Case_N` is an indentifier for a unique adverse event case
    * `DrugName` is a coded value for a drug of the form `DrugX` where `X` is a series of 1 or more capital letters
    * `Events` is a string of 1 or more space delimittted coded values for adverse events of the form `EventX` where `X` is a series of 1 or more capital letters

* `sample_cases.sas7bdat` is long version of `sample_case_rows.sas7bdat` where each `Event` string has been parsed into a single row for each `EventName` for a total of 31,291 drug/event occurences (reports).

  |Case_N|DrugName|EventName|
  |---|---|---|

    * `Case_N` is an indentifier for a unique adverse event case
    * `DrugName` is a coded value for a drug of the form `DrugX` where `X` is a series of 1 or more captital letters
    * `EventName` is a coded value for a adverse event of the form `EventX` where `X` is a series of 1 or more capital letters

* `textminedcases_train.sas7bdat` - MORE TO COME
* `textminedcases_transaction.sas7bdat` - MORE TO COME

### Simulating Sample Data
For more information about how the *Sample Data* was created and how to create more samples visit [`/example input data/simulating cases`](./example input data/simulating cases/).

## Text Mining for groups of events
See notes in "Text Mining Event Combinations Example.sas"


## Data Structure
Needs documenting
