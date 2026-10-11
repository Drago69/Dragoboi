#!/usr/bin/env python3
"""Kollisionspruefung der Gesamtbaugruppe ueber alle Bewegungszustaende.

Exportiert Baugruppen-Gruppen (SIMPLE=true, Profile als Vollquadrat) aus
cad/assembly.scad als STL und schneidet sie paarweise mit manifold3d.
Ein Ueberlapp > TOL mm^3 gilt als Kollision.

Aufruf:  python3 tools/check_collisions.py [--quick]
"""
import os, sys, threading, subprocess, itertools, math, json, hashlib
from concurrent.futures import ThreadPoolExecutor
import numpy as np
import trimesh
import manifold3d as m3d

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CAD = os.path.join(ROOT, "cad")
OUT = os.path.join(ROOT, "build", "collide")
os.makedirs(OUT, exist_ok=True)
TOL = 2.0   # mm^3

def _src_hash():
    h = hashlib.md5()
    for root, _, files in sorted(os.walk(CAD)):
        for f in sorted(files):
            if f.endswith(".scad"):
                h.update(open(os.path.join(root, f), "rb").read())
    return h.hexdigest()[:8]
SRC = _src_hash()

def export(group, **defs):
    d = {"GROUP": f'"{group}"', "SIMPLE": "true", "SHOW_BOTTLES": "true"}
    d.update({k: (str(v).lower() if isinstance(v, bool) else str(v)) for k, v in defs.items()})
    key = hashlib.md5((SRC + json.dumps(d, sort_keys=True)).encode()).hexdigest()[:10]
    path = os.path.join(OUT, f"{group}_{key}.stl")
    if not os.path.exists(path):
        tmp = path + f".{os.getpid()}.{threading.get_ident()}.tmp.stl"
        args = ["openscad", "-o", tmp]
        for k, v in d.items():
            args += ["-D", f"{k}={v}"]
        args.append(os.path.join(CAD, "assembly.scad"))
        r = subprocess.run(args, capture_output=True, text=True, timeout=3600)
        if os.path.exists(tmp): os.replace(tmp, path)
        if r.returncode != 0 or not os.path.exists(path):
            print(r.stderr[-2000:])
            raise RuntimeError(f"export failed {group} {defs}")
    return path

_cache = {}
def load(path):
    if path not in _cache:
        tm = trimesh.load(path)
        mesh = m3d.Mesh(vert_properties=np.asarray(tm.vertices, dtype=np.float32),
                        tri_verts=np.asarray(tm.faces, dtype=np.uint32))
        man = m3d.Manifold(mesh)
        if man.status() != m3d.Error.NoError:
            # einmal reparieren ueber trimesh
            tm.merge_vertices(); tm.fill_holes()
            mesh = m3d.Mesh(vert_properties=np.asarray(tm.vertices, dtype=np.float32),
                            tri_verts=np.asarray(tm.faces, dtype=np.uint32))
            man = m3d.Manifold(mesh)
        _cache[path] = man
    return _cache[path]

def overlap(pa, pb):
    a, b = load(pa), load(pb)
    i = a ^ b
    v = i.volume()
    bb = None
    if v > TOL:
        mn, mx = i.bounding_box()[:3], i.bounding_box()[3:]
        bb = [round(x, 1) for x in list(mn) + list(mx)]
    return v, bb

def cam_lift(phi):
    E, R, r = 40.0, 58.0, 11.0
    h = lambda p: E*math.cos(math.radians(p)) + math.sqrt((R+r)**2 - (E*math.sin(math.radians(p)))**2)
    return h(phi) - h(180)

def main():
    quick = "--quick" in sys.argv
    phis = [0, 45, 90, 135, 180, 225, 270, 315] if not quick else [0, 90, 180]
    rots = [0, -20, -40, -62, 20, 40, 60, 80, 100, 118] if not quick else [0, -62, 118]
    jobs = {}
    jobs["fixed"] = ("module_fixed", {})
    jobs["gutter_closed"] = ("gutter", {"GATE_EXT": True})
    jobs["gutter_open"] = ("gutter", {"GATE_EXT": False})
    jobs["housing"] = ("housing", {})
    jobs["world"] = ("world", {})
    jobs["bottles"] = ("bottles", {})
    for p in phis:
        jobs[f"car_{p}"] = ("carriage", {"CAM_PHI": p})
        jobs[f"cam_{p}"] = ("cam", {"CAM_PHI": p})
    for a in rots:
        jobs[f"rot_{a}"] = ("rotor", {"ROT_ANG": a})
    with ThreadPoolExecutor(max_workers=os.cpu_count() or 4) as ex:
        fut = {k: ex.submit(export, g, **d) for k, (g, d) in jobs.items()}
        paths = {k: f.result() for k, f in fut.items()}
    print(f"{len(paths)} Gruppen exportiert")

    pairs = []
    statics = ["fixed", "gutter_closed", "housing", "world"]
    for a, b in itertools.combinations(statics, 2):
        pairs.append((a, b))
    for p in phis:
        for s in ["fixed", "gutter_closed", "housing", "world"]:
            pairs.append((f"car_{p}", s))
        for s in ["fixed", f"car_{p}", "world", "gutter_closed", "housing"]:
            pairs.append((f"cam_{p}", s))
    for a in rots:
        for s in ["housing", "gutter_closed", "gutter_open", "world", "fixed"]:
            pairs.append((f"rot_{a}", s))
    # Flaschen (Nominallage, Rotor in Ladestellung, Sperre zu)
    for s in ["fixed", "gutter_closed", "housing", "world", "rot_0", f"car_{phis[0]}"]:
        pairs.append(("bottles", s))
    pairs.append(("gutter_open", "housing"))

    bad = 0
    for a, b in pairs:
        v, bb = overlap(paths[a], paths[b])
        flag = "KOLLISION" if v > TOL else "ok"
        if v > TOL:
            bad += 1
            print(f"{flag:9s} {a:15s} x {b:15s}  {v:10.1f} mm3  bbox {bb}")
    print(f"{len(pairs)} Paare geprueft, {bad} Kollisionen")
    return 1 if bad else 0

if __name__ == "__main__":
    sys.exit(main())
