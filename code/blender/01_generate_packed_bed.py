"""
Synthetic packed-bed generation in Blender via rigid-body physics.
================================================================

Fills a cylindrical tube with catalyst particles by dropping them in one at a
time and letting Blender's Bullet rigid-body solver settle them into a random
close packing — the same way particles pack in a real fixed-bed reactor.

Pipeline position
-----------------
    [this script] --> 02..04 (particle shapes / export) --> MATLAB porosity
    analysis --> Ansys CFD

How it works
------------
1. Build an open-topped cylindrical tube as a *passive* rigid body (the wall).
2. Spawn `N` particles above the tube. Each particle is keyframed as
   *kinematic* (animated, ignores gravity) until its release frame, then flips
   to *dynamic* so it falls and collides. Staggering the release frames by `f`
   frames makes the particles drop one at a time and pack without interlocking
   mid-air.
3. A high-quality rigid-body world (many substeps + solver iterations) keeps
   thin/low-restitution contacts stable so the final packing is realistic.

Run inside Blender: Scripting workspace -> paste -> Run, then bake the
rigid-body cache and step to the last frame.

Cleaned and documented from the project's Blender text blocks
(blender-files/bed-generation_physics.blend, Task 8_cylinder bed.blend).
"""

import bpy
import bmesh
import mathutils
import numpy as np

# ----------------------------------------------------------------------------
# USER PARAMETERS
# ----------------------------------------------------------------------------
N                 = 50      # number of particles to pack
F_GAP             = 20      # frames between successive particle releases
F_TOTAL           = 2000    # frames to run the simulation for
TUBE_RADIUS       = 4.7     # inner radius of the tube
TUBE_DEPTH        = 100     # tube length
PARTICLE_RADIUS   = 1.0     # nominal particle radius (sphere used here as example)

# Rigid-body world quality (higher -> more stable contacts, slower)
STEPS_PER_SECOND  = 1500
SOLVER_ITERATIONS = 200


def build_tube():
    """Create an open-topped cylinder that acts as the passive tube wall."""
    bpy.ops.mesh.primitive_cylinder_add(
        vertices=1024, radius=TUBE_RADIUS, depth=TUBE_DEPTH,
        end_fill_type='TRIFAN', enter_editmode=True, align='WORLD',
        location=(0, 0, -TUBE_DEPTH / 2))

    mesh = bpy.context.object.data
    bm = bmesh.from_edit_mesh(mesh)

    # Delete the top cap so particles can be dropped in from above.
    bpy.ops.mesh.select_mode(type='FACE')
    for face in bm.faces:
        face.select_set(
            np.linalg.norm(face.normal - mathutils.Vector((0, 0, 1))) <= 1e-4)
    bpy.ops.mesh.delete(type='ONLY_FACE')

    # Remove the now-dangling rim edges left behind by the cap.
    bpy.ops.mesh.select_mode(type='EDGE')
    for edge in bm.edges:
        v1, v2 = edge.verts
        top = mathutils.Vector((0, 0, TUBE_DEPTH / 2))
        edge.select_set(
            (v1.co - top).length < 1e-4 or (v2.co - top).length < 1e-4)
    bpy.ops.mesh.delete(type='EDGE')
    bpy.ops.object.editmode_toggle()

    # Make the tube a passive (immovable) rigid body with an exact mesh wall.
    bpy.ops.rigidbody.object_add()
    rb = bpy.context.object.rigid_body
    rb.type = 'PASSIVE'
    rb.collision_shape = 'MESH'
    rb.mesh_source = 'BASE'
    rb.friction = 0.5
    rb.restitution = 0.0
    rb.collision_margin = 0.0


def add_particle(index):
    """Spawn one particle and keyframe it to release at its staggered frame."""
    # Swap this primitive for any particle from 02_nlobe_particle.py / the
    # particle library to build shaped-particle beds.
    bpy.ops.mesh.primitive_uv_sphere_add(
        radius=PARTICLE_RADIUS, location=(0, 0, 0))

    bpy.ops.rigidbody.object_add()
    rb = bpy.context.object.rigid_body
    rb.mass = 100
    rb.collision_shape = 'SPHERE'         # CONVEX_HULL / MESH for shaped particles
    rb.use_margin = True
    rb.collision_margin = 0.0
    rb.friction = 0.5
    rb.restitution = 0.2
    rb.use_deactivation = True            # let settled particles "sleep"
    rb.deactivate_linear_velocity = 5e-4
    rb.deactivate_angular_velocity = 5e-3

    release = F_GAP * index + 1
    obj = bpy.context.object

    # Hold the particle above the tube as a kinematic (animated) body...
    bpy.context.scene.frame_set(release)
    obj.location = (1e-3 * np.random.uniform(-1, 1), 0, 30)  # tiny x-jitter breaks symmetry
    obj.keyframe_insert(data_path="location")
    rb.kinematic = True
    obj.keyframe_insert(data_path="rigid_body.kinematic", frame=release)

    # ...then hand it over to the physics solver so it drops and packs.
    bpy.context.scene.frame_set(release + 1)
    rb.kinematic = False
    obj.keyframe_insert(data_path="rigid_body.kinematic", frame=release + 1)


def main():
    scene = bpy.context.scene
    scene.frame_start = 1
    scene.frame_end = F_TOTAL

    build_tube()
    bpy.ops.object.editmode_toggle()

    for i in range(N):
        add_particle(i)

    # Crank up world quality for stable, physically plausible packing.
    scene.rigidbody_world.steps_per_second = STEPS_PER_SECOND
    scene.rigidbody_world.solver_iterations = SOLVER_ITERATIONS

    print(f"Placed {N} particles; bake the rigid-body cache to settle the bed.")


if __name__ == "__main__":
    main()
