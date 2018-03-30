---
editor_options: 
  chunk_output_type: console
---

## Eliminate the Time Dimension

Because changes to NDVI at each pixel follow a similar pattern over the course of a year, the slices are highly correlated. Consider representing the NDVI values as a simple matrix with

- each time slice as a variable
- each pixel as an observation

PCA is a technique for reducing dimensionality of a dataset based on correlation
between variables. The method proceeds either by eigenvalue decomposition of a
covariance matrix or singular-value decomposition of the entire dataset.
{:.notes}

===

To perform PCA on raster data, it's efficient to use specialized tools that calculate a covariance matrix without reading in that big data matrix.


~~~r
ndvi_layerStats <- layerStats(ndvi, 'cov', na.rm = TRUE)
ndvi_mean <- ndvi_layerStats[['mean']]
ndvi_cov <- ndvi_layerStats[['covariance']]
ndvi_cor <- cov2cor(ndvi_cov)
~~~
{:.text-document title="{{ site.handouts[0] }}"}


===

The `layerStats` function only evaluates standard statistical summaries. The `calc` function however can apply user defined functions over or across raster layers.


~~~r
ndvi_std <- sqrt(diag(ndvi_cov))
ndvi_stdz <- calc(ndvi,
  function(x) (x - ndvi_mean) / ndvi_std,
  filename = 'output/ndvi_stdz.grd',
  overwrite = TRUE)
~~~
{:.text-document title="{{ site.handouts[0] }}"}


===

Standardizing the data removes the large seasonal swing, but not the correlation between "variables", i.e. between pixels in different time slices. Only the correlation matters for PCA.


~~~r
animate(ndvi_stdz, pause = 0.5, n = 1)
~~~
{:.input}

![plot of chunk unnamed-chunk-3]({{ site.baseurl }}/images/unnamed-chunk-3-1.png)![plot of chunk unnamed-chunk-3]({{ site.baseurl }}/images/unnamed-chunk-3-2.png)![plot of chunk unnamed-chunk-3]({{ site.baseurl }}/images/unnamed-chunk-3-3.png)![plot of chunk unnamed-chunk-3]({{ site.baseurl }}/images/unnamed-chunk-3-4.png)![plot of chunk unnamed-chunk-3]({{ site.baseurl }}/images/unnamed-chunk-3-5.png)![plot of chunk unnamed-chunk-3]({{ site.baseurl }}/images/unnamed-chunk-3-6.png)![plot of chunk unnamed-chunk-3]({{ site.baseurl }}/images/unnamed-chunk-3-7.png)![plot of chunk unnamed-chunk-3]({{ site.baseurl }}/images/unnamed-chunk-3-8.png)![plot of chunk unnamed-chunk-3]({{ site.baseurl }}/images/unnamed-chunk-3-9.png)![plot of chunk unnamed-chunk-3]({{ site.baseurl }}/images/unnamed-chunk-3-10.png)![plot of chunk unnamed-chunk-3]({{ site.baseurl }}/images/unnamed-chunk-3-11.png)![plot of chunk unnamed-chunk-3]({{ site.baseurl }}/images/unnamed-chunk-3-12.png)![plot of chunk unnamed-chunk-3]({{ site.baseurl }}/images/unnamed-chunk-3-13.png)![plot of chunk unnamed-chunk-3]({{ site.baseurl }}/images/unnamed-chunk-3-14.png)![plot of chunk unnamed-chunk-3]({{ site.baseurl }}/images/unnamed-chunk-3-15.png)![plot of chunk unnamed-chunk-3]({{ site.baseurl }}/images/unnamed-chunk-3-16.png)![plot of chunk unnamed-chunk-3]({{ site.baseurl }}/images/unnamed-chunk-3-17.png)![plot of chunk unnamed-chunk-3]({{ site.baseurl }}/images/unnamed-chunk-3-18.png)![plot of chunk unnamed-chunk-3]({{ site.baseurl }}/images/unnamed-chunk-3-19.png)![plot of chunk unnamed-chunk-3]({{ site.baseurl }}/images/unnamed-chunk-3-20.png)![plot of chunk unnamed-chunk-3]({{ site.baseurl }}/images/unnamed-chunk-3-21.png)![plot of chunk unnamed-chunk-3]({{ site.baseurl }}/images/unnamed-chunk-3-22.png)![plot of chunk unnamed-chunk-3]({{ site.baseurl }}/images/unnamed-chunk-3-23.png)
{:.captioned}


===

Now, the principal component calculation proceeds using the NDVI correlations,
which is just a 23 by 23 matrix of pairwise correlations between the 23 time
slices. The plot method of the output shows the variance among pixels, not at
each time slice, but on each principal component.


~~~r
pca <- princomp(covmat = ndvi_cor)
plot(pca)
~~~
{:.text-document title="{{ site.handouts[0] }}"}

![plot of chunk unnamed-chunk-4]({{ site.baseurl }}/images/unnamed-chunk-4-1.png)
{:.captioned}


===

Principal component "loadings" correspond to the weight each time slice
contributes to each component. The first principal component is a more-or-less
equally weighted combination of all time slices, like an average.


~~~r
npc <- 4
loading <- data.frame(
  Date = rep(dates, npc), 
  PC = factor(rep(1:npc, each = length(dates))),
  Loading = c(pca$loadings[, 1:npc])
)
~~~
{:.text-document title="{{ site.handouts[0] }}"}


===


~~~r
ggplot(loading, aes(
  x = Date, y = Loading, col = PC)) +
  geom_line()
~~~
{:.text-document title="{{ site.handouts[0] }}"}

