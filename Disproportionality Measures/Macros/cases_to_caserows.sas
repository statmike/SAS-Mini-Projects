%macro cases_to_caserows(ds,outds,case_var,drug_var,event_var);

	/*	changing cases across multiple rows to a single row per case
		This macro reshapes the input dataset (&ds) into an output dataset (&outds)
			The input dataset columns are identifed as
				&case_var = an id for the case - can have more than 1 row
				&drug_var = the drug associated with the case
					this macro currently expect there to be just one Drug on the cases repeated on each row
					A modification to included creating a contcatenate list of drugs follows the same logic as is used for events below
				&event_var = each row has an associated with the case
			The output dataset  will have columns identified as
				&case_var = an id for the case - only 1 row per case
				&drug_var = the value of &drug_var on the last row of &ds for the current value of &case_var
				Events = a concatenated list of the value of &event_var that is space delimited
					(makes a great sentence/document for text mining)
	*/

	data &outds.;
		length Events $300.;
			do until(last.&case_var.);
				set &ds.;
				by &case_var.;
				Events=catx(' ',Events,&event_var.);
			end;
		drop &event_var.;
	run;

%mend cases_to_caserows;