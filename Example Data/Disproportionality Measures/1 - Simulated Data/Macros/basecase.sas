/* create base case with first drug(s): &OUTDS with Case_N, DrugName */
		%macro basecase(outds,reps,n_drugs,SEED=12345);

			proc sql noprint;
				select D_Percent into :D_PCT separated by ' ' from drugs;
				select "'"||strip(DrugName)||"'" into :DRUGS separated by ' ' from drugs;
				select count(*) into :COUNT from drugs;
			quit;
			data basecase;
				array drugs [&COUNT.] $ _TEMPORARY_ (&DRUGS.);
				array p [&COUNT.] _TEMPORARY_ (&D_PCT.);
				call streaminit(&seed.);
				do Case_N = 1 to &reps.;
					if &n_drugs.<0 then n_drugs=rand("Table",.3,.3,.2,.10,.05,.03,.02);
						else n_drugs=&n_drugs.;
					do nd = 1 to n_drugs;
						lookup = rand("Table", of p[*]);
							if lookup>&COUNT. then lookup=int(&COUNT.*rand("Uniform",0,1)+1);
						DrugName=drugs[lookup];
						output;
					end;
				end;
				keep Case_N DrugName;
				drop nd n_drugs;
			run;
			proc sql;
				create table &outds. as select distinct Case_n, DrugName from basecase;
				drop table basecase;
			quit;

		%mend basecase;
