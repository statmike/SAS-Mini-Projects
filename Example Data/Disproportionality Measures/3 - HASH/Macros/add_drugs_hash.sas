%macro add_drugs(inds,outds,N_DRUGS);

	proc sort data=&inds. out=&outds.;
		by Case_N EventName;
	run;

	data &outds.;
		set &outds.;
		by Case_N EventName;
		length DrugName DrugNameMatch $ 13; /* maybe not needed when implemented with FCMP function */

		/* hash table setup - change name of DrugName on hash to avoid confusion in logic below */
			if _n_=1 then do;
				declare hash sim(dataset: "sim_in.Drug_event_example (rename=(DrugName=DrugNameMatch))", multidata: "Y");
				rc = sim.defineKey('EventName');
				rc = sim.defineData('DrugNameMatch','Nij');
				rc = sim.defineDone();
				call missing(DrugNameMatch,Nij);
			end;

		/* define arrays to hold matched values from hash table */
			array A_DRUGS[2999] $ _TEMPORARY_;
			array A_NIJ[2999] _TEMPORARY_;
			array p[2999] _TEMPORARY_;

		/* store the matched values from the hash table in arrays, compute the P array (percentage of time a drug happens with a event) */
			i=0;
			do while (sim.do_over() = 0);
				i+1;
				A_DRUGS[i] = DrugNameMatch;
				A_NIJ[i] = Nij;
			end;
			do j=1 to i;
				p[j]=A_NIJ[j]/sum(of A_NIJ[*]);
			end;

		/* Setup Arrays to hold the DrigName list from input data, simulated events, and ready for output data */
			array IN_DRUGS[200] $ _TEMPORARY_; /* Holds DrugName values already on Case_N */
			array SIM_DRUGS[20] $ _TEMPORARY_; /* Holds simulated sample DrugName values */
			array OUT_DRUGS[200] $ _TEMPORARY_; /* Holds simulated sample DrugName values to output (not duplicates of existing ones for Case_N) */
			array I_DRUGS[3] _TEMPORARY_; /* 1 for IN_DRUGS, 2 for SIM_DRUGS, 3 for OUT_DRUGS */

		/* check to see if input data has DrugName values */
			dsid=open("&inds.");
			vare=varnum(dsid,'DrugName');
			dsid=close(dsid);

		/* if input data has DrugName values then store them in IN_DRUGS and output them to keep them */
			if vare>0 then do;
				if first.Case_N then do;
					I_DRUGS[1]+1;
					IN_DRUGS[1]=DrugName;
				end;
					else do;
						I_DRUGS[1]+1;
						IN_DRUGS[I_DRUGS[1]]=DrugName;
					end;
				output;
			end;

		/* if last row for a EventName (within a Case_N) then save simulated/sampled DrugName values */
			if last.EventName then do; /* Create a list of simulated sample DrugName values for the EventName */
				/* Random sample of Drugs to Add to the Cases */
					if &N_DRUGS.<0 then N_DRUGS=rand("Table",.3,.3,.2,.10,.05,.03,.02);
						else N_DRUGS=&N_DRUGS.;
					do DRUG_N = 1 to N_DRUGS;
						lookup=rand("Table", of p[*]);
							if lookup>i then lookup=int(i*rand("Uniform",0,1)+1);
						I_DRUGS[2]+1;
						SIM_DRUGS[I_DRUGS[2]]=A_DRUGS[lookup];
					end;
			end;

		/* on last row for a Case_N check the uniqueness of the simulated/sampled DrugName values against the input DrugName values within Case_N and against all the ones simulated/sampled across the EventName values within Case_N */
			if last.Case_N then do; /* Make a unique list of DrugName values from incoming Case_N and simulated sample, then output to rows */
				do I2 = 1 to I_DRUGS[2]; /* loop over SIM_DRUGS */
					match=0;
					if I_DRUGS[1]>0 then do I1 = 1 to I_DRUGS[1]; /* loop over IN_DRUGS - if any */
						if IN_DRUGS[I1]=SIM_DRUGS[I2] then match=1;
					end;
					if I_DRUGS[3]>0 then do I3 = 1 to I_DRUGS[3]; /* loop over OUT_DRUGS - if any so far */
						if OUT_DRUGS[I3]=SIM_DRUGS[I2] then match=1;
					end;
					if match=0 then do; /* If no matches in IN_DRUGS or OUT_DRUGS then add to end of OUT_DRUGS */
						I_DRUGS[3]+1;
						OUT_DRUGS[I_DRUGS[3]]=SIM_DRUGS[I2];
					end;
				end;
				do I3 = 1 to I_DRUGS[3];
					DrugName=OUT_DRUGS[I3];
					output;
				end;
			end;

		/* temporary arrays are retained so reset to missing before proceeding */
			do j=1 to i;
				p[j]=.;
				A_DRUGS[j]='';
				A_NIJ[j]=.;
			end;
			I_DRUGS[1]=0;
			I_DRUGS[2]=0;
			I_DRUGS[3]=0;

		keep Case_N DrugName EventName;
	run;

%mend add_drugs;
