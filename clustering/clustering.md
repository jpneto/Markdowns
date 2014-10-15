


Clustering
========================================================


Refs:

+ [http://horicky.blogspot.pt/2012/04/machine-learning-in-r-clustering.html](http://horicky.blogspot.pt/2012/04/machine-learning-in-r-clustering.html)
+ [http://manuals.bioinformatics.ucr.edu/home/R_BioCondManual#TOC-Clustering-and-Data-Mining-in-R](http://manuals.bioinformatics.ucr.edu/home/R_BioCondManual#TOC-Clustering-and-Data-Mining-in-R)
 
K-Means
-------

1. Pick an initial set of K centroids (this can be random or any other means)
2. For each data point, assign it to the member of the closest centroid according to the given distance function
3. Adjust the centroid position as the mean of all its assigned member data points. Go back to (2) until the membership isn't change and centroid position is stable.
4. Output the centroids.

Notice that in K-Means, we require the definition of:
+ the distance function 
+ the mean function 
+ the number of centroids $K$

K-Means is  $O(nkr)$, where $n$ is the number of points, $r$ is the number of rounds and $k$ the number of centroids.

The result of each round is undeterministic. The usual practices is to run multiple rounds of K-Means and pick the result of the best round. The best round is one who minimize the average distance of each point to its assigned centroid.


```r
library(stats)
set.seed(101)
km <- kmeans(iris[,1:4], 3)
plot(iris[,1], iris[,2], col=km$cluster)
points(km$centers[,c(1,2)], col=1:3, pch=19, cex=2)
```

<img src="figure/unnamed-chunk-21.svg" title="plot of chunk unnamed-chunk-2" alt="plot of chunk unnamed-chunk-2" style="display: block; margin: auto;" />

```r
table(km$cluster, iris$Species)
```

```
   
    setosa versicolor virginica
  1      0         48        14
  2     50          0         0
  3      0          2        36
```

```r
# Another round:
set.seed(900)
km <- kmeans(iris[,1:4], 3)
plot(iris[,1], iris[,2], col=km$cluster)
points(km$centers[,c(1,2)], col=1:3, pch=19, cex=2)
```

<img src="figure/unnamed-chunk-22.svg" title="plot of chunk unnamed-chunk-2" alt="plot of chunk unnamed-chunk-2" style="display: block; margin: auto;" />

```r
table(km$cluster, iris$Species)
```

```
   
    setosa versicolor virginica
  1      0         46        50
  2     17          4         0
  3     33          0         0
```


Hierarchical Clustering
-----------------------

In this approach, it compares all pairs of data points and merge the one with the closest distance.

1. Compute distance between every pairs of point/cluster. 
(a) Distance between point is just using the distance function. 
(b) Compute distance between pointA to clusterB may involve many choices (such as the min/max/avg distance between the pointA and points in the clusterB). 
(c) Compute distance between clusterA to clusterB may first compute distance of all points pairs (one from clusterA and the other from clusterB) and then pick either min/max/avg of these pairs.
2. Combine the two closest point/cluster into a cluster. Go back to (1) until only one big cluster remains.

In hierarchical clustering, the complexity is O(n^2), the output will be a tree of merging steps. It doesn't require us to specify $K$ or a mean function. Since its high complexity, hierarchical clustering is typically used when the number of points are not too high.


```r
m <- matrix(1:15,5,3)
dist(m) # computes the distance between rows of m (since there are 3 columns, it is the euclidian distance between tri-dimensional points)
```

```
      1     2     3     4
2 1.732                  
3 3.464 1.732            
4 5.196 3.464 1.732      
5 6.928 5.196 3.464 1.732
```

```r
dist(m,method="manhattan") # using the manhattan metric
```

```
   1  2  3  4
2  3         
3  6  3      
4  9  6  3   
5 12  9  6  3
```

```r
set.seed(101)
sampleiris <- iris[sample(1:150, 40),] # get samples from iris dataset
# each observation has 4 variables, ie, they are interpreted as 4-D points
distance   <- dist(sampleiris[,-5], method="euclidean") 
cluster    <- hclust(distance, method="average")
plot(cluster, hang=-1, label=sampleiris$Species)
```

<img src="figure/unnamed-chunk-3.svg" title="plot of chunk unnamed-chunk-3" alt="plot of chunk unnamed-chunk-3" style="display: block; margin: auto;" />


Other ways to present the information:


```r
plot(as.dendrogram(cluster), edgePar=list(col="darkgreen", lwd=2), horiz=T) 
```

<img src="figure/unnamed-chunk-4.svg" title="plot of chunk unnamed-chunk-4" alt="plot of chunk unnamed-chunk-4" style="display: block; margin: auto;" />

```r
str(as.dendrogram(cluster)) # Prints dendrogram structure as text.
```

```
--[dendrogram w/ 2 branches and 40 members at h = 3.95]
  |--[dendrogram w/ 2 branches and 13 members at h = 0.819]
  |  |--[dendrogram w/ 2 branches and 6 members at h = 0.426]
  |  |  |--[dendrogram w/ 2 branches and 2 members at h = 0.141]
  |  |  |  |--leaf "9" 
  |  |  |  `--leaf "39" 
  |  |  `--[dendrogram w/ 2 branches and 4 members at h = 0.28]
  |  |     |--leaf "30" 
  |  |     `--[dendrogram w/ 2 branches and 3 members at h = 0.244]
  |  |        |--leaf "7" 
  |  |        `--[dendrogram w/ 2 branches and 2 members at h = 0.141]
  |  |           |--leaf "48" 
  |  |           `--leaf "3" 
  |  `--[dendrogram w/ 2 branches and 7 members at h = 0.574]
  |     |--leaf "37" 
  |     `--[dendrogram w/ 2 branches and 6 members at h = 0.563]
  |        |--[dendrogram w/ 2 branches and 2 members at h = 0.387]
  |        |  |--leaf "6" 
  |        |  `--leaf "20" 
  |        `--[dendrogram w/ 2 branches and 4 members at h = 0.452]
  |           |--[dendrogram w/ 2 branches and 2 members at h = 0.265]
  |           |  |--leaf "44" 
  |           |  `--leaf "24" 
  |           `--[dendrogram w/ 2 branches and 2 members at h = 0.3]
  |              |--leaf "28" 
  |              `--leaf "50" 
  `--[dendrogram w/ 2 branches and 27 members at h = 2.63]
     |--[dendrogram w/ 2 branches and 3 members at h = 0.912]
     |  |--leaf "110" 
     |  `--[dendrogram w/ 2 branches and 2 members at h = 0.819]
     |     |--leaf "106" 
     |     `--leaf "118" 
     `--[dendrogram w/ 2 branches and 24 members at h = 1.6]
        |--[dendrogram w/ 2 branches and 13 members at h = 1.03]
        |  |--[dendrogram w/ 2 branches and 4 members at h = 0.752]
        |  |  |--leaf "103" 
        |  |  `--[dendrogram w/ 2 branches and 3 members at h = 0.494]
        |  |     |--leaf "140" 
        |  |     `--[dendrogram w/ 2 branches and 2 members at h = 0.361]
        |  |        |--leaf "117" 
        |  |        `--leaf "148" 
        |  `--[dendrogram w/ 2 branches and 9 members at h = 1.01]
        |     |--[dendrogram w/ 2 branches and 3 members at h = 0.557]
        |     |  |--leaf "51" 
        |     |  `--[dendrogram w/ 2 branches and 2 members at h = 0.374]
        |     |     |--leaf "77" 
        |     |     `--leaf "55" 
        |     `--[dendrogram w/ 2 branches and 6 members at h = 0.769]
        |        |--leaf "135" 
        |        `--[dendrogram w/ 2 branches and 5 members at h = 0.482]
        |           |--[dendrogram w/ 2 branches and 2 members at h = 0.361]
        |           |  |--leaf "124" 
        |           |  `--leaf "128" 
        |           `--[dendrogram w/ 2 branches and 3 members at h = 0.361]
        |              |--leaf "84" 
        |              `--[dendrogram w/ 2 branches and 2 members at h = 0]
        |                 |--leaf "102" 
        |                 `--leaf "143" 
        `--[dendrogram w/ 2 branches and 11 members at h = 1.3]
           |--[dendrogram w/ 2 branches and 8 members at h = 0.632]
           |  |--leaf "92" 
           |  `--[dendrogram w/ 2 branches and 7 members at h = 0.559]
           |     |--leaf "85" 
           |     `--[dendrogram w/ 2 branches and 6 members at h = 0.445]
           |        |--leaf "93" 
           |        `--[dendrogram w/ 2 branches and 5 members at h = 0.408]
           |           |--leaf "56" 
           |           `--[dendrogram w/ 2 branches and 4 members at h = 0.345]
           |              |--leaf "62" 
           |              `--[dendrogram w/ 2 branches and 3 members at h = 0.198]
           |                 |--leaf "89" 
           |                 `--[dendrogram w/ 2 branches and 2 members at h = 0.141]
           |                    |--leaf "97" 
           |                    `--leaf "100" 
           `--[dendrogram w/ 2 branches and 3 members at h = 0.858]
              |--leaf "80" 
              `--[dendrogram w/ 2 branches and 2 members at h = 0.721]
                 |--leaf "99" 
                 `--leaf "61" 
```

```r
cluster$labels[cluster$order] # Prints the row labels in the order they appear in the tree.
```

```
 [1] "9"   "39"  "30"  "7"   "48"  "3"   "37"  "6"   "20"  "44"  "24" 
[12] "28"  "50"  "110" "106" "118" "103" "140" "117" "148" "51"  "77" 
[23] "55"  "135" "124" "128" "84"  "102" "143" "92"  "85"  "93"  "56" 
[34] "62"  "89"  "97"  "100" "80"  "99"  "61" 
```


It's possible to prune the resulting tree. In the next egs we cut by number of clusters:


```r
par(mfrow=c(1,2))
group.3 <- cutree(cluster, k = 3)  # prune the tree by 3 clusters
table(group.3, sampleiris$Species) # compare with known classes
```

```
       
group.3 setosa versicolor virginica
      1      0         15         9
      2     13          0         0
      3      0          0         3
```

```r
plot(sampleiris[,c(1,2)], col=group.3, pch=19, cex=2.5, main="3 clusters")
points(sampleiris[,c(1,2)], col=sampleiris$Species, pch=19, cex=1)
group.6 <- cutree(cluster, k = 6)  # we can prune by more clusters
table(group.6, sampleiris$Species)
```

```
       
group.6 setosa versicolor virginica
      1      0          8         0
      2     13          0         0
      3      0          0         3
      4      0          4         5
      5      0          3         0
      6      0          0         4
```

```r
plot(sampleiris[,c(1,2)], col=group.6, pch=19, cex=2.5, main="6 clusters")
points(sampleiris[,c(1,2)], col=sampleiris$Species, pch=19, cex=1) # the little points are the true classes
```

<img src="figure/unnamed-chunk-5.svg" title="plot of chunk unnamed-chunk-5" alt="plot of chunk unnamed-chunk-5" style="display: block; margin: auto;" />

```r
par(mfrow=c(1,1))
```


It is also possible to cut by height of the original tree:


```r
plot(cluster, hang=-1, label=sampleiris$Species)
abline(h=0.9,lty=3,col="red")
```

<img src="figure/unnamed-chunk-61.svg" title="plot of chunk unnamed-chunk-6" alt="plot of chunk unnamed-chunk-6" style="display: block; margin: auto;" />

```r
height.0.9 <- cutree(cluster, h = 0.9)
table(height.0.9, sampleiris$Species) # compare with known classes
```

```
          
height.0.9 setosa versicolor virginica
         1      0          8         0
         2     13          0         0
         3      0          0         2
         4      0          3         0
         5      0          1         5
         6      0          3         0
         7      0          0         1
         8      0          0         4
```

```r
plot(sampleiris[,c(1,2)], col=height.0.9, pch=19, cex=2.5, main="3 clusters")
points(sampleiris[,c(1,2)], col=sampleiris$Species, pch=19, cex=1)
```

<img src="figure/unnamed-chunk-62.svg" title="plot of chunk unnamed-chunk-6" alt="plot of chunk unnamed-chunk-6" style="display: block; margin: auto;" />


And if we don't know the number of clusters? ([ref](http://www2.stat.unibo.it/montanari/Didattica/Multivariate/CA_lab.pdf))


```r
# Calculate the dissimilarity between observations using the Euclidean distance 
dist.iris <- dist(iris, method="euclidean")
# Compute a hierarchical cluster analysis on the distance matrix using the complete linkage method 
h.iris <- hclust(dist.iris, method="complete") 
h.iris
```

```

Call:
hclust(d = dist.iris, method = "complete")

Cluster method   : complete 
Distance         : euclidean 
Number of objects: 150 
```

```r
head(h.iris$merge, n=10)
```

```
      [,1] [,2]
 [1,] -102 -143
 [2,]   -8  -40
 [3,]   -1  -18
 [4,]  -10  -35
 [5,] -129 -133
 [6,]  -11  -49
 [7,]   -5  -38
 [8,]  -20  -22
 [9,]  -30  -31
[10,]  -58  -94
```


The minus in front of the unit number indicates that this is a single observation being merged; 
whereas numbers alone indicate the step at which the considered clusters were built (check `??hclust`).


```r
plot(h.iris)
```

<img src="figure/unnamed-chunk-8.svg" title="plot of chunk unnamed-chunk-8" alt="plot of chunk unnamed-chunk-8" style="display: block; margin: auto;" />


What is an appropriate number of clusters according to this plot? A common choice is to cut the tree by the largest difference of heights between two nodes. The height values are contained in the output of hclust function: 


```r
h.iris.heights <- h.iris$height # height values
h.iris.heights[1:10]
```

```
 [1] 0.0000 0.1118 0.1118 0.1118 0.1118 0.1118 0.1581 0.1581 0.1581 0.1581
```

```r
subs <- round(h.iris.heights - c(0,h.iris.heights[-length(h.iris.heights)]), 3) # subtract next height
which.max(subs)
```

```
[1] 149
```


Since the largest jump was on the last step of the merging process, it suggests two clusters (herein, we know it is three).

Other fancy stuff
-------------


```r
# Cuts dendrogram at specified level and draws rectangles around the resulting clusters
plot(cluster); rect.hclust(cluster, k=5, border="red")
```

<img src="figure/unnamed-chunk-101.svg" title="plot of chunk unnamed-chunk-10" alt="plot of chunk unnamed-chunk-10" style="display: block; margin: auto;" />

```r
c <- cor(t(iris[,-5]), method="spearman"); 
d <- as.dist(1-c);
mycl  <- cutree(cluster, h=1);
subcl <- names(mycl[mycl==3]) # which observations are considered class 3
subd  <- as.dist(as.matrix(d)[subcl,subcl])
subhr <- hclust(subd, method = "complete")
source("http://faculty.ucr.edu/~tgirke/Documents/R_BioCond/My_R_Scripts/dendroCol.R") # Import tree coloring function.
# In this example the dendrogram for the above object is colored with the imported 'dendroCol()' function based on the identifiers provided in its 'keys' argument. If 'xPar' is set to 'nodePar' then the labels are colored instead of the leaves.
dend_colored <- dendrapply(as.dendrogram(cluster), dendroCol, keys=subcl, xPar="edgePar", bgr="red", fgr="blue", lwd=2, pch=20) 
par(mfrow = c(1, 3))
# Plots the colored tree in different formats. The last command shows how one can zoom into the tree with the 'xlim and ylim' arguments, which is possible since R 2.8.
plot(dend_colored, horiz=T)
plot(dend_colored, horiz=T, type="tr")
plot(dend_colored, horiz=T, edgePar=list(lwd=2), xlim=c(3,0), ylim=c(1,3)) 
```

<img src="figure/unnamed-chunk-102.svg" title="plot of chunk unnamed-chunk-10" alt="plot of chunk unnamed-chunk-10" style="display: block; margin: auto;" />

```r
par(mfrow = c(1, 1))
# This example shows how one can manually color tree elements.
z <- as.dendrogram(cluster)
attr(z[[2]][[2]],"edgePar") <- list(col="blue", lwd=4, pch=NA)
attr(z[[2]][[1]],"edgePar") <- list(col="red", lwd=3, lty=3, pch=NA)
plot(z, horiz=T) 
```

<img src="figure/unnamed-chunk-103.svg" title="plot of chunk unnamed-chunk-10" alt="plot of chunk unnamed-chunk-10" style="display: block; margin: auto;" />


Fuzzy C-Means
-------------

Unlike K-Means where each data point belongs to only one cluster, in fuzzy cmeans, each data point has a fraction of membership to each cluster. The goal is to figure out the membership fraction that minimize the expected distance to each centroid. Details [here](http://home.deib.polimi.it/matteucc/Clustering/tutorial_html/cmeans.html).

The parameter m is the degree of fuzziness. The output is the matrix with each data point assigned a degree of membership to each centroids.


```r
library(e1071)
result <- cmeans(iris[,-5], centers=3, iter.max=100, m=2, method="cmeans")  # 3 clusters
plot(iris[,1], iris[,2], col=result$cluster)
points(result$centers[,c(1,2)], col=1:3, pch=19, cex=2)
```

<img src="figure/unnamed-chunk-11.svg" title="plot of chunk unnamed-chunk-11" alt="plot of chunk unnamed-chunk-11" style="display: block; margin: auto;" />

```r
result$membership[1:5,] # degree of membership for each observation to each cluster:
```

```
          1        2        3
[1,] 0.9966 0.002304 0.001072
[2,] 0.9759 0.016651 0.007498
[3,] 0.9798 0.013760 0.006415
[4,] 0.9674 0.022467 0.010108
[5,] 0.9945 0.003762 0.001768
```

```r
table(iris$Species, result$cluster)
```

```
            
              1  2  3
  setosa     50  0  0
  versicolor  0 47  3
  virginica   0 13 37
```


Multi-Gaussian with Expectation-Maximization
--------------------------------------------

Generally in machine learning, we will to learn a set of parameters that maximize the likelihood of observing our training data. However, what if there are some hidden variable in our data that we haven't observed. Expectation Maximization is a very common technique to use the parameter to estimate the probability distribution of those hidden variable, compute the expected likelihood and then figure out the parameters that will maximize this expected likelihood. It can be explained as follows ...

<img src="p1.png" height="33%" width="33%">
<img src="p2.png" height="33%" width="33%"">


```r
library(mclust)
mc <- Mclust(iris[,1:4], 3)
summary(mc)
```

```
----------------------------------------------------
Gaussian finite mixture model fitted by EM algorithm 
----------------------------------------------------

Mclust VEV (ellipsoidal, equal shape) model with 3 components:

 log.likelihood   n df    BIC    ICL
         -186.1 150 38 -562.6 -566.5

Clustering table:
 1  2  3 
50 45 55 
```

```r
plot(mc, what=c("classification"), dimens=c(1,2))
```

<img src="figure/unnamed-chunk-121.svg" title="plot of chunk unnamed-chunk-12" alt="plot of chunk unnamed-chunk-12" style="display: block; margin: auto;" />

```r
plot(mc, what=c("classification"), dimens=c(3,4))
```

<img src="figure/unnamed-chunk-122.svg" title="plot of chunk unnamed-chunk-12" alt="plot of chunk unnamed-chunk-12" style="display: block; margin: auto;" />

```r
table(iris$Species, mc$classification)
```

```
            
              1  2  3
  setosa     50  0  0
  versicolor  0 45  5
  virginica   0  0 50
```


Density-based Cluster
--------------------

In density based cluster, a cluster is extend along the density distribution. 

Two parameters is important: "eps" defines the radius of neighborhood of each point, and "minpts" is the number of neighbors within my "eps" radius. 

The basic algorithm called DBscan proceeds as follows

1. First scan: For each point, compute the distance with all other points. Increment a neighbor count if it is smaller than "eps".
2. Second scan: For each point, mark it as a core point if its neighbor count is greater than "minpts"
3. Third scan: For each core point, if it is not already assigned a cluster, create a new cluster and assign that to this core point as well as all of its neighbors within "eps" radius.

Unlike other cluster, density based cluster can have some outliers (data points that doesn't belong to any clusters). On the other hand, it can detect cluster of arbitrary shapes (doesn't have to be circular at all).


```r
library(fpc)
set.seed(121)
sampleiris <- iris[sample(1:150, 40),] # get samples from iris dataset
# eps is radius of neighborhood, MinPts is no of neighbors within eps
cluster <- dbscan(sampleiris[,-5], eps=0.6, MinPts=4)
# black points are outliers, triangles are core points and circles are boundary points
plot(cluster, sampleiris)
```

<img src="figure/unnamed-chunk-131.svg" title="plot of chunk unnamed-chunk-13" alt="plot of chunk unnamed-chunk-13" style="display: block; margin: auto;" />

```r
plot(cluster, sampleiris[,c(1,4)])
```

<img src="figure/unnamed-chunk-132.svg" title="plot of chunk unnamed-chunk-13" alt="plot of chunk unnamed-chunk-13" style="display: block; margin: auto;" />

```r
# Notice points in cluster 0 are unassigned outliers
table(cluster$cluster, sampleiris$Species)
```

```
   
    setosa versicolor virginica
  0      0          4         5
  1      0          3         8
  2      0          6         0
  3     14          0         0
```


QT Clustering
--------------

Quality Control Clustering requires the threshold distance within the cluster and the minimum number of elements in each cluster. 

For each data point find all its candidate data points, ie, those which are within the range of the threshold distance from the given data point. This way we find the candidate data points for all data point and choose the one with large number of candidate data points to form a cluster. Now data points which belongs to this cluster is removed and the same procedure is repeated with the reduced set of data points until no more cluster can be formed satisfying the minimum size criteria.

Pros:
+ Quality Guaranteed - Only clusters that pass a user-defined quality threshold will be returned.
+ Number of clusters is not a parameter
+ All possible clusters are considered

Cons:
+ Computationally Intensive and Time Consuming - Increasing the minimum cluster size or increasing the number of data points can greatly increase the computational time.
+ Threshold distance and minimum number of elements in the cluster are parameters


```r
library(flexclust) 
cl1 <- qtclust(iris[,-5], radius=2) # Uses 2 as the maximum distance of the points to the cluster centers.
cl2 <- qtclust(iris[,-5], radius=1) # Uses 1 as the maximum distance of the points to the cluster centers.
par(mfrow=c(1,2))
plot(iris[,c(1,2)], col=predict(cl1), xlab="", ylab="")
plot(iris[,c(1,2)], col=predict(cl2), xlab="", ylab="")
```

<img src="figure/unnamed-chunk-14.svg" title="plot of chunk unnamed-chunk-14" alt="plot of chunk unnamed-chunk-14" style="display: block; margin: auto;" />

```r
par(mfrow=c(1,1))
table(attributes(cl1)$cluster, iris$Species) # not very good...
```

```
   
    setosa versicolor virginica
  1      0         49        44
  2     50          1         0
  3      0          0         6
```

```r
table(attributes(cl2)$cluster, iris$Species) 
```

```
   
    setosa versicolor virginica
  1      0         21        39
  2     48          0         0
  3      0         29         1
  4      0          0        10
```


Self-Organizing Map (SOM)
-------------------------

ref: [http://www.jstatsoft.org/v21/i05](http://www.jstatsoft.org/v21/i05)

Self-organizing map (SOM), also known as **Kohonen network**, is an  artificial neural network algorithm in the unsupervised learning area. The approach iteratively assigns all items in a data matrix to a specified number of representatives and then updates each representative by the mean of its assigned data points. Widely used R packages for SOM clustering and visualization are: class (part of R), SOM and kohonen.


```r
library(kohonen) 
set.seed(101)
train.obs <- sample(nrow(iris), 50) # get the training set observations
train.set <- scale(iris[train.obs,][,-5]) # check info about scaling data below
test.set  <- scale(iris[-train.obs, ][-5],
               center = attr(train.set, "scaled:center"),
               scale  = attr(train.set, "scaled:scale"))
som.iris <- som(train.set, grid = somgrid(5, 5, "hexagonal"))
plot(som.iris)
```

<img src="figure/unnamed-chunk-15.svg" title="plot of chunk unnamed-chunk-15" alt="plot of chunk unnamed-chunk-15" style="display: block; margin: auto;" />

```r
som.prediction <- 
  predict(som.iris, newdata = test.set,
          trainX = train.set,
          trainY = classvec2classmat(iris[,5][train.obs]))

table(iris[,5][-train.obs], som.prediction$prediction)
```

```
            
             setosa versicolor virginica
  setosa         31          0         0
  versicolor      0         27         5
  virginica       0          4        33
```


k-Nearest Neighbour
-------------------

ref: [http://en.wikibooks.org/wiki/Data_Mining_Algorithms_In_R/Classification/kNN](http://en.wikibooks.org/wiki/Data_Mining_Algorithms_In_R/Classification/kNN)

Loosely related is the k-Nearest Neighbour algorithm. This is a classification procedure without model training! 

Let s be a sample from the test set and I be the set of classified observations. Then:
+ Compute the distance between 's' and each instance in 'I'
+ Sort the distances in increasing numerical order and pick the first 'k' elements
+ Compute and return the most frequent class in the 'k' nearest neighbors, optionally weighting each instance's class by the inverse of its distance to 's'

We use the `kknn` package. The `kknn` function uses the [Minkowski Distance](http://en.wikipedia.org/wiki/Minkowski_distance) as its metric:

$$\Big( \sum_i |x_i - y_i|^p \Big)^{1/p}$$
is the distance between vectors $x = (x_1, x_2\ldots x_n)$ and $y = (y_1, y_2\ldots y_n)$.

When $p=2$ we have as a special case the Euclidean distanc, and when $p=1$ we have the Manhattan distance.


```r
library(kknn)
library(caret)

# make a dataset
inTrain   <- createDataPartition(y=iris$Species, p=0.75, list=FALSE) 
known.set <- iris[inTrain,]
test.set  <- iris[-inTrain,]

iris.kknn <- kknn(Species ~ ., known.set, test.set[,-5], 
                  distance = 1, k = 7, scale = TRUE,
                  kernel = "triangular") 
# the kernel param specifies how to weight the neighbors according to their distances 
# kernel = "rectangular" does not weight (check help for more options)

#here are some useful information from the returned object:
iris.kknn$prob[10:20,]
```

```
      setosa versicolor virginica
 [1,]      1     0.0000   0.00000
 [2,]      1     0.0000   0.00000
 [3,]      1     0.0000   0.00000
 [4,]      0     0.9166   0.08337
 [5,]      0     0.9632   0.03683
 [6,]      0     0.7727   0.22726
 [7,]      0     1.0000   0.00000
 [8,]      0     1.0000   0.00000
 [9,]      0     1.0000   0.00000
[10,]      0     1.0000   0.00000
[11,]      0     1.0000   0.00000
```

```r
iris.kknn$fitted.values
```

```
 [1] setosa     setosa     setosa     setosa     setosa     setosa    
 [7] setosa     setosa     setosa     setosa     setosa     setosa    
[13] versicolor versicolor versicolor versicolor versicolor versicolor
[19] versicolor versicolor versicolor versicolor versicolor versicolor
[25] virginica  virginica  virginica  virginica  virginica  virginica 
[31] virginica  virginica  virginica  virginica  virginica  virginica 
Levels: setosa versicolor virginica
```

```r

# Let's test the performance of the classification:
table(test.set$Species, fitted(iris.kknn))
```

```
            
             setosa versicolor virginica
  setosa         12          0         0
  versicolor      0         12         0
  virginica       0          0        12
```

```r
pairs(test.set[,-5], 
      pch = as.character(as.numeric(test.set$Species)), 
      col = c("green3", "red")[(test.set$Species != fit)+1])
```

```
Error: comparison (2) is possible only for atomic and list types
```


The package is also able to perform cross-validation:


```r
set.seed(101)
# 10-fol cross validation with k=7 neighbors
iris.cv <- simulation(Species ~ ., iris, runs=10, k=7, kernel="triangular")
iris.cv # 6% for the mean error with a sd of 2.4%
```

```
     misclassification
mean           0.06000
sd             0.02494
```

```r
# Another method for leave-one-out cross-validation
iris.cv2 <- train.kknn(Species ~ ., iris, nn=10, kernel="triangular")
plot(iris.cv2, type="b")
```

<img src="figure/unnamed-chunk-17.svg" title="plot of chunk unnamed-chunk-17" alt="plot of chunk unnamed-chunk-17" style="display: block; margin: auto;" />



Annex: Scaling datasets
======================


```r
# Sample data matrix.
set.seed(101)
y <- matrix(rnorm(100,20,5), 20, 5, 
            dimnames=list(paste0("g", 1:20), paste0("t", 1:5))) 
head(y)
```

```
      t1    t2     t3    t4    t5
g1 18.37 19.18 22.412 18.70 29.26
g2 22.76 23.54 23.791 12.94 25.56
g3 16.63 18.66  8.403 16.79 17.44
g4 21.07 12.68 17.702 20.56 17.28
g5 21.55 23.72 14.473 22.11 11.36
g6 25.87 12.95 22.015 21.93 22.35
```

```r
apply(y,2,mean) # check mean and sd of each column
```

```
   t1    t2    t3    t4    t5 
19.51 19.97 18.84 19.60 21.15 
```

```r
apply(y,2,sd)
```

```
   t1    t2    t3    t4    t5 
4.334 4.865 4.869 4.525 4.896 
```


We use the function `scale()` to centers and/or scales the data. In its default settings, the function returns columns that have a mean close to zero and a standard deviation of one.

To scale matrix `m` by rows use `t(scale(t(m)))`


```r
apply(scale(y,scale=FALSE),2,mean) # just centers, sd remains
```

```
        t1         t2         t3         t4         t5 
-1.599e-15 -8.882e-16  4.441e-16 -1.688e-15  1.421e-15 
```

```r
apply(scale(y,scale=FALSE),2,sd)
```

```
   t1    t2    t3    t4    t5 
4.334 4.865 4.869 4.525 4.896 
```

```r
yscaled.cols <- scale(y)     # scale and center columns
yscaled.cols
```

```
          t1      t2       t3        t4       t5
g1  -0.26387 -0.1631  0.73446 -0.198648  1.65733
g2   0.74964  0.7333  1.01761 -1.471018  0.90115
g3  -0.66640 -0.2702 -2.14244 -0.620302 -0.75635
g4   0.35958 -1.4993 -0.23276  0.212732 -0.78955
g5   0.47081  0.7702 -0.89595  0.555473 -1.99974
g6   1.46667 -1.4443  0.65280  0.515945  0.24662
g7   0.82617  0.4852  0.82326 -0.671623 -0.22862
g8  -0.01779 -0.1175 -0.48594  0.253008  1.14253
g9   1.17024  0.4854 -0.05880  0.024748  0.50534
g10 -0.14530  0.5171 -1.28459  0.005770  1.35138
g11  0.71963  0.9249 -0.94203  1.757031  1.11948
g12 -0.80473  0.2921 -0.04276  1.878635 -0.26911
g13  1.75946  1.0410  0.83246  1.362802 -0.60280
g14 -1.57998 -2.1254 -1.19529  0.002698 -0.96957
g15 -0.16079  1.2280  1.00821 -1.921632  0.05388
g16 -0.11078 -0.7393 -0.84030 -1.058014 -1.04142
g17 -0.86808  0.1778  0.40888  0.422738 -0.68847
g18  0.17973  0.9510  1.39917 -1.323790  1.15984
g19 -0.83106 -1.7128  1.44426  0.241334  0.27389
g20 -2.25314  0.4661 -0.20027  0.032115 -1.06580
attr(,"scaled:center")
   t1    t2    t3    t4    t5 
19.51 19.97 18.84 19.60 21.15 
attr(,"scaled:scale")
   t1    t2    t3    t4    t5 
4.334 4.865 4.869 4.525 4.896 
```

```r
apply(yscaled.cols, 2, mean) # should be zero (or close)
```

```
        t1         t2         t3         t4         t5 
-3.809e-16 -1.901e-16  1.093e-16 -3.824e-16  2.914e-16 
```

```r
apply(yscaled.cols, 2, sd)   # should be one
```

```
t1 t2 t3 t4 t5 
 1  1  1  1  1 
```

```r
yscaled.rows <- t(scale(t(y))) # scale and center rows
yscaled.rows
```

```
          t1      t2       t3       t4       t5
g1  -0.70147 -0.5244  0.18049 -0.62922  1.67464
g2   0.20806  0.3638  0.41335 -1.75121  0.76603
g3   0.25413  0.7512 -1.75441  0.29515  0.45392
g4   0.95978 -1.5474 -0.04692  0.80755 -0.17297
g5   0.53856  0.9398 -0.77174  0.64204 -1.34867
g6   1.00887 -1.6814  0.20623  0.18948  0.27683
g7   0.77188  0.4959  0.68119 -1.60498 -0.34398
g8  -0.29590 -0.3046 -1.07797  0.04895  1.62950
g9   1.10201  0.2246 -1.25283 -0.79938  0.72564
g10 -0.25024  0.4015 -1.38905 -0.11615  1.35398
g11 -0.08935  0.2578 -1.66880  0.83706  0.66333
g12 -1.05284  0.1325 -0.47852  1.61228 -0.21341
g13  0.95433  0.3532 -0.26231  0.56122 -1.60646
g14 -0.41752 -1.2088 -0.32627  1.39562  0.55698
g15 -0.23183  0.9942  0.61535 -1.59167  0.21396
g16  1.62544  0.1005 -0.83798 -0.79851 -0.08946
g17 -1.45035  0.6055  0.60023  0.87719 -0.63255
g18 -0.35272  0.4459  0.63996 -1.59100  0.85788
g19 -0.60886 -1.3715  1.16970  0.24497  0.56571
g20 -1.55575  1.0865  0.15983  0.55834 -0.24889
attr(,"scaled:center")
   g1    g2    g3    g4    g5    g6    g7    g8    g9   g10   g11   g12 
21.59 21.72 15.59 17.86 18.64 21.02 20.97 20.56 21.76 20.27 23.11 20.80 
  g13   g14   g15   g16   g17   g18   g19   g20 
23.81 14.27 20.17 16.20 19.34 22.20 19.32 17.10 
attr(,"scaled:scale")
   g1    g2    g3    g4    g5    g6    g7    g8    g9   g10   g11   g12 
4.584 5.011 4.093 3.347 5.404 4.803 2.749 3.793 2.563 5.535 5.308 4.530 
  g13   g14   g15   g16   g17   g18   g19   g20 
3.493 3.831 5.818 1.741 2.475 5.396 5.598 4.729 
```

```r
apply(yscaled.rows, 1, mean) # should be zero (or close)
```

```
        g1         g2         g3         g4         g5         g6 
-1.665e-17 -1.499e-16  1.887e-16  6.939e-18  2.665e-16  2.776e-17 
        g7         g8         g9        g10        g11        g12 
-5.218e-16 -1.790e-16  5.329e-16  1.970e-16  2.637e-16 -3.164e-16 
       g13        g14        g15        g16        g17        g18 
-1.999e-16  1.777e-16 -4.994e-17  6.162e-16  1.110e-16  4.441e-17 
       g19        g20 
 1.110e-16 -1.721e-16 
```

```r
apply(yscaled.rows, 1, sd)   # should be one
```

```
 g1  g2  g3  g4  g5  g6  g7  g8  g9 g10 g11 g12 g13 g14 g15 g16 g17 g18 
  1   1   1   1   1   1   1   1   1   1   1   1   1   1   1   1   1   1 
g19 g20 
  1   1 
```

