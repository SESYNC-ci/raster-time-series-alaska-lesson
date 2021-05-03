---
---

## Summary

The `RasterBrick` objects created by the `brick` function, or sometimes as the
result of calculations on a `RasterStack`, are built for many layers of large
rasters. Key principles for efficient analysis of raster time series include:

===

- consolidate `RasterStacks` to `RasterBricks` for faster computation
- provide `filename` arguments to keep objects on disk
- use `layerStats` to get a covariance matrix for Principal Component Analysis (PCA)
- use `calc` and `overlay` to call custom functions

Takeaways:
- The `raster` package has two classes for multi-layer data the `RasterStacks` and the `RasterBrik`.
- `RasterBrik` can only be linked to a single (multi-layer) file.
- `RasterStack` can be formed from separate files and/or from a few layers from a single file.
- PCA is a dimensionality-reduction method used to reduce the dimensionality of a large data set improving algorithm and analysis performance and speed.
