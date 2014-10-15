





<!-- Includes \cancel latex command -->
<script type="text/x-mathjax-config">
MathJax.Hub.Register.StartupHook("TeX Jax Ready",function () {
  MathJax.Hub.Insert(MathJax.InputJax.TeX.Definitions.macros,{
    cancel: ["Extension","cancel"],
    bcancel: ["Extension","cancel"],
    xcancel: ["Extension","cancel"],
    cancelto: ["Extension","cancel"]
  });
});
</script>

BUGS tutorial (by example) Part II
=============

Let's repeat the essential code here:


```r
library(BRugs)

run.model <- function(model, samples, data=list(), chainLength=10000, burnin=0.10, 
                      init.func, n.chains=1) {
  
  writeLines(model, con="model.txt")  # Write the modelString to a file
  modelCheck( "model.txt" )           # Send the model to BUGS, which checks the model syntax
  if (length(data)>0)                 # If there's any data available...
    modelData(bugsData(data))         # ... BRugs puts it into a file and ships it to BUGS
  modelCompile()                      # BRugs command tells BUGS to compile the model
  
  if (missing(init.func)) {
    modelGenInits()                   # BRugs command tells BUGS to randomly initialize a chain
  } else {
    for (chain in 1:n.chains) {       # otherwise use user's init data
      modelInits(bugsInits(init.func))
    }
  }
    
  modelUpdate(chainLength*burnin)     # Burn-in period to be discarded
  samplesSet(samples)                 # BRugs tells BUGS to keep a record of the sampled values
  modelUpdate(chainLength)            # BRugs command tells BUGS to randomly initialize a chain
}
```


For ploting with error bars:


```r
plot.errors <- function(x, y, e) {
  plot(x, y, pch=19,ylim=c(min(y)*0.75,max(y)*1.2))
  segments(x, y-e,x, y+e)
  width.bar <- mean(e)/10
  segments(x-width.bar,y-e,x+width.bar,y-e)
  segments(x-width.bar,y+e,x+width.bar,y+e)
}
```


Bayesian Linear Regression
--------------------------

Given a data set $D = (x_1,y_1), \ldots, (x_N,y_N)$ where $x \in \mathbb{R}^d, y \in \mathbb{R}$, a Bayesian Linear Regression models the problem in the following way:

Prior: $$w \sim \mathcal{N}(0, \sigma_w^2 I_d)$$

$w$ is vector $(w_1, \ldots, w_d)^T$, so the previous distribution is a multivariate Gaussian; and $I_d$ is the $d\times d$ identity matrix.

Likelihood: $$Y_i \sim \mathcal{N}(w^T x_i, \sigma^2)$$

We assume that $Y_i \perp Y_j | w, i \neq j$

For now we'll use the precision instead of the variance, $a = 1/\sigma^2$, and $b = 1/\sigma_w^2$. We'll also assume that $a,b$ are known.

The prior can be stated as $$p(w) \propto \exp \Big\{ -\frac{b}{2} w^t w \Big\}$$

And the likelihood $$p(D|w) \propto \exp \Big\{ -\frac{a}{2} (y-Aw)^T (y-Aw) \Big\}$$

where $y = (y_1,\ldots,y_N)^T$ and $A$ is a $n\times d$ matrix where the i-th row is $x_i^T$.

The the posterior is $$p(w|D) \propto p(D|w) p(w)$$

