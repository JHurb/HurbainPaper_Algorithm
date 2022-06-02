# Description
This repository contains the Matlab scripts allowing to generate the figures of the paper "Quantitative modeling of pentose phosphate pathway response to oxidative stress reveals a cooperative regulatory strategy" by Hurbain et al. (2022).

The repository includes four folders:
- `13C_MFA` contains code scripts to generate results of Figures 2 and S2
- `Parameter_sampling` contains code scripts used for parameter exploration (genetic algorithm) and estimation (MCMC) of the kinetic model to generate Figures 3 and S3.
- `Model_analysis` contains code scripts to generate results of Figures 4-7 and S4-S7.
- `Data` contains the core parameter set obtained by parameter sampling and analyzed in Figures 4-7.
- `Model_example` contains SBML and Copasi file of the model using a parameter set from 'Data'.
# Content
## 13C_MFA
- `simu13C_MCMC.m` performs MCMC with the SSA-13CMFA algorithm (https://arxiv.org/pdf/2201.00663.pdf)
- `simu13C_score.m` returns score function associated to a flux vector. 
- `simu13C_meta.m` initiates a 3d matrix "meta" with all metabolite simulated (number of molecules x maximum number of carbon x number of metabolites). 
- `simu13C_react.m` applies reaction on the matrix meta. 
- `simu13C_mijcalc.m` computes the mass isotopomer distribution from the matrix meta
- `mcmc_xxx_reorder.dat` initial guess for the flux vector, (xxx = basal or stress)
- `simu13C_MijFromFluxes.m` computes the mass isotopomer distribution from flux set in `mcmc_xxx_reorder.dat` and save in file `MIJdistri_XXX_full.dat`
- `simu13C_plotmij.m` uses `MIJdistri_XXX_full.dat` as input to produce a plot of the mass isotopomer distribution

*Procedure to generate the data for Figures 2 and S2*
1) Initiate files `mcmc_xxx_reorder.dat` containing the initial guess for the flux vector.
2) Run `simu13C_MCMC` (manip,iniguess) where manip is set to 1 or 2 for basal or stress simulation and iniguess is the number line of initial flux condition.
3) Return `Result_MCMC_ ... .dat`  that is the list of accepted flux vectors accepted during MCMC.
4) Run `simu13C_MijFromFluxes.m` to produce the mass isotopomer distribution file `MIJdistri_XXX_full.dat` from the list of accepted flux vectors (uses `mcmc_xxx_reorder.dat` by default, can be changed in dataname0)
5) Run `simu13C_plotmij.m` to plot the mass isotopomer distribution fit in Figures S2-C&D.

## Parameter_sampling
- `simuDetox_AlgoGene.m` implements the genetic algorithm
- `simuDetox_MCMC.m` implements the MCMC sampling algorithm
- `simuDetox_reso.m` describes the differential equation system of the metabolic network
- `simuDetox_Iinput.m` defines the temporal dynamics of H2O2 and Glucose inputs
- `simuDetox_score.m` returns the RMSE score (Eq. 9)

*Procedure to generate the data for Figure 3*
1) Initiate a parameter vector param0 as initial guess. It is initiated from each parameters values after "If start from a given param vector". To start from a parameter vector from a `file.dat`, comment param0, uncomment lines 20-27 and modify dataname as the name of the file without ".dat"
2) Run `simuDetox_AlgoGene()` that returns the optimized model solution in `minscore_ngen_Result_time.dat` where `minscore` is the minimum score, `ngen` is the number of generation and `time` is the date of run. 
3) From the file `` generated with genetic algorithm, change its name in `dataname0`
4) Run `simuDetox_MCMC()` 
5) Returns a file `minscore_mean_std_knb_MCMC_time.dat` that is the list of accepted kinetic parameter set  where minscore is the minimum accepted score, mean and std are mean and standard deviation of all accepted scores, knb is the number of accepted score and time is the date of the run. 

## Model_analysis
- `simuDetox_DoseRespKO.m` computes metabolic outputs as function of H2O2 stress level
- `simuDetox_AnaParamFull.m` computes metabolic outputs upon various parametric perturbations
 
*Procedure to generate the data for Figures 4-5 and S4-S5*
1) Initiate a file `dataname1` for the parameter set to test and `dataname2` for the corresponding set of initial conditions
2) Run `simuDetox_DoseRespKO(kovect,kosecond,savedyn)` where `kovect` and `kosecond` are the first and second modified parameters. These two arguments take values from 1 to 7 : 1 is no modification, 2 is for Kig6pd, 3 for Kipgi, 4 for Kigapd, 5 for kg6pd, 6 for k6pgd and 7 for ktkt1.`savedyn` argument is set to 1 to save the temporal dynamic (Figure 4) otherwise 0.
3) Returns files `XXX_Xm_XXX.dat` with outputs at `X` min after stress and another file `XXX.dat` for the temporal dynamics if asked.

*Procedure to generate the data for Figures 6-7 and S6-S7*
1) Initiate a file `dataname1` for the parameter set to test and `dataname2` for the corresponding set of initial conditions
2) Run `simuDetox_AnaParamFull(KOpar)` where KOpar is the enzyme parameter to analyse. It takes values from 1 to 3 where 1 is for kg6pd, 2 for k6pgd and 3 for ktkt11.
3) Returns files `dataname1_APF_Xm_Y_Z.dat` with results at `X` min after stress, by modifying the parameter `Y`, where `Z` is the number of the tested value.

## Data
- `mcmcpar_100k.zip` is the compressed file of `mcmcpar_100k.dat` which contains the core parameter sets obtained by parameter sampling and analyzed in Figures 4-7.
- `mcmcfpb_100k.zip` is the compressed file of `mcmcfpb_100k.dat` which contains the metabolite concentration at steady state in basal condition corresponding to the parameter sets in `mcmcpar_100k.dat`.
- `mcmcfbs_100k.zip` is the compressed file of `mcmcfpb_100k.dat` which contains the metabolite concentration at steady state in stress condition corresponding to the parameter sets in `mcmcpar_100k.dat`.

## Model_example
- `22-03-17_MODEL.xml` is SBML file of the model using a parameter set from `mcmcpar_100k.dat`
- `22-03-17_MODEL.cps` is Copasi file of the model using a parameter set from `mcmcpar_100k.dat`
