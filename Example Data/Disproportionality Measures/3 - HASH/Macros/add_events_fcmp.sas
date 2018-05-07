%macro setup_macvars;

	%let DrugName=%sysfunc(dequote(&DrugName.));
	proc sql NOPRINT;
		create table _tmp_ as
		select DE_Percent as DE_PCT,
				 strip(EventName) as EVENTS length=8
		from (select EventName, Nij/sum(Nij) as DE_PERCENT
				from sim_in.drug_event_example
				where DrugName="&DrugName.")
		;
	quit;

%mend setup_macvars;


proc fcmp outlib=work.functions.add FLOW LISTALL;

	function addevent(DrugName $);* $ 13;
		call streaminit(-1);
		rc=run_macro('setup_macvars',DrugName);
		array p[1] / NOSYMBOLS;
			rc=read_array('work._tmp_',p,'DE_PCT');
		lookup=rand("Table", of p[*]); /* of operator not supported - unravel to range of vars TESSA7612154407 */
		put lookup;
			if lookup>hbound(p) then lookup=int(hbound(p)*rand("Uniform",0,1)+1);
		put lookup;
		return(lookup);
	endsub;

run;
options cmplib=(work.functions);

%macro add_events(inds,outds,N_EVENTS);

	data &outds.;
		set &inds.;
		call streaminit(-1);
		if EventName then output;
		if &N_EVENTS.<0 then N_EVENTS=rand("Table",.3,.2,.15,.10,.05,.05,.05,.05,.01,.01,.01,.01,.01);
			else N_EVENTS=&N_EVENTS.;
		do EVENT_N = 1 to N_EVENTS;
			EventN=addevent(DrugName);
			output;
		end;
		drop Event_N N_EVENTS;
	run;

%mend add_events;

/* holding ground

		*array aevents[1] / NOSYMBOLS;
			*rc=read_array('work._tmp_',aevents,'EVENTS');
		*array p[1] / NOSYMBOLS;
			*rc=read_array('work._tmp_',p,'DE_PCT');
		*call streaminit(-1);
		*lookup=rand("Table", of p[*]);
		*put lookup;
			*if lookup>hbound(aevents) then lookup=int(hbound(aevents)*rand("Uniform",0,1)+1);
		*EventName=aevents[lookup];
		*return(EventName);
		*return(lookup);
*/
