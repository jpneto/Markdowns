### Function for generating the posterior of Robo's position ###

landscape <- c(rep("plain", 50), rep("mountain", 25), rep("forest", 45))
landscape_color <- c(mountain = "black", forest = "green", plain = "yellow")
cover_cost <- c(mountain = 10, forest = 5, plain = 1)


posterior_sample <- function(n) {
  dist_i <- sample(3, n, replace = TRUE, c(18, 17, 65))
  mu <- c(15, 40, 90)
  sigma <- c(2, 4, 15)
  post <- rnorm(n, mu[dist_i], sigma[dist_i])
  post[post >= 0 & post <= 120]
} 

### Custom plot export functions ###

png_two_panels <- function(fname, expr) {
  png(fname, 700, 450, res = 96, bg = rgb(1, 1, 1, 0))
  expr
  dev.off()
}

png_one_panel <- function(fname, expr) {
  png(fname, 700, 300, res = 96, bg = rgb(1, 1, 1, 0))
  expr
  dev.off()
}

### Just looking at the posterior

plot(density(posterior_sample(99999)),  xlim=c(0, 120))
points(seq_along(landscape), rep(0, length(landscape)), col = landscape_color[landscape], pch=3) #TBC Color

### The common loss functions for point decisions

L0 <- function(x, s) {
  # just proportional to L0 loss.
  -approx(density(s), xout = x)$y
}

L1 <- function(x, s) {
  sum(abs(x - s))
}

L2 <- function(x, s) {
  sum((x - s)^2)
}

# Some new loss functions for point decisions

limited_dist_loss <- function(x, s, max_dist) {
  mean(abs(x - s) > max_dist)
}

limited_time_loss <- function(x, s, max_time) {
  mean(  
    sapply(s, function(sample)
      max_time < sum(cover_cost[landscape[x:sample] ])))  
}


# The posterior sample
s <- posterior_sample(99999)

### Plotting the posterior distance to Robo from the 60th mile ###

png("posterior_distance_given_decision.png", 700, 300, res = 96)
  old_par <- par(mar=c(4.1, 4.1, 1.1, 1.1))
  hist(abs(s - 60), 60, freq = FALSE, col=rgb(0.2, 0.7, 0.4), border = "transparent", main="", xlab="Post. dist. to Robo when starting the search at the 60th mile.", ylab="Probability")
  abline(v=mean(abs(s - 60)), col="darkred", lwd=3, lty=2)
  text(mean(abs(s - 60)), 0.04, labels = "Expected distance\nto Robo.", pos = 2, col="darkred")
  par(old_par)
dev.off()

### Custom plot function for plotting and optimizing a point loss function ###

plot_post_and_point <- function(s, loss_function, ..., color="darkgreen", loss_xlabel="Loss function (lower is better)", loss_ylabel="") {
  old_par <- par(no.readonly = TRUE)
  par(lab=c(5, 3, 1))
  layout(rbind(1, 2), 1, c(2, 1))
  #plot(density(s, adjust = 0.2),  xlim=c(0, 120))
  par(mar=c(3.1, 4.1, 3.1, 1.1))
  hist(s[s >= 0 & s <= 120], xlim=c(0, 120), breaks = 60, col = rgb(0.2, 0.2, 1, 0.5), border=rgb(1, 1, 1, 0.0),
       main="Posterior prob. of Robo's position", yaxt="s", freq=FALSE, ylab="Probability", xlab="")
  points(seq_along(landscape), rep(0, length(landscape)), col = landscape_color[landscape], pch="_") 
  least_loss <- which.min(sapply(1:120, loss_function, s=s, ...))
  print(least_loss)
  abline(v = least_loss, lty = 2, col=color, lwd=4)
  par(mar=c(4.1, 4.1, 0.1, 1.1))
  curve(Vectorize(loss_function, "x")(x, s, ...), 0, 120, col=color, lty=2, lwd=3,bty="n", ylab=loss_ylabel,xlab=loss_xlabel)
  par(old_par)
}

plot_post_and_point(s, L0)
plot_post_and_point(s, L1)
plot_post_and_point(s, L2)

# Nomalizes a vector to the interval [0, 1]
normalize_0_1 <- function(x) {
  (x-min(x))/(max(x)-min(x))
}

### Plotting the L0, L1, and L2 loss functions ###

