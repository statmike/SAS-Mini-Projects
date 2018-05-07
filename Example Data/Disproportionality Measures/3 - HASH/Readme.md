# Synopsis
rewrite Disproportionality code to use Proc FCMP defined functions
Steps:
* replace the creation of the datasets Drug_event, Drugs, Events
  * at the start of each macro (basecase, add_events, add_drugs), replace the SQL code that creates macro variables with full derivation of the data previously expected to be in Drug_Event, Drugs, EVENTS
* convert add_events macro to PROC FCMP functions
