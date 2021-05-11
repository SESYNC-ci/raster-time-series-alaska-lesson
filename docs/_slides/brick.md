---
---

## Raster Time Series

Take a closer look at NDVI using products covering 16-day periods in 2005. These
images are stored as separate files on the disk, all having the same extent and
resolution.



~~~r
ndvi_16day <- Sys.glob(
  'data/NDVI_alaska_2005/*.tif')
ndvi <- stack(ndvi_16day)
crs(ndvi) <- '+init=epsg:3338'
~~~
{:title="{{ site.data.lesson.handouts[0] }}" .text-document}

The `ndvi_16day` object contains the names for all the `.tif` files in the `data/NDVI_alaska_2005/` folder.
We create a stack of rasters and assign a CRS.
{:.notes}

===

Lacking other metadata, extract the date of each image from its filename.



~~~r
dates <- as.Date(
  sub('alaska_NDVI_', '', names(ndvi)),
  '%Y_%m_%d')
names(ndvi) <- format(dates, '%b %d %Y')
~~~
{:title="{{ site.data.lesson.handouts[0] }}" .text-document}

All the raster images are stored in the `ndvi` stack object and their names start
with `alaska_NDVI_`.
`names(ndvi)` gives us all the names of the rasters in the stack.
First we use `sub()` to replace `alaska_NDVI_` with an empty string, which gives us just the dates.
We then format the dates, and assign them back as the names for the rasters in the stack.
In this case, we are formatting the dates like so: `'%b %d %Y'`, where `%b` is the month, `%d` the day, and `%Y` the year.
{:.notes}



~~~r
> plot(subset(ndvi, 1:2))
~~~
{:title="Console" .input}
![ ]({% include asset.html path="images/brick/unnamed-chunk-3-1.png" %})
{:.captioned}

===

## Raster Bricks

A `RasterBrick` representation of tightly integrated raster layers, such as a
time series of remote sensing data from sequential overflights, has advantages
for speed but limitations on flexibility.

A `RasterStack` is more flexible because it can mix values stored on disk with
those in memory. Adding a layer of in-memory values to a `RasterBrick` causes the
entire brick to be loaded into memory, which may not be possible given the
available memory.
{:.notes}

`RasterBrick` can be created from a `RasterStack`
{:.notes}

===

For training purposes, again crop the NDVI data to the bounding box of the
wildfires shapefile. But this time, avoid reading the values into memory.



~~~r
ndvi <- crop(ndvi, burn_bbox,
  filename = file.path(out, 'crop_alaska_ndvi.grd'),
  overwrite = TRUE)
~~~
{:title="{{ site.data.lesson.handouts[0] }}" .text-document}


===

Notice that `crop` creates a `RasterBrick`. In fact, we have been working with a
`RasterBrick` in memory since first using `crop`.



~~~r
> ndvi
~~~
{:title="Console" .input}


~~~
class      : RasterBrick 
dimensions : 74, 151, 11174, 23  (nrow, ncol, ncell, nlayers)
resolution : 1000.045, 999.9566  (x, y)
extent     : 68336.16, 219342.9, 1772970, 1846967  (xmin, xmax, ymin, ymax)
crs        : +init=epsg:3338 +proj=aea +lat_1=55 +lat_2=65 +lat_0=50 +lon_0=-154 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs +ellps=GRS80 +towgs84=0,0,0 
source     : /research-home/agarcia/lesson_repos/raster-time-series-alaska-lesson/outputs_raster_ts/crop_alaska_ndvi.grd 
names      : Jan.01.2005, Jan.17.2005, Feb.02.2005, Feb.18.2005, Mar.06.2005, Mar.22.2005, Apr.07.2005, Apr.23.2005, May.09.2005, May.25.2005, Jun.10.2005, Jun.26.2005, Jul.12.2005, Jul.28.2005, Aug.13.2005, ... 
min values :    -0.19518,    -0.20000,    -0.19900,    -0.18050,    -0.12120,    -0.09540,    -0.03910,    -0.11290,    -0.09390,    -0.15520,    -0.18400,    -0.16780,    -0.18000,    -0.17200,    -0.18600, ... 
max values :   0.3337000,   0.3633000,   0.4949000,   0.3514000,   0.4898000,   0.7274000,   0.6268000,   0.5879000,   0.9076000,   0.9190000,   0.8807000,   0.9625000,   0.8810000,   0.9244000,   0.9493000, ... 
~~~
{:.output}


===

## So Much Data

The immediate challenge is trying to represent the data in ways we can explore
and interpret the characteristics of wildfire visible by remote sensing.



~~~r
> animate(ndvi, pause = 0.5, n = 1)
~~~
{:title="Console" .no-eval .input}


