## Logistics

library(sf)
library(raster)
library(ggplot2)

out <- 'outputs_raster_ts'
dir.create(out, showWarnings = FALSE)

## Raster Stacks 

ndvi_yrly <- ...('data/r_ndvi_*.tif')

ndvi <- ...
names(ndvi) <- c(
  'Avg NDVI 2002',
  'Avg NDVI 2009')

... <- '+init=epsg:3338'

## Wildfires in Alaska 

scar <- ...(
  'data/OVERLAY_ID_83_399_144_TEST_BURNT_83_144_399_reclassed',
  crs = 3338)
plot(...)
plot(..., add = TRUE)

burn_bbox <- ...
ndvi <- ...(ndvi, burn_bbox)

## Pixel Change 

diff_ndvi <- ...
names(diff_ndvi) <- 'Difference'

diff_ndvi_mean <-
  ...(diff_ndvi, 'mean')
diff_ndvi_sd <-
  cellStats(diff_ndvi, 'sd')

diff_ndvi_stdz <-
  ... /
  ...
names(diff_ndvi_stdz) <- 'Std. Diff.'

## Raster Time Series 

ndvi_16day <- Sys.glob(
  'data/NDVI_alaska_2005/*.tif')
ndvi <- ...(ndvi_16day)
crs(ndvi) <- '+init=epsg:3338'

dates <- as.Date(
  sub('alaska_NDVI_', '', names(ndvi)),
  '%Y_%m_%d')
names(ndvi) <- format(dates, '%b %d %Y')

## Raster Bricks 

ndvi <- crop(ndvi, ...,
  ... = file.path(out, 'crop_alaska_ndvi.grd'),
  overwrite = TRUE)

## Pixel Time Series 

idx <- match('Aug.13.2005', names(ndvi))
plot(ndvi[[idx]])

pixel <- c(2813, 3720, 2823, 4195, 9910)
scar_pixel <- data.frame(
  Date = ...,
  cell = rep(pixel, length(dates)),
  Type = 'burn scar?',
  NDVI = ...)

pixel <- c(1710, 4736, 7374, 1957, 750)
normal_pixel <- data.frame(
  Date = rep(dates, each = length(pixel)),
  cell = rep(pixel, length(dates)),
  Type = 'normal',
  NDVI = c(ndvi[pixel]))

pixel <- rbind(normal_pixel, scar_pixel)
ggplot(pixel,
       aes(x = ..., y = ...,
           group = ..., col = ...)) +
  geom_line()

## Zonal Averages 

scar_geom <-
  as(st_geometry(scar), 'Spatial')
scar_zone <- rasterize(scar_geom, ndvi,
                       background = 0,
                       filename = 'outputs_raster_ts/scar.grd',
                       overwrite = TRUE)

crs(scar_zone) <- '+init=epsg:3338'
scar_zone <- crop(scar_zone, ndvi)

scar_ndvi <-
  ...(ndvi, scar_zone, ...)

zone <- factor(scar_ndvi[, 1])
scar_ndvi <- scar_ndvi[, -1]
scar_zone <- data.frame(
  Date = rep(dates, each = nrow(scar_ndvi)),
  Zone = rep(zone, length(dates)),
  NDVI = c(scar_ndvi))

## Eliminating Time 

ndvi_lS <- ...(
  ndvi, ..., na.rm = TRUE)
ndvi_mean <- ndvi_lS[['mean']]
ndvi_cov <- ndvi_lS[['covariance']]
ndvi_cor <- cov2cor(ndvi_cov)

ndvi_std <- sqrt(diag(ndvi_cov))
ndvi_stdz <- ...(ndvi,
  ... ,
  filename = file.path(out, 'ndvi_stdz.grd'),
  overwrite = TRUE)

pca <- ...
plot(pca)

npc <- 4
loading <- data.frame(
  Date = rep(dates, npc),
  PC = factor(rep(1:npc, each = length(dates))),
  Loading = ...
)

ggplot(loading,
       aes(...,
           ...)) +
  geom_line()

pca$center <- pca$scale * 0
ndvi_scores <- ...(
  ...
  index = 1:npc,
  filename = file.path(out, 'ndvi_scores.grd'),
  overwrite = TRUE)
plot(ndvi_scores)

ndvi_dev <- ...(
  ...
  fun = ... {
    ...
  },
  filename = file.path(out, 'ndvi_dev.grd'),
  overwrite = TRUE)
names(ndvi_dev) <- names(ndvi)

plot(
  ndvi_scores[[2]] < -2 |
  ndvi_scores[[3]] < -2)
plot(st_geometry(scar), add = TRUE)
