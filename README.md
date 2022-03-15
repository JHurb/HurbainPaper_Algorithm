# HurbainPaper_Algorithm
Algorithm of the Paper "Quantitative modeling of pentose phosphate pathway response to oxidative stress reveals a cooperative regulatory strategy". 
Authors : Hurbain J. , Thommen Q. , Pfeuty B.


%%%%%%%%%%%%%%%%%%

13C_Analysis :
simu13C_MCMC.m : Main algorithm to compute MCMC with SSA-13C MFA (https://arxiv.org/pdf/2201.00663.pdf).
simu13C_score.m : Return score function depending of a flux vector.
simu13C_meta.m : Initiate a 3d matrix "meta" with all metabolite simulated (number of molecules x maximum number of carbon x number of metabolites).
simu13C_react.m : Apply reaction on the matrix meta.
simu13C_mijcalc.m : Compute the mass isotopomer distribution from the matrix meta.

- To compute MCMC on the metabolic network, use simu13C_MCMC.m
- Initiate a file "mcmc_basal_reorder.dat"/"mcmc_stress_reorder.dat" including a fluxes vector as initiale guess.
- Enter the function simu13C_MCMC(manip,iniguess) where manip is 1 or 2 for basal or stress simulation and iniguess is the ligne number of the fluxes initiales guess.
- Return param_MCMC which is the matrix of set of fluxes accepted during MCMC. This matrix is written in a file "Result_MCMC_ ... .dat"


%%%%%%%%%%%%%%%%%%

Genetic_Algo :
simuDetox_AlgoGene.m : Main algorithm to compute Genetic algorithm.
simuDetox_reso.m : Function including the system of equations.
simuDetox_Iinput.m : Function that design a temporal dynamic of H2O2 stress and Glucose input. Used for a step function.
simuDetox_score.m : Return a score depending of a parameter vector.

- To compute Genetic Algorithm, use simuDetox_AlgoGene.m
- Initiate a first parameter vector as initiale guess called param0. It is initiated from each parameters values after "If start from a given param vector". To start from a parameter vector from a saved file .dat, comment param0, uncomment after "If start from a previous vector" (lignes 20-27) and modify dataname as the name of the file without ".dat".
- Enter the function simuDetox_AlgoGene() which return Result which is the matrix of the family after selections. This matrix is written in a file named as " minscore_ngen_Result_time.dat' where minscore is the minimum score, ngen is the number of generation and time is the date of run.


%%%%%%%%%%%%%%%%%%

MCMC :
simuDetox_MCMC.m : Main algorithm to compute MCMC with a SSA-13C MFA.
simuDetox_reso.m : Function including the system of equations.
simuDetox_Iinput.m : Function that design a temporal dynamic of H2O2 stress and Glucose input. Used for a step function.
simuDetox_score.m : Return a score depending of a parameter vector.

- To compute MCMC, use simuDetox_MCMC.m
- From the file generated with genetic algorithm, change the parameters file name in dataname0. Run the function with simuDetox_MCMC()
- It returns param_MCMC which is a matrix of the set of parameter which lignes are accepted sets and columns are each parameters. This matrix is written in a file named as "minscore_mean_std_knb_MCMC_time.dat" where minscore is the minimum accepted score, mean and std are mean and standard deviation of all accepted scores, knb is the number of accepted score and time is the date of the run.


%%%%%%%%%%%%%%%%%%

Regulation-Enzyme_Analysis :
simuDetox_DoseRespKO.m : Compute all Dose Responses, Regulation analysis.
simuDetox_AnaParamFull.m : Compute all Enzymes knockdown/activation with a dose response.

Dose response :
- Initiate a file dataname1 which is the set of parameters to test and dataname2 which is a file of initial condition for each set of parameters.
- Run the function simuDetox_DoseRespKO(kovect,kosecond,savedyn) where kovect and kosecond are the first and second modified parameter. These two arguments take values from 1 to 7 : 1 is no modification, 2 is for Kig6pd, 3 for Kipgi, 4 for Kigapd, 5 for kg6pd, 6 for k6pgd and 7 for ktkt11. savedyn argument is 1 to save the temporal dynamic otherwise 0.
- It returns files with results at 5min or 30min after stress and another file for the temporal dynamic if asked.

Complete Enzyme parameter analysis :
- Initiate a file dataname1 which is the set of parameters to test and dataname2 which is a file of initial condition for each set of parameters.
- Run the function simuDetox_AnaParamFull(KOpar) where KOpar is the enzyme parameter to analyse. It takes values from 1 to 3 where 1 is for kg6pd, 2 for k6pgd and 3 for ktkt11.
- It returns files with results at 5min or 30min after stress. For instance, modifying k6pgd while create "dataname1_APF_5m_6pgd_x.dat" where x is the number of the value tested during the algorithm.
