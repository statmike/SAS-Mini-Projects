%macro add_events(inds,outds,N_EVENTS);

	proc sort data=&inds. out=&outds.; 
		by Case_N DrugName;
	run;

	data &outds.;
		set &outds.;
		by Case_N DrugName;
		length EventName EventNameMatch $ 13; /* maybe not needed when implemented with FCMP function */

		/* hash table setup - change name of EventName on hash to avoid confusion in logic below */
			if _n_=1 then do;
				declare hash sim(dataset: "sim_in.Drug_event_example (rename=(EventName=EventNameMatch))", multidata: "Y");
				rc = sim.defineKey('DrugName');
				rc = sim.defineData('EventNameMatch','Nij');
				rc = sim.defineDone();
				call missing(EventNameMatch,Nij);
			end;

		/* define arrays to hold matched values from hash table */
			array A_EVENTS[2999] $ _TEMPORARY_;
			array A_NIJ[2999] _TEMPORARY_;
			array p[2999] _TEMPORARY_;

		/* store the matched values from the hash table in arrays, compute the P array (percentage of time an event happens with a drug) */
			i=0;
			do while (sim.do_over() = 0);
				i+1;
				A_EVENTS[i] = EventNameMatch;
				A_NIJ[i] = Nij;
			end;
			do j=1 to i;
				p[j]=A_NIJ[j]/sum(of A_NIJ[*]);
			end;

		/* Setup Arrays to hold the EventName list from input data, simulated events, and ready for output data */
			array IN_EVENTS[200] $ _TEMPORARY_; /* Holds EventName values already on Case_N */
			array SIM_EVENTS[20] $ _TEMPORARY_; /* Holds simulated sample EventName values */
			array OUT_EVENTS[200] $ _TEMPORARY_; /* Holds simulated sample EventName values to output (not duplicates of existing ones for Case_N) */
			array I_EVENTS[3] _TEMPORARY_; /* 1 for IN_EVENTS, 2 for SIM_EVENTS, 3 for OUT_EVENTS */

		/* check to see if input data has EventName values */
			dsid=open("&inds.");
			vare=varnum(dsid,'EventName');
			dsid=close(dsid);

		/* if input data has EventName values then store them in IN_EVENTS and output them to keep them */
			if vare>0 then do;
				if first.Case_N then do;
					I_EVENTS[1]+1;
					IN_EVENTS[1]=EventName;
				end;
					else do;
						I_EVENTS[1]+1;
						IN_EVENTS[I_EVENTS[1]]=EventName;
					end;
				output;
			end;

		/* if last row for a DrugName (within a Case_N) then save simulated/sampled EventName values */
			if last.DrugName then do; /* Create a list of simulated sample EventName values for the DrugName */
				/* Random sample of Events to Add to the Cases */
					if &N_EVENTS.<0 then N_EVENTS=rand("Table",.3,.2,.15,.10,.05,.05,.05,.05,.01,.01,.01,.01,.01);
						else N_EVENTS=&N_EVENTS.;
					do EVENT_N = 1 to N_EVENTS;
						lookup=rand("Table", of p[*]);
							if lookup>i then lookup=int(i*rand("Uniform",0,1)+1);
						I_EVENTS[2]+1;
						SIM_EVENTS[I_EVENTS[2]]=A_EVENTS[lookup];
					end;
			end;

		/* on last row for a Case_N check the uniqueness of the simulated/sampled EventName values against the input EventName values within Case_N and against all the ones simulated/sampled across the DrugName values within Case_N */
			if last.Case_N then do; /* Make a unique list of EventName values from incoming Case_N and simulated sample, then output to rows */
				do I2 = 1 to I_EVENTS[2]; /* loop over SIM_EVENTS */
					match=0;
					if I_EVENTS[1]>0 then do I1 = 1 to I_EVENTS[1]; /* loop over IN_EVENTS - if any */
						if IN_EVENTS[I1]=SIM_EVENTS[I2] then match=1;
					end;
					if I_EVENTS[3]>0 then do I3 = 1 to I_EVENTS[3]; /* loop over OUT_EVENTS - if any so far */
						if OUT_EVENTS[I3]=SIM_EVENTS[I2] then match=1;
					end;
					if match=0 then do; /* If no matches in IN_EVENTS or OUT_EVENTS then add to end of OUT_EVENTS */
						I_EVENTS[3]+1;
						OUT_EVENTS[I_EVENTS[3]]=SIM_EVENTS[I2];
					end;
				end;
				do I3 = 1 to I_EVENTS[3];
					EventName=OUT_EVENTS[I3];
					output;
				end;
			end;

		/* temporary arrays are retained so reset to missing before proceeding */
			do j=1 to i;
				p[j]=.;
				A_EVENTS[j]='';
				A_NIJ[j]=.;
			end;
			I_EVENTS[1]=0;
			I_EVENTS[2]=0;
			I_EVENTS[3]=0;

		keep Case_N DrugName EventName;
	run;

%mend add_events;
