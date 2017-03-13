#Links for PROC MCMC Over Versions
*	9.2
  *	SAS/STAT http://support.sas.com/documentation/onlinedoc/stat/index.html#statprev
  *	MCMC is NEW: http://support.sas.com/documentation/cdl/en/statug/63033/HTML/default/viewer.htm#statug_whatsnew_sect024.htm
*	9.22
  *	SAS/STAT: http://support.sas.com/documentation/onlinedoc/stat/index.html#statprev
  *	MCMC What’s New: http://support.sas.com/documentation/cdl/en/statug/63347/HTML/default/viewer.htm#statug_whatsnew_sect019.htm
    *	The PREDDIST statement creates random samples from the posterior predictive distribution of the response variable and saves the samples to a SAS data set. The posterior predictive distribution is the distribution of unobserved observations (prediction) conditional on the observed data.
*	9.3
  *	SAS/STAT: http://support.sas.com/documentation/onlinedoc/stat/index.html#stat93
  *	MCMC What’s New: http://support.sas.com/documentation/cdl/en/statug/63962/HTML/default/viewer.htm#statug_whatsnew_sect019.htm
    *	The new RANDOM statement simplifies the construction of hierarchical random-effects models and significantly reduces simulation time while improving convergence, especially in models with a large number of subjects or clusters. This statement defines random effects that can enter the model in a linear or nonlinear fashion and supports univariate and multivariate prior distributions.
    *	In addition to the default Metropolis-based algorithms, PROC MCMC now takes advantages of certain forms of conjugacy in the model in order to sample directly from the target conditional distributions. In many situations, the conjugate sampler increases sampling efficiency and provides a substantial reduction in computing time.
    *	The MCMC procedure now supports multivariate distributions including the Dirichlet, inverse Wishart, multivariate normal, and multinomial distributions.
*	9.4 – Analytical products like SAS/STAT took on a new number system
  *	12.1/12.3
    *	SAS/STAT: http://support.sas.com/documentation/onlinedoc/stat/index.html#stat121
    *	MCMC What’s New: http://support.sas.com/documentation/cdl/en/statug/66103/HTML/default/viewer.htm#statug_whatsnew_sect022.htm
      *	The MCMC procedure provides the following new capabilities:
        *	The MODEL statement augments missing values in the response variable by default. PROC MCMC treats missing values as unknown parameters and incorporates the sampling of the missing data as part of the Markov chain.
        *	The RANDOM statement supports multilevel hierarchical modeling to an arbitrary depth; a random effect can appear in the distributional hierarchy of other random effects.
        *	More distributions, such as multivariate normal distribution with autoregressive structure, Poisson distribution, and general distribution (for the construction of nonstandard distributions), are made available for the RANDOM statement.
        *	Direct sampling and more conjugate sampling algorithms are available for all parameters in the model (including model parameters, random-effects parameters, and missing data variables) when appropriate.
        *	A slice sampler is an alternative sampling algorithm for both the model parameters and random-effects parameters.
  *	13.1
    *	SAS/STAT: http://support.sas.com/documentation/onlinedoc/stat/index.html#stat131
    *	MCMC What’s New: http://support.sas.com/documentation/cdl/en/statug/66859/HTML/default/viewer.htm#statug_whatsnew_sect019.htm
      *	The MCMC procedure is now multithreaded and can take advantage of multiple processors. The NTHREADS= option in the PROC MCMC statement specifies the number of threads for simulation. When sampling model parameters, PROC MCMC allocates data into different threads and calculates the objective function by accumulating values from each one. When sampling random-effects parameters and missing data variables, PROC MCMC generates a subset of these parameters on individual threads simultaneously at each iteration. Most sampling algorithms are threaded. By default, NTHREADS=1.
      *	PROC MCMC now permits parameters (or functions of parameters) in all truncated distributions (LOWER= and UPPER= options) in both the PRIOR and the MODEL statements.
  *	13.2
    *	SAS/STAT: http://support.sas.com/documentation/onlinedoc/stat/index.html#stat132
    *	MCMC What’s New: http://support.sas.com/documentation/cdl/en/statug/67523/HTML/default/viewer.htm#statug_whatsnew_sect018.htm
      *	The PRIOR, RANDOM, and MODEL statements now support a categorical distribution.
      *	The RANDOM statement now supports a uniform prior distribution.
      *	All conjugate sampling algorithms are now multithreaded.
  *	14.1
      *	SAS/STAT: http://support.sas.com/documentation/onlinedoc/stat/index.html#stat141
      *	MCMC What’s New: http://support.sas.com/documentation/cdl/en/statug/68162/HTML/default/viewer.htm#statug_whatsnew_sect026.htm
        *	Two default sampling algorithms for continuous parameters have been added to the procedure: Hamiltonian Monte Carlo (HMC) and No-U-Turn Sampler (NUTS). You can select them as replacements for the normal- or t-distribution-based random-walk Metropolis algorithm to draw posterior samples.
        *	PROC MCMC supports lagging and leading variables. This enables the procedure to fit dynamic linear models, state space models, autoregressive models, or other models that have a conditionally dependent structure on either the random-effects parameters or the response variable.
        *	PROC MCMC adds an ordinary differential equation (ODE) solver and a general integration function, which enable the procedure to fit models that contain differential equations (for example, PK models) or models that require integration (for example, marginal likelihood models).
        *	The PREDDIST statement makes predictions from marginal random-effects models. For example, you can make predictions for new observations that do not have group membership information in a random-effects model.
  *	14.2
    *	SAS/STAT: http://support.sas.com/documentation/onlinedoc/stat/index.html#stat142
    *	MCMC What’s New: http://go.documentation.sas.com/?docsetId=statug&docsetVersion=14.2&docsetTarget=statug_whatsnew_sect013.htm&locale=en
      *	The new NORMALCAR option in the RANDOM statement specifies a spatial conditional autoregressive (CAR) prior that can be used to model spatial correlations among sites and neighbors.

#Very Important Sections of the Documentation – These are kept up to date for the most recent version