![plot of chunk unnamed-chunk-6]({{ site.baseurl }}/images/unnamed-chunk-6-1.png)
{:.captioned}


===

The principal component scores are a projection of the NDVI values at each time
point onto the components. The calculation is matrix multiplation on the NDVI
time-series, which you may not be able to do in memory. The [raster](){:.rlib}
package `predict` wrapper carries the PCA output's `predict` method through to
the time series for each pixel.


~~~r
pca$center <- pca$scale * 0
ndvi_scores <- predict(
  ndvi_stdz, pca,
  index = 1:npc,
  filename = 'output/ndvi_scores.grd',
  overwrite = TRUE)
plot(ndvi_scores)
~~~
{:.text-document title="{{ site.handouts[0] }}"}

![plot of chunk unnamed-chunk-7]({{ site.baseurl }}/images/unnamed-chunk-7-1.png)
{:.captioned}


A complication in here is that the `pca` object does not know how the original
data were centered, because we didn't give it the original data. The `predict`
function will behave as if we performed PCA on `ndvi_stdz[]` if we set the
centering vector to zeros.
{:.notes}

===

The first several principal components account for most of the variance in the
data, so approximate the NDVI time series by "un-projecting" the scores.

Mathematically, the calculation for this approximation at each time slice,
$\bm{X_t}$, is a linear combination of each score "map", $\bm{T}_i$, with
time-varying loadings, $\W_{i,t}$.
{:.notes}

$$
\bm{X}_t \sim= W_{1,t}*\bm{T}_1 + W_{2,t}*\bm{T}_2 + W_{3,t}*\bm{T}_3 + \hdots
$$

===

The flexible `overlay` function allows you to pass a custom function for pixel-wise calculations
on one or more of the main raster objects.


~~~r
ndvi_dev <- overlay(
  ndvi_stdz, ndvi_scores,
  fun = function(x, y) x - y %*% t(pca$loadings[, 1:npc]),
  filename = 'output/ndvi_dev.grd',
  overwrite = TRUE)
names(ndvi_dev) <- names(ndvi)
~~~
{:.text-document title="{{ site.handouts[0] }}"}


===

Verify that the deviations just calculated are never very large, then try the
same approximation using even fewer principal components.


~~~r
animate(ndvi_dev, pause = 0.5, n = 1)
~~~
{:.input}

![plot of chunk unnamed-chunk-9]({{ site.baseurl }}/images/unnamed-chunk-9-1.png)![plot of chunk unnamed-chunk-9]({{ site.baseurl }}/images/unnamed-chunk-9-2.png)![plot of chunk unnamed-chunk-9]({{ site.baseurl }}/images/unnamed-chunk-9-3.png)![plot of chunk unnamed-chunk-9]({{ site.baseurl }}/images/unnamed-chunk-9-4.png)![plot of chunk unnamed-chunk-9]({{ site.baseurl }}/images/unnamed-chunk-9-5.png)![plot of chunk unnamed-chunk-9]({{ site.baseurl }}/images/unnamed-chunk-9-6.png)![plot of chunk unnamed-chunk-9]({{ site.baseurl }}/images/unnamed-chunk-9-7.png)![plot of chunk unnamed-chunk-9]({{ site.baseurl }}/images/unnamed-chunk-9-8.png)![plot of chunk unnamed-chunk-9]({{ site.baseurl }}/images/unnamed-chunk-9-9.png)![plot of chunk unnamed-chunk-9]({{ site.baseurl }}/images/unnamed-chunk-9-10.png)![plot of chunk unnamed-chunk-9]({{ site.baseurl }}/images/unnamed-chunk-9-11.png)![plot of chunk unnamed-chunk-9]({{ site.baseurl }}/images/unnamed-chunk-9-12.png)![plot of chunk unnamed-chunk-9]({{ site.baseurl }}/images/unnamed-chunk-9-13.png)![plot of chunk unnamed-chunk-9]({{ site.baseurl }}/images/unnamed-chunk-9-14.png)![plot of chunk unnamed-chunk-9]({{ site.baseurl }}/images/unnamed-chunk-9-15.png)![plot of chunk unnamed-chunk-9]({{ site.baseurl }}/images/unnamed-chunk-9-16.png)![plot of chunk unnamed-chunk-9]({{ site.baseurl }}/images/unnamed-chunk-9-17.png)![plot of chunk unnamed-chunk-9]({{ site.baseurl }}/images/unnamed-chunk-9-18.png)![plot of chunk unnamed-chunk-9]({{ site.baseurl }}/images/unnamed-chunk-9-19.png)![plot of chunk unnamed-chunk-9]({{ site.baseurl }}/images/unnamed-chunk-9-20.png)![plot of chunk unnamed-chunk-9]({{ site.baseurl }}/images/unnamed-chunk-9-21.png)![plot of chunk unnamed-chunk-9]({{ site.baseurl }}/images/unnamed-chunk-9-22.png)![plot of chunk unnamed-chunk-9]({{ site.baseurl }}/images/unnamed-chunk-9-23.png)
{:.captioned}


===

Based on the time variation in the loadings for principal components 2 and 3, we
might guess that they correspond to one longer-term and one shorter-term departure from
the seasonal NDVI variation within this extent.


~~~r
plot(ndvi_scores[[2]] < -2 | ndvi_scores[[3]] < -2)
plot(st_geometry(scar), add = TRUE)
~~~
{:.text-document title="{{ site.handouts[0] }}"}

![plot of chunk unnamed-chunk-10]({{ site.baseurl }}/images/unnamed-chunk-10-1.png)
{:.captioned}