After many [calculations](https://www.youtube.com/watch?v=nrd4AnDLR3U&list=PLD0F06AA0D2E8FFBA&index=61) we discover that

$$p(w|D) \sim \mathcal{N}(w | \mu, \Lambda^{-1})$$

where ($\Lambda$ is the precision matrix)

$$\Lambda = a A^T A + b I_d $$
$$\mu = a \Lambda^{-1} A^T y$$

Notice that $\mu$ is equal to the $w_{MAP}$ of the regular linear regression, this is because for the Gaussian, the mean is equal to the mode.

Also, we can make some algebra over $\mu$ and get the following equality ($\Lambda = aA^TA+bI_d$):

$$\mu = (A^T A + \frac{b}{a} I_d)^{-1} A^T y$$

and compare with $w_{MLE}$:

$$w_{MLE} = (A^T A)^{-1} A^T y$$

The extra expression in $\mu$ corresponds to the prior. This is similar to the expression for the Ridge regression, for the special case when $\lambda = \frac{b}{a}$. Ridge regression is more general because the technique can choose improper priors (in the Bayesian perspective).

For the predictive posterior distribution:

$$p(y|x,D) = \int p(y|x,D,w) p(w|x,D) dw = \int p(y|x,w) p(w|D) dw$$

it is possible to calculate that

$$y|x,D \sim \mathcal{N}(\mu^Tx, \frac{1}{a} + x^T \Lambda^{-1}x)$$

Using BUGS
----------


```r
modelString = "
  model {
      for (i in 1:5) {
        y[i] ~ dnorm(mu[i], tau)
        mu[i] <- beta0 + beta1 * (x[i] - mean(x[]))
      }
  
      # Jeffreys priors
      beta0 ~ dflat()
      beta1 ~ dflat()
      tau   <- 1/sigma2
      log(sigma2) <- 2*log.sigma
      log.sigma ~ dflat()
  }
"

# data
x <- c(  8,  15,  22,  29,  36)  # day of measure
y <- c(177, 236, 285, 350, 376)  # weight in grams

data.list = list(
    x = x, 
    y = y  
)

# initializations
n.chains <- 1
log.sigmas <- c(0)
betas0 <- c(0)
betas1 <- c(0)

genInitFactory <- function()  {
  i <- 0
  function() {
    i <<- i + 1
    list( 
      log.sigma = log.sigmas[i],
      beta0 = betas0[i],
      beta1 = betas1[i]
    ) 
  }
}

run.model(modelString, samples=c("beta0", "beta1", "sigma2"), data=data.list, chainLength=15000,
          init.func=genInitFactory(), n.chains=n.chains)

samplesStats(c("beta0", "beta1", "sigma2"))
```

```
          mean        sd  MC_error val2.5pc  median val97.5pc start sample
beta0  284.900    8.2160  0.056790  270.100 284.900   300.300  1501  15000
beta1    7.311    0.8012  0.006087    5.845   7.308     8.783  1501  15000
sigma2 326.100 1015.0000 37.170000   37.950 144.300  1570.000  1501  15000
```

```r

# Extract chain values:
beta0  <- samplesSample( "beta0" )
beta1  <- samplesSample( "beta1" )
sigma2 <- samplesSample( "sigma2" )

# Posterior prediction [from Kruschke - Doing Bayesian Data Analysis (2010)]
# Specify x values for which predicted y's are needed:
xPostPred <- seq( min(x)-5 , max(x)+5 , length=100 ) # just make a bunch of them
# Define matrix for recording posterior predicted y values at each x value.
# One row per x value, with each row holding random predicted y values.
postSampSize <- length(beta0)
yPostPred <- matrix( 0 , nrow=length(xPostPred) , ncol=postSampSize )
# Define matrix for recording HDI limits of posterior predicted y values:
yHDIlim <- matrix( 0 , nrow=length(xPostPred) , ncol=2 )
# Generate posterior predicted y values.
# This gets only one y value, at each x, for each step in the chain.
xM <- mean(xPostPred)
# generate values according to the model specified in BUGS:
# y[i] ~ dnorm(mu[i], tau)
# mu[i] <- beta0 + beta1 * (x[i] - mean(x[]))
for ( chainIdx in 1:postSampSize ) {
  yPostPred[,chainIdx] <- rnorm( length(xPostPred) ,  # rnorm(n, mean, sd)
                                 beta0[chainIdx] + beta1[chainIdx] * (xPostPred - xM),
                                 sqrt(sigma2) )
}

source("HDIofMCMC.R") # call Kruschke's Highest Density Interval (HDI) script
for ( xIdx in 1:length(xPostPred) ) {  # get 95% HDI for each predicted x
    yHDIlim[xIdx,] <- HDIofMCMC( yPostPred[xIdx,] )
}
head(yHDIlim)
```

```
      [,1]  [,2]
[1,] 105.2 187.0
[2,] 110.2 190.4
[3,] 111.9 190.4
[4,] 115.3 194.1
[5,] 118.1 196.6
[6,] 121.1 198.7
```

```r
# Display data with HDIs of posterior predictions.
plot( x , y, xlim=c(8,36) , ylim=c(100,500), type="n", ylab=expression(hat(y)),
      main="Data with 95% HDI & Mean of Posterior Predictions")
polygon(c(xPostPred,rev(xPostPred)), c(yHDIlim[,1],rev(yHDIlim[,2])), col="lightgray")  # HDI's
points(x,y, pch=19)
lines( xPostPred , apply(yPostPred,1,mean) , col="red" ) # the linear regression
```

<img src="figure/unnamed-chunk-4.svg" title="plot of chunk unnamed-chunk-4" alt="plot of chunk unnamed-chunk-4" style="display: block; margin: auto;" />


Checking the analytical solution vs. the simulated one:


```r
a <- 1/var(x)
b <- 1/20
A <- matrix(x, ncol=1)                           # d=1, ie, 1D samples

Lambda <- a * t(A) %*% A + b * diag(ncol(A))
mu     <- a * solve(Lambda) %*% t(A) %*% y

i <- 31  # select one of the estimated values
hist(yPostPred[i,], prob=T, breaks=100) # plot the estimated histogram

new.x <- xPostPred[i]
new.x
```

```
[1] 14.52
```

```r

ys <- seq(100,300,1)
lines(ys, dnorm(ys, t(mu)%*%new.x, sqrt(1/a+t(new.x)%*%solve(Lambda)%*%new.x)) , lwd=2, col="red")
```

<img src="figure/unnamed-chunk-5.svg" title="plot of chunk unnamed-chunk-5" alt="plot of chunk unnamed-chunk-5" style="display: block; margin: auto;" />


TODO: this does not fit :-(

Bayesian Regression with outliers
---------------------

We got this data somehow (in fact, from [here](http://jakevdp.github.io/blog/2014/06/06/frequentism-and-bayesianism-2-when-results-differ/)).


```r
x <- c(0,  3,  9, 14, 15, 19, 20, 21, 30, 35, 40, 41, 42, 43, 54, 56, 67, 69, 72, 88)
y <- c(33, 68, 34, 34, 37, 71, 37, 44, 48, 49, 53, 49, 50, 48, 56, 60, 61, 63, 44, 71)
e <- c(3.6, 3.9, 2.6, 3.4, 3.8, 3.8, 2.2, 2.1, 2.3, 3.8, 2.2, 2.8, 3.9, 3.1, 3.4, 2.6, 3.4, 3.7, 2.0, 3.5) # error of y

plot.errors(x,y,e)
```

<img src="figure/unnamed-chunk-6.svg" title="plot of chunk unnamed-chunk-6" alt="plot of chunk unnamed-chunk-6" style="display: block; margin: auto;" />


We wish to model this using a linear model:

$$\hat{y}(x|\theta) = \theta_0 + \theta_1 x$$

and assume that the likelihood for each point is modelled by a Gaussian:

$$p(x_i,y_i,e_i | \theta) \propto \exp \Big\{ -\frac{1}{2e_i^2} (y - \hat{y}(x|\theta))^2 \Big\}$$

The traditional linear regression gives:


```r
fit <- lm(y~x, data=data.frame(x=x,y=y))
plot.errors(x,y,e)
abline(fit,col="red",lwd=2)                        # showing the linear fit
points(x[c(2,6,19)],y[c(2,6,19)],col="red",pch=19) # showing the outliers
```

<img src="figure/unnamed-chunk-7.svg" title="plot of chunk unnamed-chunk-7" alt="plot of chunk unnamed-chunk-7" style="display: block; margin: auto;" />


which does not seem right at all! This is because of the three obvious outliers (above in red) that influence the result.

We can hack a bit and use the Huber loss function, which is useful to deal with outliers in a classic statistics setting, providing a robust linear regression:


```r
# a: residuals, ie, y - hat.y
huber <- function(a, delta) {
  ifelse(abs(a)<delta, a^2/2, delta*(abs(a)-delta/2))      # ifelse is a vectorized conditional
}

huber.loss <- function(theta, x=x, y=y, e=e, delta=3) {
  sum( huber((y - theta[1] - theta[2]*x)/e, delta) )
}

fit.huber <- optim(par=c(0,0), fn=huber.loss, x=x, y=y, e=e) # find best values using optimization

plot.errors(x,y,e)
abline(fit,col="lightgrey",)                               # showing the linear fit  (in grey)
abline(fit.huber$par[1],fit.huber$par[2], col="red",lwd=2) # showing the robust fit
```

<img src="figure/unnamed-chunk-8.svg" title="plot of chunk unnamed-chunk-8" alt="plot of chunk unnamed-chunk-8" style="display: block; margin: auto;" />


which is way better. However the Huber loss function, and the choice of its parameter value (set here to $3$), are somewhat hacks, _ad hoc_ tools to attack the outlier problem.

In Bayesian terms acknowledging the outliers exist, we should modify the model in order to account them.

Now the likelihood will be the following:

$$p(x_i,y_i,e_i | \theta, g_i,\sigma_B) = \frac{g_i}{\sqrt{2\pi e_i^2}} \exp \Big\{ -\frac{1}{2e_i^2} (y - \hat{y}(x|\theta))^2 \Big\} + \frac{1-g_i}{\sqrt{2\pi \sigma_B^2}} \exp \Big\{ -\frac{1}{2 \sigma_B^2} (y - \hat{y}(x|\theta))^2 \Big\}$$

herein, parameter $g_i=0$ means that data point $x_i$ is an outlier, while $g=1$ means that $x_i$ is not. If the i-th point is an outlier the likelihhod will use a Gaussian of variance $\sigma_B$ that might be considered an extra nuissance parameter, or set to a high value (we'll choose value $50$). Our model has now 22 parameters instead of the initial two ($\theta_0$ and $\theta_1$).

Since BUGS cannot sample from an arbitrary distribution, we can use the [zeros trick](http://users.aims.ac.za/~mackay/BUGS/Manuals/Tricks.html#SpecifyingANewSamplingDistribution) to plug the likelihood directly:


```r
modelString = "
  model {
      for (i in 1:n) {

        phi[i] <- -log( (g[i]/sqrt(2*pi*pow(e[i],2))) * exp(-0.5*pow(y[i]-mu[i],2)/pow(e[i],2)) + ((1-g[i])/sqrt(2*pi*pow(sigmaB,2))) * exp(-0.5*pow(y[i]-mu[i],2)/pow(sigmaB,2)) ) + C
        
        dummy[i] <- 0
        dummy[i] ~ dpois( phi[i] )

        mu[i] <- theta0 + theta1 * x[i]
        g[i] ~ dunif(0,1)
        
      }
 
      theta0 ~ dflat()
      theta1 ~ dflat()
      
      C <- 10000   # for the zero's trick
      pi <- 3.14159
  }
"

# data
data.list = list(
    x = x, 
    y = y,
    e = e,
    n = length(x),
    sigmaB = 50
)

# initializations
n.chains <- 1
theta0 <- c(0)
theta1 <- c(0)
g <- rep(0.01,length(x))

genInitFactory <- function()  {
  i <- 0
  function() {
    i <<- i + 1
    list( 
      theta0 = theta0[i],
      theta1 = theta1[i],
      g = g
    ) 
  }
}

run.model(modelString, samples=c("theta0", "theta1", "g"), data=data.list, 
          chainLength=25000, init.func=genInitFactory(), n.chains=n.chains)

samplesStats(c("theta0", "theta1", "g"))
```

```
          mean      sd  MC_error val2.5pc  median val97.5pc start sample
theta0 31.2900 1.59800 0.0244500 28.21000 31.2800   34.5200  2501  25000
theta1  0.4686 0.03756 0.0006304  0.39420  0.4689    0.5418  2501  25000
g[1]    0.6430 0.25340 0.0020030  0.09925  0.6860    0.9868  2501  25000
g[2]    0.3346 0.23760 0.0019920  0.01218  0.2947    0.8465  2501  25000
g[3]    0.6425 0.25030 0.0022460  0.10180  0.6846    0.9858  2501  25000
g[4]    0.6233 0.25990 0.0020040  0.08467  0.6630    0.9850  2501  25000
g[5]    0.6401 0.25110 0.0023100  0.10020  0.6806    0.9863  2501  25000
g[6]    0.3329 0.23490 0.0020340  0.01324  0.2921    0.8383  2501  25000
g[7]    0.6062 0.26920 0.0021030  0.05966  0.6469    0.9851  2501  25000
g[8]    0.6215 0.25940 0.0021900  0.08211  0.6607    0.9855  2501  25000
g[9]    0.6368 0.25400 0.0019250  0.09842  0.6781    0.9865  2501  25000
g[10]   0.6399 0.25210 0.0019420  0.10140  0.6802    0.9859  2501  25000
g[11]   0.6293 0.25830 0.0021680  0.08466  0.6736    0.9855  2501  25000
g[12]   0.6400 0.25070 0.0020630  0.10750  0.6816    0.9860  2501  25000
g[13]   0.6386 0.25270 0.0020840  0.10070  0.6795    0.9860  2501  25000
g[14]   0.6351 0.25640 0.0020060  0.09118  0.6775    0.9862  2501  25000
g[15]   0.6413 0.25050 0.0021140  0.10880  0.6835    0.9859  2501  25000
g[16]   0.6376 0.25310 0.0021460  0.09801  0.6781    0.9867  2501  25000
g[17]   0.6420 0.25420 0.0022570  0.09991  0.6862    0.9880  2501  25000
g[18]   0.6404 0.25310 0.0022110  0.10290  0.6832    0.9862  2501  25000
g[19]   0.3309 0.23340 0.0020240  0.01292  0.2891    0.8360  2501  25000
g[20]   0.6339 0.25450 0.0019920  0.09798  0.6762    0.9862  2501  25000
```

```r

theta0.hat <- mean(samplesSample("theta0"))
theta1.hat <- mean(samplesSample("theta1"))

plot.errors(x,y,e)
abline(fit,col="lightgrey",)                                # showing the linear fit (in grey)
abline(fit.huber$par[1],fit.huber$par[2], col="grey",lwd=2) # showing the robust fit (in solid grey)
abline(theta0.hat, theta1.hat, col="red",lwd=2)
# define outliers as those which g[i] is less than 0.5
posterior.g <- rep(NA,length(g))
for(i in 1:length(g)) {
  posterior.g[i] <- mean(samplesSample(paste0("g[",i,"]")))
}
outliers <- which(posterior.g<0.5)
# plot outliers
points(x[outliers], y[outliers], col="red", pch=12)
```

<img src="figure/unnamed-chunk-9.svg" title="plot of chunk unnamed-chunk-9" alt="plot of chunk unnamed-chunk-9" style="display: block; margin: auto;" />


If we do not care of outlier accounting, we can just use a more heavy-tailed distribution to prevent the outlier influence. The next model uses a t distribution for that effect:


```r
modelString = "
  model {
      for (i in 1:n) {
        tau[i] <- 1/pow(e[i],2)
        y[i] ~ dt(mu[i], tau[i], 4)
    
        mu[i] <- theta0 + theta1 * x[i]
      }
  
      theta0 ~ dflat()
      theta1 ~ dflat()
  }
"

data.list = list(
    x = x, 
    y = y,
    e = e,
    n = length(x)
)

# initializations
n.chains <- 1
theta0 <- c(0)
theta1 <- c(0)

genInitFactory <- function()  {
  i <- 0
  function() {
    i <<- i + 1
    list( 
      theta0 = theta0[i],
      theta1 = theta1[i]
    ) 
  }
}

run.model(modelString, samples=c("theta0", "theta1"), data=data.list, chainLength=15000,
          init.func=genInitFactory(), n.chains=n.chains)

samplesStats(c("theta0", "theta1"))
```

```
          mean      sd MC_error val2.5pc  median val97.5pc start sample
theta0 32.1600 1.70100 0.045930  28.9400 32.1400    35.580  1501  15000
theta1  0.4451 0.03785 0.001012   0.3689  0.4454     0.518  1501  15000
```

```r

theta0.hat <- mean(samplesSample("theta0"))
theta1.hat <- mean(samplesSample("theta1"))

plot.errors(x,y,e)
abline(fit,col="lightgrey",)                                # showing the linear fit (in grey)
abline(fit.huber$par[1],fit.huber$par[2], col="grey",lwd=2) # showing the robust fit (in solid grey)
abline(theta0.hat, theta1.hat, col="red",lwd=2)
```

<img src="figure/unnamed-chunk-10.svg" title="plot of chunk unnamed-chunk-10" alt="plot of chunk unnamed-chunk-10" style="display: block; margin: auto;" />


