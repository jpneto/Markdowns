###################################
## Function to Color Dendrograms ##
###################################
dendroCol <- function(dend=dend, keys=keys, xPar="edgePar", bgr="red", fgr="blue", pch=20, lwd=1, ...) {
        if(is.leaf(dend)) {
                myattr <- attributes(dend)
                if(length(which(keys==myattr$label))==1){
                	attr(dend, xPar) <- c(myattr$edgePar, list(lab.col=fgr, col=fgr, pch=pch, lwd=lwd))
                	# attr(dend, xPar) <- c(attr$edgePar, list(lab.col=fgr, col=fgr, pch=pch))
                } else {
                	attr(dend, xPar) <- c(myattr$edgePar, list(lab.col=bgr, col=bgr, pch=pch, lwd=lwd))
                }
        }
  return(dend)
}
# Usage: 
# dend_colored <- dendrapply(dend, dendroCol, keys, xPar="edgePar", bgr="red", fgr="blue", pch=20) # use xPar="nodePar" to color tree labels
# plot(dend_colored, horiz=T)

