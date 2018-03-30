---
---

## Summary

The `RasterBrick` objects created by the `brick` function, or sometimes as the
result of calculations on a `RasterStack`, are built for many layers of large
rasters. Key principals for efficient analysis on raster time series include

- consolidate `RasterStacks` to `RasterBricks` for faster computation
- provide `filename` arguments to keep objects on disk
- use `layerStats` to get a covariance matrix for PCA
- use `calc` and `overlay` to call custom functions
