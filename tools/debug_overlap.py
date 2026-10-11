#!/usr/bin/env python3
"""Zeigt die Einzelkoerper einer Ueberschneidung zweier Gruppen (Diagnose)."""
import sys, glob, os, numpy as np, trimesh
sys.path.insert(0, os.path.dirname(__file__))
from check_collisions import export, load
def run(ga, da, gb, db):
    a = load(export(ga, **da)); b = load(export(gb, **db))
    i = a ^ b
    m = i.to_mesh()
    tm = trimesh.Trimesh(vertices=m.vert_properties[:, :3], faces=m.tri_verts)
    for p in sorted(tm.split(only_watertight=False), key=lambda q: -abs(q.volume))[:15]:
        print(f"  vol {abs(p.volume):9.1f}  min {np.round(p.bounds[0],1)}  max {np.round(p.bounds[1],1)}")
if __name__ == "__main__":
    import ast
    run(sys.argv[1], ast.literal_eval(sys.argv[2]), sys.argv[3], ast.literal_eval(sys.argv[4]))