![plot of ndvi_animation]({% include asset.html path="images/ndvi_animation.gif" %})
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
{:title="{{ site.data.lesson.handouts[0] }}" .text-document}
![ ]({% include asset.html path="images/brick/unnamed-chunk-8-1.png" %})
{:.captioned}
`match()` returns the index of the layer in `ndvi` named `'Aug.13.2005'`.
{:.notes}


===



~~~r
> pixel <- click(ndvi[[idx]], cell = TRUE)
> pixel
~~~
{:title="Console" .no-eval .input}

`click()` gives us the ability to click on the plot map and get pixel values for a cell.
After clicking on the map, you will see the cell number and value for that cell is printed on the console. 
Press the `esc` key to exit the pixel clicker. 
{:.notes}

===

"Hard code" these pixel values into your worksheet.



~~~r
pixel <- c(2813, 3720, 2823, 4195, 9910)
scar_pixel <- data.frame(
  Date = rep(dates, each = length(pixel)),
  cell = rep(pixel, length(dates)),
  Type = 'burn scar?',
  NDVI = c(ndvi[pixel]))
~~~
{:title="{{ site.data.lesson.handouts[0] }}" .text-document}

We create a `scar_pixel` dataframe for the burn scar. `rep()` repeats the dates  `each` times (the number of pixels). 
`pixel` is repeated for each of the dates.
{:.notes}

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
{:title="{{ site.data.lesson.handouts[0] }}" .text-document}


===

Join your haphazard samples together for comparison as time series.



~~~r
pixel <- rbind(normal_pixel, scar_pixel)
ggplot(pixel,
       aes(x = Date, y = NDVI,
           group = cell, col = Type)) +
  geom_line()
~~~
{:title="{{ site.data.lesson.handouts[0] }}" .text-document}
![ ]({% include asset.html path="images/brick/unnamed-chunk-12-1.png" %})
{:.captioned}

Combine the two dataframes we created to a single one and plot with `ggplot()`.
We can see a significant difference in August between a possible burn scar and what the area normally looks like.
{:.notes}

===

## Zonal Averages

We cannot very well analyze the time series for every pixel, so we have to reduce
the dimensionality of the data. One way is to summarize it by "zones" defined by
another spatial data source.



~~~r
> ?zonal
~~~
{:title="Console" .no-eval .input}


Currently we have raster data (`ndvi`) and vector data (`scar`). In order to
aggregate by polygon, we have to join these two datasets. There are two
approaches. 1) Treat the raster data as POINT geometries in a table and perform
a spatial join to the table with POLYGON geometries. 2) Turn the polygons into a
raster and summarize the raster masked for each polygon. Let's pursue option 2.
{:.notes}

===

Let's convert out `scar` shapefile to raster with the `rasterize`
function.  



~~~r
# Rasterize polygon shapefile.
scar_geom <-
  as(st_geometry(scar), 'Spatial')
scar_zone <- rasterize(scar_geom, ndvi,
  background = 0,
  filename = 'outputs_raster_ts/scar.grd',
  overwrite = TRUE)

crs(scar_zone) <- '+init=epsg:3338'
scar_zone <- crop(scar_zone, ndvi)
~~~
{:title="{{ site.data.lesson.handouts[0] }}" .text-document}


Using `as()` we coerce the `scar` shapefile as an object of the 'Spatial' class. We then use `rasterize()` to create a `RasterLayer` object for the shapefile. Then we crop the raster to the same extent as `ndvi`.
{:.notes}

===

The `zonal` function calculates `fun` (here, `mean`) over each zone.



~~~r
scar_ndvi <-
  zonal(ndvi, scar_zone, "mean")
~~~
{:title="{{ site.data.lesson.handouts[0] }}" .text-document}


===

Rearrange the data for visualization as a time series.



~~~r
zone <- factor(scar_ndvi[, 1])
scar_ndvi <- scar_ndvi[, -1]
scar_zone <- data.frame(
  Date = rep(dates, each = nrow(scar_ndvi)),
  Zone = rep(zone, length(dates)),
  NDVI = c(scar_ndvi))
~~~
{:title="{{ site.data.lesson.handouts[0] }}" .text-document}


Here we convert the zone category labels to a `factor` variable, then
manually reshape the data from wide form to long form, with one column
for the date, one for the zone category, and one for the mean NDVI value
for that category.
{:.notes}

===

What appears to be the most pronounced signal in this view is an early loss of
greenness compared to the background NDVI (Zone 0).



~~~r
> ggplot(scar_zone,
+        aes(x = Date, y = NDVI,
+            col = Zone)) +
+   geom_line()
~~~
{:title="Console" .input}
![ ]({% include asset.html path="images/brick/unnamed-chunk-17-1.png" %})
{:.captioned}

===

## Zonal Statistics

- provide a very clean reduction of raster time-series for easy visualization
- require pre-defined zones!
