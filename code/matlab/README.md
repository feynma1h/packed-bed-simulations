# MATLAB — image-based porosity analysis

Turns rendered bed slices into a **z-averaged radial porosity profile**, and
provides analytic per-shape planar projections.

### Core analysis

| Script | Purpose |
|--------|---------|
| [`avgRadialPorosity.m`](avgRadialPorosity.m) | Binarise each slice, count void vs. solid pixels at every radius, average over all slices → radial porosity profile |
| [`avgRadialPorosity_sectorAveraging.m`](avgRadialPorosity_sectorAveraging.m) | Variant that also averages over angular sectors |
| [`z_averagedExport.m`](z_averagedExport.m) | Export z-averaged porosity over chosen height ranges to a spreadsheet |
| [`plotResults.m`](plotResults.m) / [`plotResults_sectorAveraging.m`](plotResults_sectorAveraging.m) | Compare MATLAB vs. Ansys profiles, plot deviations and z-averaged curves |

### Analytic particle projections

`exportImages_*.m` draw the exact planar impression of a single particle shape,
derived from geometry (a cylinder projects to an ellipse, a sphere to a circle,
a plane to a line):

`exportImages_Sphere.m` · `exportImages_Cylinder.m` · `exportImages_Cylcut.m` ·
`exportImages_Daisy.m` · `exportImages_intExt.m` · `exportImages_nHole.m` ·
`exportImages_nLobe.m`

> These per-shape projectors were later superseded by the **universal Boolean
> slicing** approach in [`../blender/05_export_planar_slices.py`](../blender/05_export_planar_slices.py),
> which handles any geometry with a single script.

### Method in one line

At radius `r`, porosity = (black pixels) / (total pixels) along the circle of
radius `r`, averaged over every slice:

```
porosity(r) = mean over slices of  [ void_pixels(r) / total_pixels(r) ]
```