png_two_panels("usual_loss_suspects.png", {
  old_par <- par(no.readonly = TRUE)
  layout(rbind(1, 2), 1, c(2, 1))
  #plot(density(s, adjust = 0.2),  xlim=c(0, 120))
  par(mar=c(3.1, 4.1, 3.1, 1.1))
  par(lab=c(5, 3, 1))
  hist(s[s >= 0 & s <= 120], xlim=c(0, 120), breaks = 60, col = rgb(0.2, 0.2, 1, 0.5), border=rgb(1, 1, 1, 0.0),
       main="Posterior prob. of Robo's position", yaxt="s", freq=FALSE, ylab="Probability", xlab="")
  points(seq_along(landscape), rep(0, length(landscape)), col = landscape_color[landscape], pch="_") 
  
  L0_least_loss <- which.min(sapply(1:120, L0, s=s))
  L1_least_loss <- which.min(sapply(1:120, L1, s=s))
  L2_least_loss <- which.min(sapply(1:120, L2, s=s))
  
  abline(v = L0_least_loss, col="darkorange", lwd=4, lty=1)
  text(L0_least_loss, y = par("yaxp")[2], labels = "L0", pos = 4, col="darkorange", cex = 1.5)
  abline(v = L1_least_loss, col="darkgreen", lwd=4, lty=2)
  text(L1_least_loss, y = par("yaxp")[2], labels = "L1", pos = 4, col="darkgreen", cex = 1.5)
  abline(v = L2_least_loss, col="purple", lwd=4, lty=3)
  text(L2_least_loss, y = par("yaxp")[2], labels = "L2", pos = 2, col="purple", cex = 1.5)
  par(mar=c(4.1, 4.1, 0.1, 1.1))
  curve(normalize_0_1(Vectorize(L0, "x")(x, s)), 0, 120, col="darkorange", lwd=2, lty=1,bty="n", ylab="", yaxt="n",xlab="Loss function (lower is better)")
  curve(normalize_0_1(Vectorize(L1, "x")(x, s)), 0, 120, col="darkgreen", lwd=2, lty=2, add=TRUE)
  curve(normalize_0_1(Vectorize(L2, "x")(x, s)), 0, 120 , col="purple", lwd=2, lty=3, add=TRUE)
  par(old_par)
})

### Plotting the new point loss functions ###

png_two_panels("limited_dist_loss.png", {
  plot_post_and_point(s, limited_dist_loss, max_dist = 30, color="darkgoldenrod1", loss_xlabel = "Prob. of not finding Robo within 30 miles.", loss_ylabel = "Probability")
})

png_two_panels("limited_time_loss_24.png", {
  plot_post_and_point(s, limited_time_loss, max_time = 24, color="chartreuse3", loss_xlabel = "Prob. of not finding Robo within 24 hours.", loss_ylabel = "Probability")
})

png_two_panels("limited_time_loss_72.png", {
  plot_post_and_point(s, limited_time_loss, max_time = 72, color="darkmagenta", loss_xlabel = "Prob. of not finding Robo within 72 hours.", loss_ylabel = "Probability")
})


### Plotting a 90% HDI ###
library(coda)

png_one_panel("90_perc_hdi.png", {
  old_par <- par(no.readonly = TRUE)
  par(lab=c(5, 3, 1))
  par(mar=c(3.1, 4.1, 3.1, 1.1))
  hist(s[s >= 0 & s <= 120], xlim=c(0, 120), breaks = 60, col = rgb(0.2, 0.2, 1, 0.5), border=rgb(1, 1, 1, 0.0),
       main="Posterior prob. of Robo's position", yaxt="s", freq=FALSE, ylab="Probability", xlab="")
  points(seq_along(landscape), rep(0, length(landscape)), col = landscape_color[landscape], pch="_")
  hdi <- HPDinterval(mcmc(s), prob = 0.90)
  arrows(x1 = hdi[1], x0 = hdi[2], y0 = par("yaxp")[c(2,2)], col="red", lwd=3, code=3, length = 0.1, angle=90)
  text(mean(hdi), y = par("yaxp")[2], labels = "90% prob. interval", col="red", pos = 3, offset = 0.75, cex=1.3)
  par(old_par)
})

### Plotting the fixed cost intervals ###

plot_post_and_cost_interval <- function(s, cost, ..., interval_label ="") {
  #plot(density(s, adjust = 0.5),  xlim=c(0, 120))
old_par <- par(no.readonly = TRUE)
  par(lab=c(5, 3, 1))
  par(mar=c(3.1, 4.1, 3.1, 1.1))
  hist(s[s >= 0 & s <= 120], xlim=c(0, 120), breaks = 60, col = rgb(0.2, 0.2, 1, 0.5), border=rgb(1, 1, 1, 0.0),
       main="Posterior prob. of Robo's position", yaxt="s", freq=FALSE, ylab="Probability", xlab="")
  points(seq_along(landscape), rep(0, length(landscape)), col = landscape_color[landscape], pch="_")
  
  prob_coverage <- t(sapply(seq_len(length(landscape) - 1), function(lower) {
    upper <- lower + max(which(cumsum(cover_cost[landscape[lower:length(landscape)]]) <= cost))
    c(mean(s >= lower & s <= upper), lower, upper)
  }))
  
  interval <- prob_coverage[which.max(prob_coverage[,1]), 2:3]
  
  arrows(x1 = interval[1], x0 = interval[2], y0 = par("yaxp")[c(2,2)], col="darkorchid", lwd=3, code=3, length = 0.1, angle=90)
  text(60, y = par("yaxp")[2], labels = interval_label, col="darkorchid", pos = 3, offset = 0.75, cex=1.3)
par(old_par)
}

