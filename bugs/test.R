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

###################################################
# read data
msg.data <- read.csv("txtdata.csv")
names(msg.data) <- c("msgs")
head(msg.data)

# model it
modelString = "
  model {
      tau ~ dcat(p[])  # the day that the Poisson parameter changes
      
      lambda1 ~ dexp(alpha) # the Poisson parameter before the change
      lambda2 ~ dexp(alpha) # the Poisson parameter after  the change

      for(i in 1:N) {
        p[i] <- 1/N         # each day has an a priori equal probability 
        lambdas[i] <- step(tau-i) * lambda1 + step(i-tau-1) * lambda2
        msgs[i] ~ dpois(lambdas[i])
      }

  }
"

# We list the data we know, in this case, there were 0 deaths in 10 operations
data.list = list(
  alpha = 1 / mean(msg.data$msgs), 
  msgs  = msg.data$msgs,
  N = length(msg.data$msgs)
)

run.model(modelString, samples=c("tau", "lambda1", "lambda2"), data=data.list, chainLength=1e5)

samplesStats("tau")      # stats of the posterior for the phase change
samplesStats("lambda1")  # stats of the posterior for the 1st interval
samplesStats("lambda2")  # stats of the posterior for the 2nd interval

hist(samplesSample("tau"), prob=TRUE, breaks=c(0,40.5,41.5,42.5,43.5,44.5,75), xlim=c(39,46))
hist(samplesSample("lambda1"), prob=TRUE, xlim=c(15,21),breaks=100)
hist(samplesSample("lambda2"), prob=TRUE, xlim=c(19,26),breaks=100)

# So the model, after processing the data, proposes the following scenario:

space <- 0.2
width <- 1
barplot(msg.data$msgs, names.arg=1:73, space=space, width=width)
lines((1:73)*(width+space),c(rep(17.9,43),rep(22.7,30)), lwd=2, col="red")
