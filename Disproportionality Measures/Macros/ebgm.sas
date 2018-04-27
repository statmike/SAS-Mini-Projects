

%macro EBGM(ds,outds,prod_level,event_level);
	/*  
		Based On the methods described in:
			Bayesian Data Mining in Large Frequency Tables, with an Application to the FDA Spontaneous Reporting System
			William DuMouchel
			The American Statistician, Vol. 53, No. 3 (Aug., 1999), pp. 177-190
			
		Multi-Item Gamma Poisson Shrinker (MGPS) is used to find intersting large cell counts in a large table of drugs and events
		The empirical Bayes geometric mean (EBGM)  is an empirical Bayes estimate of RR obtained from model
			RR = N11*(N11+N12+N21+N22) / (N11*N21)*(N11+N12)
	*/
	proc sort data = &ds.; by &prod_level &event_level; run;
	    data &outds.;
            set &ds.;
            by &prod_level &event_level;

            Prod_Total = sum(of N11, N12);
            Event_Total = sum(of N11, N21);
            Total = sum(of N11, N12, N21, N22);
            
            E11 = Prod_Total*Event_Total/Total;
            EBGM_Unadj = N11/E11;
	    RUN;
	    
	ods output PostSumInt = work.MCMC_PARMS;
	proc mcmc data=&outds. seed=32259 nmc=10000 thin=5 nthread=6 propcov=quanew monitor=(Mix_p alpha1 alpha2 beta1 beta2);
		parms Mix_p 0.3333 alpha1 .2 alpha2 2 beta1 .1 beta2 4;
	
		/**Generic gamma priors*/
		prior alpha1 beta1 ~ gamma(1, iscale=1);
		prior alpha2 beta2 ~ gamma(1, iscale=1);
		prior Mix_p ~ uniform(0,1);
	
		const1=lgamma(alpha1+N11) - lgamma(alpha1) - lgamma(N11+1);
		const2=lgamma(alpha2+N11) - lgamma(alpha2) - lgamma(N11+1);
		LogL1=const1 - N11*log(1+beta1/E11) - alpha1*log(1+E11/beta1);
		LogL2=const2 - N11*log(1+beta2/E11) - alpha2*log(1+E11/beta2);
		llike = log(Mix_p*exp(LogL1) + (1-Mix_p)*exp(LogL2));
		model N11 ~ general(llike); 
	run;
	
	/* score code here */
	data _null_;
		set work.MCMC_PARMS;
		call symput(parameter,mean);
		call symput(trim(parameter)||'_std',StdDev);
	run;
	proc sql; drop table work.MCMC_PARMS; quit;
	
	data &outds.;
		set &outds.;
	        p1 =E11/(E11 + &beta1.); q1=1-p1;
	        p2 =E11/(E11 + &beta2.); q2=1-p2;
			drop p1 p2 q1 q2;
	
	        f1=(p1**N11)*(q1**&alpha1.)*exp(lgamma(&alpha1.+N11)-lgamma(&alpha1.)-lgamma(N11+1));
	        f2=(p2**N11)*(q2**&alpha2.)*exp(lgamma(&alpha2.+N11)-lgamma(&alpha2.)-lgamma(N11+1));
	        f =&Mix_P*f1+(1-&Mix_P)*f2;
	        drop f1 f2 f;
	
	        **Catch exception due to gamma function for large numbers***;
	        mc=1.e-150; 
	        c=(f > mc); 
	        c1=1-c;
	        f =f * c + c1 * mc;
	        drop mc c c1;
	
	        Qn=&Mix_P.*f1/f;
	        E_Lambda=Qn*((&alpha1.+N11)/(&beta1.+E11))+(1-Qn)*((&alpha2.+N11)/(&beta2.+E11));
	        E_LogLambda=Qn*(digamma(&alpha1.+N11)-log(&beta1.+E11))+(1-Qn)*(digamma(&alpha2.+N11)-log(&beta2.+E11));
	        EBlog2=round(E_LogLambda/log(2),.000001);
	        EBGM=(2**EBlog2);
	        EBGM=round(EBGM,.000001);
	        format EBGM  EBlog2 12.6;
			drop Qn E_Lambda E_LogLambda EBlog2;
	
	        ****Compute the 5th and 95th percentiles for Lambda****;
	        ****Use bisection algorithmic method to find the 0.05 quantile of the mixed distribution****;
	
	        alpha1_=N11 + &alpha1.;
	        beta1_ =E11 + &beta1.;
	        alpha2_=N11 + &alpha2.;
	        beta2_ =E11 + &beta2.;
	        drop alpha1_ beta1_ alpha2_ beta2_;

	        EBGM05 = Qn*QUANTILE('GAMMA', 0.05, alpha1_, 1/beta1_) +
	                 (1-Qn)*QUANTILE('GAMMA', 0.05, alpha2_, 1/beta2_);
	        EBGM95 = Qn*QUANTILE('GAMMA', 0.95, alpha1_, 1/beta1_) +
	                 (1-Qn)*QUANTILE('GAMMA', 0.95, alpha2_, 1/beta2_);
           	
	run;	
%mend EBGM;

