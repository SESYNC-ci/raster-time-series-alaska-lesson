---
editor_options: 
  chunk_output_type: console
---

## Raster Time Series

To understand changes in average NDVI between 2002 and 2009, take a closer look
using NDVI products covering 16 day periods in 2005. These images are stored as
separate files on disk, all having the same extent and resolution.


~~~r
ndvi_16day <- Sys.glob('data/NDVI_alaska_2005/*.tif')
ndvi <- stack(ndvi_16day)
crs(ndvi) <- '+init=epsg:3338'
~~~
{:.text-document title="{{ site.handouts[0] }}"}

===


~~~r
dates <- as.Date(sub('alaska_NDVI_', '', names(ndvi)), '%Y_%m_%d')
names(ndvi) <- format(dates, '%b %d %Y')
~~~
{:.text-document title="{{ site.handouts[0] }}"}


~~~r
plot(subset(ndvi, 1:2))
~~~
{:.input}

![plot of chunk unnamed-chunk-3]({{ site.baseurl }}/images/unnamed-chunk-3-1.png)
{:.captioned}

## Raster Bricks

A `RasterBrick` representation of tightly integrated raster layers, such as a
time series of remote sensing data from sequential overflights, has advantages
for speed but limitations on flexibility.

A `RasterStack` is more flexible because it can mix values stored on disk with those in memory. Adding a layer of in-memory values to a RasterBrick causes the entire brick to be loaded into memory, which may not be possible given the available memory.
{:.notes}

===

For training purposes, again crop the NDVI data to the bounding box of the wildfires shapefile. But this time, avoid reading the values into memory.


~~~r
ndvi <- crop(ndvi, burn_bbox,
  filename = 'output/crop_alask_ndvi.grd',
  overwrite = TRUE)
~~~
{:.text-document title="{{ site.handouts[0] }}"}

Notice that `crop` creates a `RasterBrick`. In fact, we have been working with a `RasterBrick` in memory since first using `crop`.


~~~r
ndvi
~~~
{:.input}
~~~
class       : RasterBrick 
dimensions  : 74, 151, 11174, 23  (nrow, ncol, ncell, nlayers)
resolution  : 1000.045, 999.9566  (x, y)
extent      : 68336.16, 219342.9, 1772970, 1846967  (xmin, xmax, ymin, ymax)
coord. ref. : +init=epsg:3338 +proj=aea +lat_1=55 +lat_2=65 +lat_0=50 +lon_0=-154 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs +ellps=GRS80 +towgs84=0,0,0 
data source : /research-home/icarroll/training/raster-time-series-alaska-lesson/output/crop_alask_ndvi.grd 
names       : Jan.01.2005, Jan.17.2005, Feb.02.2005, Feb.18.2005, Mar.06.2005, Mar.22.2005, Apr.07.2005, Apr.23.2005, May.09.2005, May.25.2005, Jun.10.2005, Jun.26.2005, Jul.12.2005, Jul.28.2005, Aug.13.2005, ... 
min values  :    -0.19518,    -0.20000,    -0.19900,    -0.18050,    -0.12120,    -0.09540,    -0.03910,    -0.11290,    -0.09390,    -0.15520,    -0.18400,    -0.16780,    -0.18000,    -0.17200,    -0.18600, ... 
max values  :   0.3337000,   0.3633000,   0.4949000,   0.3514000,   0.4898000,   0.7274000,   0.6268000,   0.5879000,   0.9076000,   0.9190000,   0.8807000,   0.9625000,   0.8810000,   0.9244000,   0.9493000, ... 
~~~
{:.output}

===

## So many data

The immediate challenge is trying to represent the data in ways we can explore
and interpret the characteristics of wildfire visible by remote sensing.


~~~r
animate(ndvi, pause = 0.5, n = 1)
~~~
{:.input}

