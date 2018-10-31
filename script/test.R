# ref: http://docopt.org/
# ref: https://github.com/docopt/docopt.R
# eg on Win7: Rscript test.R -m 10 -s 3 -n 10000 -o sim_lots_of_data.csv

library(docopt)
'Usage:
   sim_normal.R [-m <mean> -s <sd> -n <nsamples> -o <output>]

Options:
-m Mean of distribution to sample from [default: 0]
-s SD of distribution to sample from [default: 1]
-n Number of samples [default: 100]
-o Output file [default: sim_data.csv]

]' -> doc

opts <- docopt(doc)

x <- rnorm(opts$n, mean = as.numeric(opts$m), sd = as.numeric(opts$s))
df <- data.frame(x = x)
write.csv(df, opts$o)