png_one_panel("1000_cost_interval.png", {
  plot_post_and_cost_interval(s, cost = 10, interval_label = "Best $1,000 search range")
})

png_one_panel("3000_cost_interval.png", {
  plot_post_and_cost_interval(s, cost = 30, interval_label = "Best $3,000 search range")
})

png_one_panel("20000_cost_interval.png", {
  plot_post_and_cost_interval(s, cost = 200, interval_label = "Best $20,000 search range")
})


### Defining and plotting the utility function considering the value of Robo ###

utility_search <- function(start, end, s, robo_value) {
  posterior_utility <- sapply(s, function(robo_pos) {
    if(robo_pos >= start & robo_pos <= end) {
      covered_ground <- start:robo_pos
      robo_value - sum(cover_cost[landscape[ covered_ground] ])
    } else {
      covered_ground <- start:end
      - sum(cover_cost[landscape[ covered_ground] ])
    }
  })
  mean(posterior_utility)
}

utility_search <- function(par, s, value) {
  start <- par[1]
  end <- par[2]
  if(start == end) {
    return(0)
  }
  mean(sapply(s, function(sample) {
    if(sample >= start & sample <= end) {
      covered_ground <- start:sample
      value -  sum(cover_cost[landscape[ covered_ground] ])
    } else {
      covered_ground <- start:end
       -sum(cover_cost[landscape[ covered_ground] ])
    }
  }))
}


plot_utility_interval <- function(s, value, ..., plot_start_end=TRUE) {
  old_par <- par(no.readonly = TRUE)
  par(lab=c(5, 3, 1))
  par(mar=c(3.1, 4.1, 3.1, 1.1))
  hist(s[s >= 0 & s <= 120], xlim=c(0, 120), breaks = 60, col = rgb(0.2, 0.2, 1, 0.5), border=rgb(1, 1, 1, 0.0),
       main="Posterior prob. of Robo's position", yaxt="s", freq=FALSE, ylab="Probability", xlab="")
  points(seq_along(landscape), rep(0, length(landscape)), col = landscape_color[landscape], pch="_")
    
  pars_to_evaluate <- expand.grid(seq(0, 120, length.out = 30), seq(0, 120, length.out = 30))
  best_par <- which.max(apply(pars_to_evaluate, 1, utility_search, s=sample(s, replace = T, size = 1000), value=value))
  
  expected_utility <- print(utility_search(as.numeric(pars_to_evaluate[best_par,]), s, value))
  
  start <- pars_to_evaluate[best_par, 1]
  end <- pars_to_evaluate[best_par, 2]
  text(60, y = par("yaxp")[2], labels = paste0("Value of Robo: $", value*100, ", expected profit: $", round(100* expected_utility)), col="black", pos = 3, offset = 0.75, cex=1.3)
  if(start != end) {
    arrows(x0 = start, x1 = mean(c(start,end)), y0 = par("yaxp")[c(2,2)], col="darkred", lwd=4, code=1, length = 0.1, angle=90)
    arrows(x0 = mean(c(start,end)), x1 = end, y0 = par("yaxp")[c(2,2)], col="darkred", lwd=4, code=2, length = 0.1, angle=45)
    
    if(plot_start_end) {
      text(start, y = par("yaxp")[2], labels = "start", col="darkred", pos = 2, offset = 0.5, cex=1.3)
      text(end, y = par("yaxp")[2], labels = "end", col="darkred", pos = 4, offset = 0.5, cex=1.3)
    }
  }
par(old_par)
  
}

png_one_panel("expected_profit_1000_value.png", {
  plot_utility_interval(s, 10)
})

png_one_panel("expected_profit_10000_value.png", {
  plot_utility_interval(s, 100)
})

png_one_panel("expected_profit_20000_value.png", {
  plot_utility_interval(s, 200)
})

png_one_panel("expected_profit_40000_value.png", {
  plot_utility_interval(s, 400, plot_start_end = FALSE)
})