![plot of chunk unnamed-chunk-6]({{ site.baseurl }}/images/unnamed-chunk-6-1.png)![plot of chunk unnamed-chunk-6]({{ site.baseurl }}/images/unnamed-chunk-6-2.png)![plot of chunk unnamed-chunk-6]({{ site.baseurl }}/images/unnamed-chunk-6-3.png)![plot of chunk unnamed-chunk-6]({{ site.baseurl }}/images/unnamed-chunk-6-4.png)![plot of chunk unnamed-chunk-6]({{ site.baseurl }}/images/unnamed-chunk-6-5.png)![plot of chunk unnamed-chunk-6]({{ site.baseurl }}/images/unnamed-chunk-6-6.png)![plot of chunk unnamed-chunk-6]({{ site.baseurl }}/images/unnamed-chunk-6-7.png)![plot of chunk unnamed-chunk-6]({{ site.baseurl }}/images/unnamed-chunk-6-8.png)![plot of chunk unnamed-chunk-6]({{ site.baseurl }}/images/unnamed-chunk-6-9.png)![plot of chunk unnamed-chunk-6]({{ site.baseurl }}/images/unnamed-chunk-6-10.png)![plot of chunk unnamed-chunk-6]({{ site.baseurl }}/images/unnamed-chunk-6-11.png)![plot of chunk unnamed-chunk-6]({{ site.baseurl }}/images/unnamed-chunk-6-12.png)![plot of chunk unnamed-chunk-6]({{ site.baseurl }}/images/unnamed-chunk-6-13.png)![plot of chunk unnamed-chunk-6]({{ site.baseurl }}/images/unnamed-chunk-6-14.png)![plot of chunk unnamed-chunk-6]({{ site.baseurl }}/images/unnamed-chunk-6-15.png)![plot of chunk unnamed-chunk-6]({{ site.baseurl }}/images/unnamed-chunk-6-16.png)![plot of chunk unnamed-chunk-6]({{ site.baseurl }}/images/unnamed-chunk-6-17.png)![plot of chunk unnamed-chunk-6]({{ site.baseurl }}/images/unnamed-chunk-6-18.png)![plot of chunk unnamed-chunk-6]({{ site.baseurl }}/images/unnamed-chunk-6-19.png)![plot of chunk unnamed-chunk-6]({{ site.baseurl }}/images/unnamed-chunk-6-20.png)![plot of chunk unnamed-chunk-6]({{ site.baseurl }}/images/unnamed-chunk-6-21.png)![plot of chunk unnamed-chunk-6]({{ site.baseurl }}/images/unnamed-chunk-6-22.png)![plot of chunk unnamed-chunk-6]({{ site.baseurl }}/images/unnamed-chunk-6-23.png)
{:.captioned}

===

## Pixel Time Series

Verify that something happened very abruptly (fire!?) by plotting the time
series at pixels corresponding to locations with dramatic NDVI variation in the
layer from Aug 13, 2005.


~~~r
idx <- match('Aug.13.2005', names(ndvi))
plot(ndvi[[idx]])
~~~
{:.text-document title="{{ site.handouts[0] }}"}

![plot of chunk unnamed-chunk-7]({{ site.baseurl }}/images/unnamed-chunk-7-1.png)
{:.captioned}

===


~~~r
pixel <- click(ndvi[[idx]], cell = TRUE)
~~~
{:.input}

~~~r
pixel
~~~
{:.input}
~~~
Error in eval(expr, envir, enclos): object 'pixel' not found
~~~
{:.output}

===

"Hard code" these pixel values into your worksheet


~~~r
pixel <- c(2813, 3720, 2823, 4195, 9910)
scar_pixel <- data.frame(
  Date = rep(dates, each = length(pixel)),
  cell = rep(pixel, length(dates)),
  Type = 'burn scar?',
  NDVI = c(ndvi[pixel]))
~~~
{:.text-document title="{{ site.handouts[0] }}"}

===

