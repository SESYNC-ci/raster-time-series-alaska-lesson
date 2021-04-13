---
---

## Introduction

The [raster](){:.rlib} library is a powerful open-source geographical data analysis tool used to manipulate, analyze, and model spatial raster data.
A raster is a grid of pixel values---in the world of geospatial data, the grid is associated with a location on Earth's surface.
This lesson provides an overview of using [raster](){:.rlib}, the namesake package in R, to create a raster time series of wildfires in Alaska.

===

## Lesson Objectives

- Work with time series raster data
- Observe characteristics of wildfires in remote sensing data
- Find "unusual" pixels in time-series of raster data

===

## Specific Achievements

- Distinguish raster "stacks" from  raster "bricks"
- Use MODIS derived Normalized Difference Vegetation Index (NDVI) rasters
- Execute efficient raster calculations
- Perform Principal Component Analysis (PCA) on raster "bricks"

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


We load the required packages, `sf`, `raster`, and `ggplot2`. 
`dir.create()`  creates a folder for output rasters called `outputs_raster_ts`.
{:.notes}
