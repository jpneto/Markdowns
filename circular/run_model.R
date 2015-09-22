library(BRugs)

run.model <- function(model, samples, data=list(), chainLength=10000, burnin=0.10, 
                      init.func, n.chains=1, thin=1) {
  
  writeLines(model, con="model.txt")  # Write the modelString to a file
  modelCheck( "model.txt" )           # Send the model to BUGS, which checks the model syntax
  if (length(data)>0)                 # If there's any data available...
    modelData(bugsData(data))         # ... BRugs puts it into a file and ships it to BUGS
  modelCompile(n.chains)              # BRugs command tells BUGS to compile the model
  
  if (missing(init.func)) {
    modelGenInits()                   # BRugs command tells BUGS to randomly initialize a chain
  } else {
    for (chain in 1:n.chains) {       # otherwise use user's init data
      modelInits(bugsInits(init.func))
    }
  }
  
  modelUpdate(chainLength*burnin)     # Burn-in period to be discarded
  samplesSet(samples)                 # BRugs tells BUGS to keep a record of the sampled values
  samplesSetThin(thin)                # Set thinning
  modelUpdate(chainLength)            # BRugs command tells BUGS to randomly initialize a chain
}