"""
Parametric N-lobe catalyst particle generator (Blender).
========================================================

Builds the extruded "N-lobe" catalyst pellets used in the study (tri-lobe,
quad-lobe, ...). The cross-section is made of `N` circular lobes of radius `R`
whose centres sit a distance `d` from the axis; neighbouring lobes intersect so
the outline is a smooth multi-lobed profile. The 2-D profile is meshed, capped
with a face, then extruded by `H` to give the solid pellet.

Geometry
--------
Each lobe contributes a circular arc. With the lobe centres equally spaced at
angle ``2*pi/N``, two adjacent circles of radius `R` centred a distance `d`
apart intersect where the visible arc of a single lobe spans::

    arc_angle = pi + 2*pi/N - 2*acos( d*sin(pi/N) / R )

Requirement: ``d < R`` (otherwise the lobes leave a hole at the centre).

Cleaned and documented from blender-files/nlobe-bed-generation.blend
(Task 7a_N-lobe bed.blend).
"""

import bpy
import math
from math import sin, cos


def make_n_lobe(N=3, n_verts=128, R=0.5255, d=0.4745, H=2.0, name="N_lobe"):
    """Create a solid N-lobe pellet mesh and return the Blender object.

    Parameters
    ----------
    N        : number of lobes (3 = tri-lobe, 4 = quad-lobe, ...)
    n_verts  : vertices sampled along each lobe's arc (higher = smoother)
    R        : lobe (circle) radius
    d        : distance of each lobe centre from the axis (must be < R)
    H        : extrusion height of the pellet
    """
    if d >= R:
        raise ValueError("Need d < R, otherwise the lobe centre is hollow.")

    arc_angle = math.pi + 2 * math.pi / N - 2 * math.acos(d * sin(math.pi / N) / R)
    section_angle = arc_angle / (n_verts - 1)

    verts, edges = [], []
    for j in range(N):
        lobe_centre = math.pi / 2 + j * 2 * math.pi / N       # angular position of lobe j
        arc_start = math.pi / 2 - arc_angle / 2 + j * 2 * math.pi / N
        for i in range(1, n_verts):
            theta = arc_start + i * section_angle
            x = d * cos(lobe_centre) + R * cos(theta)
            y = d * sin(lobe_centre) + R * sin(theta)
            verts.append((x, y, 0.0))

    # Close the profile into a single loop.
    n = len(verts)
    edges = [[i, (i + 1) % n] for i in range(n)]

    mesh = bpy.data.meshes.new(name + "_Data")
    mesh.from_pydata(verts, edges, [])
    mesh.update()

    obj = bpy.data.objects.new(name, mesh)
    bpy.context.scene.collection.objects.link(obj)
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj

    # Cap the loop with a face, extrude straight down by H to make the solid.
    bpy.ops.object.editmode_toggle()
    bpy.ops.mesh.edge_face_add()
    bpy.ops.mesh.extrude_region_move(
        TRANSFORM_OT_translate={"value": (0, 0, -H),
                                "constraint_axis": (False, False, True)})
    bpy.ops.mesh.normals_make_consistent(inside=False)   # outward-facing normals
    bpy.ops.object.editmode_toggle()

    # Recentre the origin so the pellet rotates about its own centroid.
    bpy.ops.object.origin_set(type='ORIGIN_CENTER_OF_VOLUME', center='MEDIAN')
    return obj


if __name__ == "__main__":
    # Example: a tri-lobe pellet matching the dimensions used in the thesis.
    make_n_lobe(N=3, R=0.5255, d=0.4745, H=2.0, name="TriLobe")
