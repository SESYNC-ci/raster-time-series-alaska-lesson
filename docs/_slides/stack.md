---
editor_options: 
  chunk_output_type: console
---

## Raster upon Raster

The [raster](){:.rlib} library uniformly handles two-dimensional data as a
`RasterLayer` object, created with the `raster()` function. There are several
cases where raster data has a third dimension.

- a multi-band image (e.g. Landsat scenes)
- closely related images (e.g. time series of NDVI values)
- three dimensional data (e.g. GCM products)

===

Any `RasterLayer` objects that have the same extent and resolution (i.e. cover
the same space with the same number of rows and columns) can be combined into
one of two container types:

- a `RasterStack` created with `stack()`
- a `RasterBrick` created with `brick()`

===

## Raster Stacks

The layers of a "stack" can refer to data from separate files, or even a mix of
data on disk and data in memory.


~~~r
ndvi_yrly <- Sys.glob('data/r_ndvi_*.tif')
~~~
{:.text-document title="{{ site.handouts[0] }}"}


~~~r
ndvi_yrly
~~~
{:.input}

~~~
[1] "data/r_ndvi_2001_2009_filling6__STA_year2_Amplitude0.tif"
[2] "data/r_ndvi_2001_2009_filling6__STA_year9_Amplitude0.tif"
~~~
{:.output}


===


~~~r
ndvi <- stack(ndvi_yrly)
names(ndvi) <- c(
  'Avg NDVI 2002',
  'Avg NDVI 2009')
~~~
{:.text-document title="{{ site.handouts[0] }}"}


~~~r
plot(ndvi)
~~~
{:.input}

![plot of chunk unnamed-chunk-4]({{ site.baseurl }}/images/unnamed-chunk-4-1.png)
{:.captioned}


===

The data source for the first layer is the first file in the list. Note that the
CRS is missing: it is quite possible to stack files with different
projections. They only have to share a common extent and resolution.


~~~r
raster(ndvi, 1)
~~~
{:.input}

~~~
class       : RasterLayer 
dimensions  : 1951, 2441, 4762391  (nrow, ncol, ncell)
resolution  : 1000.045, 999.9567  (x, y)
extent      : -930708.7, 1510401, 454027.3, 2404943  (xmin, xmax, ymin, ymax)
coord. ref. : NA 
data source : /nfs/public-data/training/r_ndvi_2001_2009_filling6__STA_year2_Amplitude0.tif 
names       : Avg.NDVI.2002 
values      : -0.3, 0.8713216  (min, max)
~~~
{:.output}


===

