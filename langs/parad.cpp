

  #include <cstdlib>
  #include <iostream>
  #include <Rcpp.h>
  #include <omp.h>
  
  using namespace std;
  // [[Rcpp::export]]
  Rcpp::NumericVector parad(Rcpp::NumericVector x, Rcpp::NumericVector y) {
  
    int i,n,max;
    n=x.size();
    Rcpp::NumericVector product(n);
    
    max=omp_get_max_threads();
    omp_set_num_threads(max);
    
    #pragma omp parallel for
    for(i=0; i<n; i++){
      product[i] = x[i] / y[i];
    }
      return(product);
  }

