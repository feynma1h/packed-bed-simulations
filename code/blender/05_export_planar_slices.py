"""
Export planar impressions (slices) of a packed bed (Blender).
=============================================================

Generates the cross-sectional slice images that feed the porosity analysis.
A stack of horizontal circular planes is created at increasing heights `z`.
For each plane, every particle it intersects is subtracted from it with a
Boolean-difference modifier, leaving white where the plane is open (void) and
holes where particles cut through. The plane is then rendered top-down to a PNG.

Why Blender instead of the per-shape MATLAB projectors (code/matlab/exportImages_*):
this Boolean approach works for *any* particle geometry with a single universal
script — no need to derive the analytic projection of each new pellet shape.

The resulting `z=###.png` stack is processed by
code/matlab/avgRadialPorosity.m to obtain the z-averaged radial porosity.

Cleaned and documented from blender-files/export-planar-slices.blend
(export images.blend).
"""

import bpy
import math

# ----------------------------------------------------------------------------
N_PLANES      = 100                 # number of horizontal slices
N_PARTICLES   = 300                 # particles present in the scene
TUBE_RADIUS   = 4.7
Z_BOTTOM      = -100.0
DZ            = 0.5                  # spacing between slices
PARTICLE_DIAG = 0.5 * math.sqrt(2 * 2 + 2 * 2)   # half body-diagonal cull radius
OUT_DIR       = "//slices/"         # relative to the .blend file
# ----------------------------------------------------------------------------

# Create the stack of capped circular planes.
for i in range(1, N_PLANES + 1):
    bpy.ops.mesh.primitive_circle_add(
        vertices=256, radius=TUBE_RADIUS, fill_type='NGON',
        location=(0, 0, Z_BOTTOM + DZ * i))

plane_names = ['Circle'] + [f'Circle.{i:03d}' for i in range(1, N_PLANES)]
particle_names = [f'Particle.{i:03d}' for i in range(1, N_PARTICLES + 1)]
filenames = [f'z={5 * i:03d}' for i in range(1, N_PLANES + 1)]

# Camera + light looking straight down for a clean orthographic-style render.
bpy.ops.object.camera_add(location=(40, 40, 25), rotation=(0, 0, 0))
bpy.context.scene.camera = bpy.context.scene.objects['Camera']
bpy.ops.object.light_add(type='SUN', location=(40, 40, 25))

for i in range(N_PLANES):
    plane = bpy.data.objects[plane_names[i]]
    plane.select_set(True)
    bpy.context.view_layer.objects.active = plane
    pz = plane.matrix_world.translation.z

    # Only subtract particles whose centre is within one body-diagonal of the
    # plane — everything else cannot possibly intersect it.
    for j in range(N_PARTICLES):
        particle = bpy.data.objects[particle_names[j]]
        if abs(particle.matrix_world.translation.z - pz) <= PARTICLE_DIAG:
            mod = plane.modifiers.new(name="Boolean", type='BOOLEAN')
            mod.object = particle
            bpy.ops.object.modifier_apply(modifier="Boolean")

    # Move the finished plane aside, render top-down, then delete it.
    plane.location = (40, 40, 0)
    bpy.context.scene.render.image_settings.file_format = 'PNG'
    bpy.context.scene.render.filepath = OUT_DIR + filenames[i]
    bpy.ops.render.render(write_still=True)
    bpy.ops.object.delete()

print(f"Rendered {N_PLANES} slice images to {OUT_DIR}")
