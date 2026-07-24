"""
Recreate a Blender-generated packing inside Ansys SpaceClaim.
============================================================

Reads the particle location/orientation CSV exported from Blender
(code/blender/03_export_particle_transforms.py) and rebuilds the *identical*
packing as CAD solids in SpaceClaim, ready for meshing and CFD in Fluent.

For each row it copies a template particle body (Bodies[0]), applies the three
Euler rotations (columns 4-6, in degrees), then translates it to the recorded
position (columns 1-3, interpreted in centimetres).

Run from SpaceClaim's script editor with the template particle as the only body
in the design.

Reconstructed from the project's SpaceClaim script (scriptAnsys-shapedParticle).
"""

import csv

# Template body to be copied to every particle location.
template = Selection.Create(GetRootPart().Bodies[0])

path = r"particleLoc.csv"   # x, y, z, rot_x, rot_y, rot_z  (rotations in degrees)

with open(path, 'r') as f:
    reader = csv.reader(f)
    b = 1                                        # index of the next pasted body
    for row in reader:
        # Duplicate the template body via the clipboard.
        Copy.ToClipboard(template)
        Paste.FromClipboard()

        selection = Selection.Create(GetRootPart().Bodies[b])

        # Apply the recorded orientation about X, Y, then Z.
        for axis_dir, col in ((Direction.DirX, 3),
                              (Direction.DirY, 4),
                              (Direction.DirZ, 5)):
            anchor = Move.GetAnchorPoint(selection)
            axis = Line.Create(anchor, axis_dir)
            Move.Rotate(selection, axis, RAD(float(row[col])), MoveOptions())

        # Move the body to its recorded (x, y, z) location.
        anchor = Move.GetAnchorPoint(selection)
        frame = Frame.Create(anchor, Direction.DirX, Direction.DirY)
        Move.MoveToCoordinate(selection,
                              CM(float(row[0])), CM(float(row[1])), CM(float(row[2])),
                              frame, MoveOptions())
        b += 1
