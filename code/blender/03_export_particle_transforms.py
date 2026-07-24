"""
Export particle location + orientation from a settled Blender bed.
==================================================================

After the rigid-body simulation has settled (01_generate_packed_bed.py), this
writes the position and Euler orientation of every particle at a chosen frame to
a CSV. That CSV is the hand-off to:

  * MATLAB  -> generate planar impressions & porosity profiles
  * Ansys   -> recreate the identical packing in SpaceClaim (see code/ansys)

Output columns: x, y, z, rot_x, rot_y, rot_z   (one row per particle)

Cleaned and documented from blender-files/export-particle-transforms.blend
(export object properties.blend).
"""

import bpy
import os

# ----------------------------------------------------------------------------
FRAME = 1                       # frame at which the bed is fully settled
OUT_PATH = os.path.join(bpy.path.abspath("//"), "particleLoc.csv")
# ----------------------------------------------------------------------------

bpy.context.scene.frame_set(FRAME)

# Select every particle. (Exclude the tube first if it is in the scene.)
bpy.ops.object.select_all(action='SELECT')
selected = bpy.context.selected_objects

with open(OUT_PATH, "w") as f:
    for obj in selected:
        loc = obj.matrix_world.translation
        rot = obj.rotation_euler
        f.write(f"{loc.x},{loc.y},{loc.z},{rot.x},{rot.y},{rot.z}\n")

print(f"Wrote transforms for {len(selected)} particles -> {OUT_PATH}")