Set the CRS using the [EPSG code
3338](http://spatialreference.org/ref/epsg/nad83-alaska-albers/) for an Albers
Equal Area projection of Alaska using the NAD38 datum.


~~~r
crs(ndvi) <- '+init=epsg:3338'
~~~
{:.text-document title="{{ site.handouts[0] }}"}


~~~r
raster(ndvi, 0)
~~~
{:.input}

~~~
class       : RasterLayer 
dimensions  : 1951, 2441, 4762391  (nrow, ncol, ncell)
resolution  : 1000.045, 999.9567  (x, y)
extent      : -930708.7, 1510401, 454027.3, 2404943  (xmin, xmax, ymin, ymax)
coord. ref. : +init=epsg:3338 +proj=aea +lat_1=55 +lat_2=65 +lat_0=50 +lon_0=-154 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs +ellps=GRS80 +towgs84=0,0,0 
~~~
{:.output}


===

The `ndvi` object only takes up a tiny amount of memory. The pixel values
take up much more space on disk, as you can see in the file browser.


~~~r
print(object.size(ndvi),
  units = 'KB',
  standard = 'SI')
~~~
{:.input}

~~~
29.6 kB
~~~
{:.output}


===

Why so small? The `ndvi` object is only metadata and a pointer to where the
pixel values are saved on disk.


~~~r
inMemory(ndvi)
~~~
{:.input}

~~~
[1] FALSE
~~~
{:.output}


Whereas `read.csv()` would load the named file into memory, the [raster](){:.rlib} library handles files like a database where
possible. The values can be accessed, to make those plots for example, but are
not held in memory. This is the key to working with deep stacks of large rasters.
{:.notes}

===

## Wildfires in Alaska

Many and massive wildfires burned in Alaska and the Yukon between 2001 and 2009.
Three large fires that burned during this period (their locations are in a
shapefile) occured within boreal forest areas of central Alaska.


~~~r
import('sf', 'read_sf', 'st_geometry',
  'st_bbox')
scar <- read_sf(
  'data/OVERLAY_ID_83_399_144_TEST_BURNT_83_144_399_reclassed',
  crs = 3338)
plot(ndvi[[1]])
plot(st_geometry(scar), add = TRUE)
~~~
{:.text-document title="{{ site.handouts[0] }}"}

![plot of chunk unnamed-chunk-10]({{ site.baseurl }}/images/unnamed-chunk-10-1.png)
{:.captioned}


===

For faster processing in this lesson, crop the NDVI imagery to the smaller extent of the shapefile.


~~~r
burn_bbox <- extent(matrix(st_bbox(scar), 2))
ndvi <- crop(ndvi, burn_bbox)
~~~
{:.text-document title="{{ site.handouts[0] }}"}


~~~r
plot(ndvi[[1]], ext = burn_bbox)
plot(st_geometry(scar), add = TRUE)
~~~
{:.input}

![plot of chunk unnamed-chunk-12]({{ site.baseurl }}/images/unnamed-chunk-12-1.png)
{:.captioned}


===

Notice, however, that the NDVI values are now stored in memory. That's okay for this part of the lesson; we'll see the alternative shortly.


~~~r
inMemory(ndvi)
~~~
{:.input}

~~~
[1] TRUE
~~~
{:.output}


===

## Pixel Change

Use element-wise subtration to give a difference raster, where negative values
indicate a higher NDVI in 2002, or a decrease in NDVI from 2002 to 2009.


~~~r
diff_ndvi <- ndvi[[2]] - ndvi[[1]]
names(diff_ndvi) <- 'Difference'
~~~
{:.text-document title="{{ site.handouts[0] }}"}


~~~r
plot(diff_ndvi)
~~~
{:.input}

![plot of chunk unnamed-chunk-15]({{ site.baseurl }}/images/unnamed-chunk-15-1.png)
{:.captioned}


===

The histogram shows clearly that change in NDVI within this corner of Alaska clusters around two modes.


~~~r
hist(diff_ndvi)
~~~
{:.input}

![plot of chunk unnamed-chunk-16]({{ site.baseurl }}/images/unnamed-chunk-16-1.png)
{:.captioned}


===

One way to "classify" pixels as potentially affected by wildfire is to threshold
the differrence. Pixels below "-0.1" mostly belong to the smaller mode, and may
represent impacts of wildfire.


~~~r
plot(diff_ndvi < -0.1)
plot(st_geometry(scar), add = TRUE)
~~~
{:.input}

![plot of chunk unnamed-chunk-17]({{ site.baseurl }}/images/unnamed-chunk-17-1.png)
{:.captioned}


===

The threshold value could also be defined in terms of the variability among
pixels.

Centering and scaling the pixel values requires computation of their
mean and standard variation. The `cellStats` function efficiently applies a few
common functions across large rasters, regardless of whether the values are in
memory or on disk.
{:.notes}


~~~r
diff_ndvi_mean <- cellStats(diff_ndvi, 'mean')
diff_ndvi_sd <- cellStats(diff_ndvi, 'sd')
~~~
{:.text-document title="{{ site.handouts[0] }}"}


===

Mathematical operations with rasters and scalars work as expected; scalar
values are repeated for each cell in the array.
{:.notes}

The difference threshold of "-0.1" appears roughly equivalent to a threshold of
1 standard deviation below zero.


~~~r
diff_ndvi_stdz <- (diff_ndvi - diff_ndvi_mean) / diff_ndvi_sd
names(diff_ndvi_stdz) <- 'Standardized Difference'
~~~
{:.text-document title="{{ site.handouts[0] }}"}


~~~r
hist(diff_ndvi_stdz, breaks = 20)
~~~
{:.input}

![plot of chunk unnamed-chunk-20]({{ site.baseurl }}/images/unnamed-chunk-20-1.png)
{:.captioned}


===

Standardizing the pixel values does not change the overal result.


~~~r
plot(diff_ndvi_stdz < -1)
plot(st_geometry(scar), add = TRUE)
~~~
{:.input}

![plot of chunk unnamed-chunk-21]({{ site.baseurl }}/images/unnamed-chunk-21-1.png)
{:.captioned}

