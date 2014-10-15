


Benchmarking
========================================================

`system.time()` returns CPU (and other) times that expr used.


```r
x <- rep(NA,10000)
system.time(for(i in 1:10000) x[i] <- mean(runif(1000)))  
```

```
   user  system elapsed 
    0.7     0.0     0.7 
```

```r
system.time(sort(x))  
```

```
   user  system elapsed 
      0       0       0 
```


`microbenchmark` serves as a more accurate replacement of the often seen system.time(replicate(1000, expr)) expression. It tries hard to accurately measure only the time it takes to evaluate expr. To achieved this, the sub-millisecond (supposedly nanosecond) accurate timing functions most modern operating systems provide are used. Additionally all evaluations of the expressions are done in C code to minimze any overhead.


```r
library(microbenchmark)
m <- microbenchmark(
  xs <- 1:1000,
  for(i in 1:1000) {xs[i] <- i},
  xs <- rnorm(1000),
  times = 250
)
m
```

```
Unit: microseconds
                                 expr      min       lq  median       uq
                         xs <- 1:1000    1.281    2.134    2.56    2.561
 for (i in 1:1000) {     xs[i] <- i } 2514.348 2560.854 2594.77 2649.601
                    xs <- rnorm(1000)  146.774  150.614  151.89  154.881
      max neval
    8.534   250
 3959.894   250
  258.987   250
```

```r
boxplot(m)
```

![plot of chunk unnamed-chunk-3](figure/unnamed-chunk-31.png) 

```r
library(ggplot2) 
qplot(y=time, data=m, colour=expr) + scale_y_log10()
```

![plot of chunk unnamed-chunk-3](figure/unnamed-chunk-32.png) 


The library consists of just one function, benchmark, which is a simple wrapper around `system.time`.

Given a specification of the benchmarking process (counts of replications, evaluation environment) and an arbitrary number of expressions, `benchmark()` evaluates each of the expressions in the specified environment, replicating the evaluation as many times as specified, and returning the results conveniently wrapped into a data frame.


```r
library(rbenchmark)

random.array = function(rows, cols, dist=rnorm) 
                  array(dist(rows*cols), c(rows, cols))
random.replicate = function(rows, cols, dist=rnorm)
                      replicate(cols, dist(rows))

results <- 
  benchmark(random.array(100, 100),
            random.replicate(100, 100),
            columns=c('test', 'elapsed', 'replications'),
            replications=c(20,40),
            order="elapsed")

results[results$test == "random.array(100, 100)",]
```

```
                    test elapsed replications
1 random.array(100, 100)    0.03           20
3 random.array(100, 100)    0.07           40
```

```r
results[results$test == "random.replicate(100, 100)",]
```

```
                        test elapsed replications
2 random.replicate(100, 100)    0.05           20
4 random.replicate(100, 100)    0.10           40
```

