# Blender project files

The original `.blend` files behind the pipeline. Open with
[Blender](https://www.blender.org/) (2.9x). The readable, cleaned-up Python
extracted from these files lives in [`../code/blender/`](../code/blender).

### Workflow files

| File | What it does |
|------|--------------|
| `bed-generation_physics.blend` | Physics-based bed generation — drop N particles into a tube and settle them |
| `nlobe-bed-generation.blend` | Bed generation using parametric N-lobe pellets |
| `place-bed-from-data.blend` | Rebuild a bed by placing a base particle from an exported location/orientation CSV |
| `export-particle-transforms.blend` | Export particle locations + orientations of a settled bed |
| `export-planar-slices.blend` | Universal Boolean slicing → rendered slice images |

### `particles/` — catalyst shape library

Reusable particle definitions used to build the beds:

`cylinder` · `cylcut` · `daisy` · `n-hole` · `n-hole-bulge` ·
`internal-external-holes` · `elliptical-cylinder`

> Only finalised files are included — intermediate checkpoints and
> version-iteration files from the original working directory are omitted.
