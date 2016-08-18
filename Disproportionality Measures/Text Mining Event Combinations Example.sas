/*
	First - review "run from here.sas" to see disproportionality metrics for traditional drug/event combinations

	The unique idea here is to take the events in a case together and look for special grouping or combinations.
	Within and adverse event case there can be more than one event expressed: think Headache and Nausea.
	Here I code each of the events into a unique word ID: EventABC EventA EventAD
	These sentences of coded events can be treated as documents for text mining.
	I used SAS Text Miner to create up to 25 topics from these documents.
	The topics are derived grouping of events.
	
	Below I prepare the SAS Text Miner output data and send it throught the %Disproportionality macro
	
	The SAS Text Miner output can be found in: 
		C:\PROJECTS\SAS-Mini-Projects\Disproportionality Measures\example input data\
				textminedcases_train.sas7bdat (we will use this file)
				textminedcases_transaction.sas7bdat
				
		The files are the result of analyzing the file:
			C:\PROJECTS\SAS-Mini-Projects\Disproportionality Measures\example input data\sample_case_rows
*/

libname signal 'C:\PROJECTS\SAS-Mini-Projects\Disproportionality Measures\example input data';

/* prepare text miner output for disproportionality calculations */
data grouped_events;
	set signal.textminedcases_train(drop=texttopic_raw:);
	array tt[25] texttopic_1-texttopic_25;
	if sum(of tt(*))>0 then do;
		do i = 1 to 25;
			if tt[i]=1 then do;
				EventName='TextTopic'||put(i,$2.);
				output;
			end;
		end;
	end;
	else do;
		do j = 1 by 1 while(scan(Events,j,' ')^=' ');
			EventName=scan(Events,j,' ');
			output;
		end;
	end;
	keep Case_N DrugName EventName Events;
run;


/* some checks */
	proc sql;
		/* still 10000 cases? */
		select count(*) from (select distinct Case_N from grouped_events);
		/* how many cases without a TextTopic hit ? */
		select 10000-count(*) from (select distinct Case_N from grouped_events where index(EventName,'T')=1);
	quit;
	
%create2x2fromcases(grouped_events,Signal_grouped_events,case_n,DrugName,EventName,shape=LONG);
%disproportionality(Signal_grouped_events,Signal_groups_disproportionality,DrugName,EventName,1.96,EBGM=N);

/* what are these topics? 
parts of this code will reference data outside of the repository and not be able to be reproduced
*/
libname em 'C:\PROJECTS\EMProjects\Adverse Event Grouping\Workspaces\EMWS1';
libname events 'C:\Users\mihend\Desktop\Signal Detection';

/* top five terms (events) per topic */
data topics; set em.texttopic_topics;
	TopicID=_topicid;
	do i = 1 by 1 while(scan(_name,i,',')^=' ');
		EventName=scan(_name,i,',');
		EventName=upcase(EventName);
		substr(EventName,2,4)='vent';
		output;
	end;
	keep TopicID EventName;
run;
proc sql noprint undo_policy=NONE;
	create table topics as 
		select a.TopicID, a.EventName, b.EventName_Source
		from
			(select TopicID, EventName from topics) a
			left outer join
			(select EventName, EventName_Source from events.key_event) b
			on a.EventName=b.EventName
		order by a.TopicID, a.EventName
	;
quit;



