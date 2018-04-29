/* for each distinct (Case_N and DrugName) add EventName (&N_EVENTS): &OUTDS with Case_N, DrugName, EventName
		NOTES:
			run %basecase first to create the &inds
			requires different names for &inds and &outds
			you can call the macro iteratively to add more events
				%basecase(core,&NCases.,1);
					%add_events(core,EX1a,&NCases.,1);
					%add_events(EX1a,EX1b,&NCases.,1);
					%add_events(EX1b,EX1c,&NCases.,1);
					%add_events(EX1c,EX1d,&NCases.,-1);
*/
		%macro add_events(inds,outds,N_EVENTS);

			proc sql noprint;
				create table key as select distinct Case_N, DrugName from &inds.;
				select count(*) into :key from key;
			quit;
			data key; set key; key=_n_; run;

			%do i = 1 %to &key.;
					/* store in macro variables: case_n, DrugName, N_Events */
					proc sql noprint;
						select distinct Case_N, DrugName
							into :Case_N, :DrugName
							from key
							where key=&i.
						;
					quit;

					/* store DE_PCT, Events, COUNT macro variable from Drug_Event where DrugName is the drug on current Case_N*/
					proc sql noprint;
						select DE_Percent into :DE_PCT separated by ' ' from drug_event where DrugName="&DrugName.";
						select "'"||strip(EventName)||"'" into :EVENTS separated by ' ' from drug_event where DrugName="&DrugName.";
						select count(*) into :COUNT from drug_event where DrugName="&DrugName.";
					quit;

					data caseevents;
						array events [&COUNT.] $ _TEMPORARY_ (&EVENTS.);
						array p [&COUNT.]  _TEMPORARY_ (&DE_PCT.);
						call streaminit(-1);
						key=&i.;
						if &N_EVENTS.<0 then N_EVENTS=rand("Table",.3,.2,.15,.10,.05,.05,.05,.05,.01,.01,.01,.01,.01);
						else N_EVENTS=&N_EVENTS.;
						do EVENT_N = 1 to N_EVENTS;
							lookup=rand("Table", of p[*]);
								if lookup>&COUNT. then lookup=int(&COUNT.*rand("Uniform",0,1)+1);
							EventName=events[lookup];
							output;
						end;
						keep key EventName;
					run;

					proc sql noprint undo_policy=NONE;
						create table caseevents2 as
							select a.Case_N, a.DrugName, B.EventName from
									(select Case_N, DrugName, key from key where key=&i.) a
									left outer join
									(select distinct key, EventName from caseevents where key=&i.) b
									on a.key=b.key
						;
					quit;

					proc append base=add_events data=caseevents2; run;

			%end;

			proc sql;
				create table add_events_final as
					select * from &inds.
						union
						select * from add_events
					order by Case_N, DrugName, EventName
				;
				create table &outds. as select distinct Case_N, DrugName, EventName from add_events_final where EventName;
				drop table caseevents, caseevents2, add_events, add_events_final;
				drop table key;
			quit;

		%mend add_events;
