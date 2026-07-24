"""
Rebuild a bed from exported location/orientation data (Blender).
================================================================

Reads a `LocRot` CSV (columns: x, y, z, rot_x, rot_y, rot_z) and duplicates a
single base particle to every recorded position/orientation. Useful for
re-instantiating a saved packing without re-running the physics, or for
swapping the particle shape while keeping the packing fixed.

Cleaned and documented from blender-files/place-bed-from-data.blend
(PBG(LocRot).blend).
"""

import bpy
from numpy import genfromtxt

# ----------------------------------------------------------------------------
BASE_PARTICLE = "Sphere"                     # object to duplicate
CSV_PATH = bpy.path.abspath("//particleLoc.csv")
# ----------------------------------------------------------------------------

# Columns 1-3 -> location, columns 4-6 -> Euler rotation.
loc_rot = genfromtxt(CSV_PATH, delimiter=',')

for i in range(loc_rot.shape[0]):
    bpy.data.objects[BASE_PARTICLE].select_set(True)
    bpy.context.view_layer.objects.active = bpy.data.objects[BASE_PARTICLE]
    bpy.ops.object.duplicate()

    obj = bpy.context.object
    obj.location = (loc_rot[i, 0], loc_rot[i, 1], loc_rot[i, 2])
    obj.rotation_euler = (loc_rot[i, 3], loc_rot[i, 4], loc_rot[i, 5])

    bpy.context.active_object.select_set(False)
    bpy.ops.object.select_all(action='DESELECT')

print(f"Placed {loc_rot.shape[0]} copies of '{BASE_PARTICLE}'.")