Repeat the selection with `click` for "normal" looking pixels.


~~~r
pixel <- c(1710, 4736, 7374, 1957, 750)
normal_pixel <- data.frame(
  Date = rep(dates, each = length(pixel)),
  cell = rep(pixel, length(dates)),
  Type = 'normal',
  NDVI = c(ndvi[pixel]))
~~~
{:.text-document title="{{ site.handouts[0] }}"}

===

Join your haphazard samples together for comparison as time series.


~~~r
import('ggplot2', 'ggplot', 'aes', 'geom_line')
pixel <- rbind(normal_pixel, scar_pixel)
ggplot(pixel,
  aes(x = Date, y = NDVI,
    group = cell, col = Type)) +
  geom_line()
~~~
{:.text-document title="{{ site.handouts[0] }}"}

![plot of chunk unnamed-chunk-12]({{ site.baseurl }}/images/unnamed-chunk-12-1.png)
{:.captioned}

===

## Zonal Averages

Cannot very well analyze the time series for every pixel, so we have to reduce
the dimensionality of the data. One way is to summarize it by "zones" defined by
another spatial data source.


~~~r
?zonal
~~~
{:.input}

Currently we have raster data (`ndvi`) and vector data (`scar`). In order to
aggregate by polygon, we have to join these two datasets. There are two
approaches. 1) Treat the raster data as POINT geometries in a table and perform
a spatial join to the table with POLYGON geometries. 2) Turn the polygons into a
raster and summarize the raster masked for each polygon. Let's persue option 2, but take a shortcut due to the presence of invalid geometries in the shapefile.
{:.notes}

===

Typically we could convert simple features to raster with the `rasterize` function, but not all geometries are well defined.


~~~r
# Does not work, due to invalid geometries.
scar_geom <- as(st_geometry(scar), 'Spatial')
scar_zone <- rasterize(scar_geom, ndvi,
  background = 0,
  filename = 'output/scar.grd',
  overwrite = TRUE)
~~~
{:.input}

===


~~~r
sf::st_is_valid(scar, reason = TRUE)
~~~
{:.input}
~~~
[1] "Self-intersection[209342.453857422 1824967.88427734]"
[2] "Self-intersection[181341.197753906 1775970.00769043]"
[3] "Nested shells[75336.4425048828 1815968.27429199]"    
~~~
{:.output}

===

Fortuantely, we have the rasterized version from another source.


~~~r
scar_zone <- raster(
  'data/r_OVERLAY_ID_83_399_144_TEST_BURNT_83_144_399_reclassed.tif')
crs(scar_zone) <- '+init=epsg:3338'
scar_zone <- crop(scar_zone, ndvi)
~~~
{:.text-document title="{{ site.handouts[0] }}"}

===

The `zonal` function calculates `fun` over each zone


~~~r
scar_ndvi <- zonal(ndvi, scar_zone, fun = "mean")
~~~
{:.text-document title="{{ site.handouts[0] }}"}

===

Rearrange the data for vizualization as a time series.


~~~r
zone <- factor(scar_ndvi[, 1])
scar_ndvi <- scar_ndvi[, -1]
scar_zone <- data.frame(
  Date = rep(dates, each = nrow(scar_ndvi)),
  Zone = rep(zone, length(dates)),
  NDVI = c(scar_ndvi))
~~~
{:.text-document title="{{ site.handouts[0] }}"}

===

What appears to be the most pronounced signal in this view is an early loss of greenness compared to the background NDVI.


~~~r
ggplot(scar_zone,
  aes(x = Date, y = NDVI, col = Zone)) +
  geom_line()
~~~
{:.input}

![plot of chunk unnamed-chunk-19]({{ site.baseurl }}/images/unnamed-chunk-19-1.png)
{:.captioned}

===

Zonal statistics

- provide a very clean reduction of raster time-series for easy vizualization
- require pre-defined zones!
