#
#
########## Bayesian Factor Analysis ##########
#
#
# Import the simulated example data from the web, naming it "data1". The data consists of 
# 1000 cases and 8 variables (items). The first four items load on factor 1 with loadings 
# of approximately 0.8, the second four items load on factor 2 with loadings of 
# approximately 0.7.

data1 <- read.table("http://www.unt.edu/rss/class/Jon/R_SC/Module10/MCMCfactanal_data1.txt",
                    header=TRUE, sep=",", na.strings="NA", dec=".", strip.white=TRUE)
summary(data1)
head(data1)

# write.table(data1,"MCMCfactanal_data1.txt")

#######################

## Traditional factor analysis; here assigned to the object "fa.1".

fa.1 <- factanal(~., factors = 2, rotation = "varimax", data = data1)
fa.1

# If desired; display the loadings without suppression (cutoff)
# and only the first 3 digits below zero.

print(fa.1, digits = 3, cutoff = .000001)

#######################

## Bayesian Factor Analysis using Markov Chain Monte Carlo (MCMC) methods. 

# Keep in mind that a Bayesian factor analysis is by its very nature a confirmatory analysis. The 
# Bayesian perspective necessitates the use of a prior and therefore, it can be assumed that the prior 
# is based on an exploratory factor analysis done previously (or the prior is based on previous 
# research involving the establishment or acceptance of the items/scales/measure). 

# Load the MCMCpack library.

library(MCMCpack)

# Take a look at the 'MCMCfactanal' function; pay  particular attention to each argument.

help(MCMCfactanal)

# Run the MCMC factor analysis (assigning it to an object; here "fa.2"). Keep in mind, this can take 
# a few minutes. In the example below, we do not fully specify the model (i.e. constraining which items 
# load on which factors); which will be covered further below.

fa.2 <- MCMCfactanal(~x1+x2+x3+x4+x5+x6+x7+x8, factors = 2, data = data1, burnin = 1000, mcmc = 10000,
                     thin = 10, verbose = 0, seed = NA, lambda.start = NA, psi.start = NA, l0 = 0, L0 = 0, 
                     a0 = 0.001, b0 = 0.001, store.scores = FALSE, std.var = TRUE)
summary(fa.2)

# Notice in the summary (above), 'x1', 'x2', 'x3', and 'x4' load heavily on one factor and 'x5', 
# 'x6', 'x7', and 'x8' load heavily on the other factor; but the warning messages and noticable 
# cross-loadings should raise concern.

# In order to assess convergence and adequacy of the MCMC function / model, we can take a look at the 
# trace and density for each parameter as graphed with the plot command.
# Create/view the density plots for each parameter estimated (NOTE: you will have to click on the graph to
# advance to each subsequent graph). We expect the densities of the loadings (Lambda) to be roughly normally 
# distributed (in this example, they are not; which should raise more concern).

plot(fa.2)

# However, a more precise way of assessing convergence is with the Heidel diagnostic test from the 'coda' 
# package. The Heidel diagnostic test "uses the Cramer-von-Mises statistic to test the null hypothesis 
# that the sampled values come from a stationary distribution" (Plummer, Best, Cowles, & Vines, 2010). 

heidel.diag(fa.2)

# The output of the Heidel diagnostic test reveals convergence was not reached. This can be due to a small 
# number of iterations (i.e. the Markov Chain has not reached stationarity). Often increasing the mcmc (iterations)
# can correct this. HOWEVER; a better way to fix this is, being more precise about specifying the model/parameters 
# such as, which items load on one factor and which items load on the other factor (as will be done below with "fa.3"). 

#######################

# Extracting elements of the output. 

### First, the loadings (Lambda). 

loadings <- summary(fa.2)$statistics[1:16]
loadings

# Factor 1 item loadings (items x1, x2, x3, x4).

factor1.item.loadings <- loadings[c(1,3,5,7)]
factor1.item.loadings

# Factor 2 item loadings (items x5, x6, x7, x8).

factor2.item.loadings <- loadings[c(10,12,14,16)]
factor2.item.loadings

# Extract the 95% Credible Interval estimates of each loading.

ci.loadings <- summary(fa.2)$quantiles[1:16,c(1,5)]
ci.loadings

# Factor 1 item loading intervals (items x1, x2, x3, x4).

factor1.ci.loadings <- ci.loadings[c(1,3,5,7),]
factor1.ci.loadings

# Factor 2 item loading intervals (items x5, x6, x7, x8).

factor2.ci.loadings <- ci.loadings[c(10,12,14,16),]
factor2.ci.loadings

### Extract the uniquenesses (Psi). 

uniquenesses <- data.frame(summary(fa.2)$statistics[17:24], names(data1))
names(uniquenesses)[1] <- "uniquenesses"
uniquenesses

# Extract the 95% Credible Interval estimates of each uniqueness.

ci.unique <- summary(fa.2)$quantiles[17:24,c(1,5)]
ci.unique

# Calculate the Communalities for each item.

communalities <- data.frame(1 - uniquenesses[,1], names(data1))
names(communalities)[1] <- "communalities"
communalities


################################################################################

# Here constraining the loadings (Lambda) so that the first four items load exclusively on 
# factor 1 and not on factor 2; as well as ensuring the second four items load on factor 2 
# and not on factor 1; for instance, item "x1" is constrained on factor 2 to have a loading 
# of zero [e.g. x1=c(2,0)]. One could say this is a more 'confirmatory' strategy; which seems 
# appropriate when taking a Bayesian approach (i.e. the specification of a prior, which 
# is necessary; indicates an exploratory factor analysis was done previoiusly or previous
# research has established the structure of the measure). 

fa.3 <- MCMCfactanal(~x1+x2+x3+x4+x5+x6+x7+x8, factors = 2, data = data1, 
                     lambda.constraints=list(x1=list(2,0), x2=c(2,0), x3=list(2,0), x4=c(2,0),
                                             x5=list(1,0), x6=c(1,0), x7=list(1,0), x8=c(1,0)),
                     burnin = 1000, mcmc = 10000, thin = 10, verbose = 0, 
                     seed = NA, lambda.start = NA, psi.start = NA, l0 = 0, L0 = 0, 
                     a0 = 0.001, b0 = 0.001, store.scores = FALSE, std.var = TRUE)
summary(fa.3)

# Notice in the summary (above) the loadings are substantially greater than the previous MCMCfactanal,
# and the items are not allowed to cross-load (i.e. load on a factor they should not). In the situation 
# where items are thought to load on multiple factors, constraints can be used to specify how 
# each item loads on each factor (positive / negative; or magnitude of the loading for each factor). 

# Below, running the Heidel diagnostic test (from package 'coda') confirms stationarity was achieved. 

heidel.diag(fa.3)

# Also, the densities for the loadings are more normally distributed. 

plot(fa.3)


ls()

# NOTE: The 'MCMCpack' package also contains a function for doing MCMC factor analysis 
# with mixed data (i.e. continuous and ordinal variables).

help(MCMCmixfactanal)


################################################################################

# Martin, A. D., Quinn, K. M., & Park, J. H. (2010). Package 'MCMCpack'. 
# Package Reference Manual available at:
# http://cran.r-project.org/web/packages/MCMCpack/MCMCpack.pdf

# Plumer, M., Best, N., Cowles, K, & Vines, K. (2010). Package 'coda'. 
# Package Reference Manual available at:
# http://cran.r-project.org/web/packages/coda/coda.pdf





# End: 7 Jan. 2010.


