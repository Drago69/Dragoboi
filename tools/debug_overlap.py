#!/usr/bin/env python3
"""Zeigt Ueberschneidungen zweier Gruppen als Einzelkoerper (Welt-, Rinnen- und Teller-TD-Koordinaten).
Aufruf: python3 tools/debug_overlap.py GRUPPE_A[:DEF=WERT,...] GRUPPE_B[:...]"""
import sys, os, math, numpy as np, trimesh
sys.path.insert(0, os.path.dirname(__file__))
import check_collisions as cc
A = 28; BZ = 900; RZ = BZ + 172; S_T = -590; RB = 228.7
TD_C = np.array([(15 - RB)/math.sqrt(2), S_T, -(RB + 15)/math.sqrt(2)])
def w2g(p):
    a = math.radians(A); y, z = p[1], p[2] - RZ
    return np.array([p[0], y*math.cos(a) - z*math.sin(a), y*math.sin(a) + z*math.cos(a)])
def g2td(g):
    d = g - TD_C; c = math.sqrt(0.5)
    return np.array([c*d[0] + c*d[2], d[1], -c*d[0] + c*d[2]])
def parse(arg):
    g, *rest = arg.split(":")
    d = dict(kv.split("=") for kv in rest[0].split(",")) if rest else {}
    return cc.export(g, **d)
pa, pb = parse(sys.argv[1]), parse(sys.argv[2])
i = cc.load(pa) ^ cc.load(pb)
m = i.to_mesh()
tm = trimesh.Trimesh(np.asarray(m.vert_properties)[:, :3], np.asarray(m.tri_verts))
for part in sorted(tm.split(only_watertight=False), key=lambda p: -abs(p.volume))[:12]:
    c = part.centroid; g = w2g(c); t = g2td(g)
    th = 2*abs(part.volume)/max(part.area, 1e-9)
    print(f"vol {abs(part.volume):8.2f} dicke {th:5.2f}  W {np.round(c,1)}  G(X,s,n) {np.round(g,1)}  TD {np.round(t,1)} r={math.hypot(t[0],t[1]):.1f} ang={math.degrees(math.atan2(t[1],t[0])):.1f}")
