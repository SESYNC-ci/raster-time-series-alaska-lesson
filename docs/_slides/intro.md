---
---

## Lesson Objectives

- Observe characteristics of wildfire in remote sensing data
- Find "unusual" pixels in time-series of raster data

===

## Specific Achievements

- Distinguish "stacks" from "bricks"
- Use MODIS derived NDVI
- Execute efficient raster calculations
- Perform PCA on "bricks"

===

## Logistics

Load packages, define global variables, and take care of remaining logistics at
the very top.



~~~r
library(sf)
library(raster)
library(ggplot2)

out <- 'outputs_raster_ts'
dir.create(out, showWarnings = FALSE)
~~~
{:title="{{ site.data.lesson.handouts[0] }}" .text-document}

