# Code

Scripts for the full synthetic-bed pipeline. See the [main README](../README.md)
for how they fit together.

### `blender/` — bed generation & processing (Python / `bpy`)

Run inside Blender's **Scripting** workspace. Numbered in pipeline order:

| Script | Purpose |
|--------|---------|
| [`01_generate_packed_bed.py`](blender/01_generate_packed_bed.py) | Drop particles into a tube and settle them with rigid-body physics |
| [`02_nlobe_particle.py`](blender/02_nlobe_particle.py) | Parametric generator for tri-/quad-/N-lobe catalyst pellets |
| [`03_export_particle_transforms.py`](blender/03_export_particle_transforms.py) | Export particle location + orientation of the settled bed to CSV |
| [`04_place_bed_from_data.py`](blender/04_place_bed_from_data.py) | Rebuild a bed from an exported CSV (no physics re-run) |
| [`05_export_planar_slices.py`](blender/05_export_planar_slices.py) | Universal Boolean slicing → PNG stack for porosity analysis |

> Cleaned and documented from the original Blender text blocks; the raw
> `.blend` files are preserved in [`../blender-files/`](../blender-files).

### `ansys/` — CAD reconstruction (SpaceClaim Python)

[`recreate_bed_in_spaceclaim.py`](ansys/recreate_bed_in_spaceclaim.py) — reads the
exported CSV and rebuilds the identical packing as CAD solids, ready to mesh and
solve in Fluent.

### `matlab/` — porosity analysis & plotting

See [`matlab/README.md`](matlab/README.md).

### `python/` — supporting analysis

[`pixel-discretization-analysis.ipynb`](python/pixel-discretization-analysis.ipynb) —
a small study of how many image pixels a circle of a given radius crosses, used to
understand discretisation error in the pixel-counting porosity method.
