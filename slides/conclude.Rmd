---
---

## Summary

The `RasterBrick` objects created by the `brick` function, or sometimes as the
result of calculations on a `RasterStack`, are built for many layers of large
rasters. Key principles for efficient analysis of raster time series include:

===

- consolidate `RasterStack`s to `RasterBrick`s for faster computation
- provide `filename` arguments to keep objects on disk
- use `layerStats` to get a covariance matrix for PCA
- use `calc` and `overlay` to call custom functions
