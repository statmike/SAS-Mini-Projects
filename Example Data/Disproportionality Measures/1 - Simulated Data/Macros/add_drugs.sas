/* for each distinct (Case_N and EventName) add DrugName (&N_Drugs): &OUTDS with Case_N, DrugName, EventName
		NOTES:
			run %basecase first then
				run %add_events to create the &inds
			requires different names for inds and outds
			you can call the macro iteratively to add more drugs
				%basecase(core,&NCases.,1);
					%add_events(core,EX1,&NCases.,1);
					%add_drugs(EX1,EX1a,&NCases.,1);
					%add_drugs(EX1a,EX1b,&NCases.,1);
					%add_drugs(EX1b,EX1c,&NCases.,-1);
*/
		%macro add_drugs(inds,outds,N_DRUGS);

			proc sql noprint;
				create table key as select distinct Case_N, EventName from &inds.;
				select count(*) into :key from key;
			quit;
			data key; set key; key=_n_; run;

			%do i = 1 %to &key.;
					/* store in macro variables: case_n, DrugName, N_Events */
					proc sql noprint;
						select distinct Case_N, EventName
							into :Case_N, :EventName
							from key
							where key=&i.
						;
					quit;

					/* store ED_PCT, Events, COUNT macro variable from Drug_Event where DrugName is the drug on current Case_N*/
					proc sql noprint;
						select ED_Percent into :ED_PCT separated by ' ' from drug_event where EventName="&EventName.";
						select "'"||strip(DrugName)||"'" into :DRUGS separated by ' ' from drug_event where EventName="&EventName.";
						select count(*) into :COUNT from drug_event where EventName="&EventName.";
					quit;

					data caseevents;
						array drugs [&COUNT.] $ _TEMPORARY_ (&DRUGS.);
						array p [&COUNT.]  _TEMPORARY_ (&ED_PCT.);
						call streaminit(-1);
						key=&i.;
						if &N_DRUGS.<0 then N_DRUGS=rand("Table",.3,.3,.2,.10,.05,.03,.02);
						else N_DRUGS=&N_DRUGS.;
						do DRUG_N = 1 to N_DRUGS;
							lookup=rand("Table", of p[*]);
								if lookup>&COUNT. then lookup=int(&COUNT.*rand("Uniform",0,1)+1);
							DrugName=drugs[lookup];
							output;
						end;
						keep key DrugName;
					run;

					proc sql noprint undo_policy=NONE;
						create table caseevents2 as
							select a.Case_N, b.DrugName, a.EventName from
									(select Case_N, EventName, key from key where key=&i.) a
									left outer join
									(select distinct key, DrugName from caseevents where key=&i.) b
									on a.key=b.key
						;
					quit;

					proc append base=add_drugs data=caseevents2; run;

			%end;

			proc sql;
				create table add_drugs_final as
					select * from &inds.
						union
						select * from add_drugs
					order by Case_N, DrugName, EventName
				;
				create table &outds. as select distinct Case_N, DrugName, EventName from add_drugs_final where DrugName;
				drop table caseevents, caseevents2, add_drugs, add_drugs_final;
				drop table key;
			quit;

		%mend add_drugs;
