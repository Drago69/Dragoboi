#!/usr/bin/env python3
"""Kollisionspruefung der Gesamtbaugruppe ueber alle Bewegungszustaende.

Exportiert Baugruppen-Gruppen (SIMPLE=true, Profile als Vollquadrat) aus
cad/assembly.scad als STL und schneidet sie paarweise mit manifold3d.
Ein Ueberlapp > TOL mm^3 gilt als Kollision.

Gruppen: Tellerrahmen, Bunker, Uebergabe, Haube, Rinne, Gehaeuse, Gestell, Flaschen;
Teller (mit Taschenflaschen) ueber eine Hakenteilung, Rotor ueber alle Winkel.
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
        # flaechige Beruehrung (Anlageflaechen) ist keine Kollision: mittlere Dicke < 0.1 mm
        m = i.to_mesh(); tri = np.asarray(m.tri_verts); vp = np.asarray(m.vert_properties)[:, :3]
        area = np.linalg.norm(np.cross(vp[tri[:,1]] - vp[tri[:,0]], vp[tri[:,2]] - vp[tri[:,0]]), axis=1).sum()/2
        if 2*v/max(area, 1e-9) < 0.1:
            return 0.0, None
        mn, mx = i.bounding_box()[:3], i.bounding_box()[3:]
        bb = [round(x, 1) for x in list(mn) + list(mx)]
    return v, bb

def main():
    quick = "--quick" in sys.argv
    phis = list(range(0, 36, 3)) if not quick else [0, 12, 24]          # Tellerwinkel (eine Teilung 36 Grad)
    rots = [0, -20, -40, -62, 20, 40, 60, 80, 100, 118] if not quick else [0, -62, 118]
    jobs = {}
    jobs["frame"] = ("teller_frame", {})
    jobs["hopper"] = ("hopper", {})
    jobs["transfer"] = ("transfer", {})
    jobs["hood"] = ("hood", {})
    jobs["gutter_closed"] = ("gutter", {"GATE_EXT": True})
    jobs["gutter_open"] = ("gutter", {"GATE_EXT": False})
    jobs["housing"] = ("housing", {})
    jobs["world"] = ("world", {})
    jobs["bottles"] = ("bottles", {})
    for p in phis:
        jobs[f"disc_{p}"] = ("disc", {"TD_PHI": p})
    for a in rots:
        jobs[f"rot_{a}"] = ("rotor", {"ROT_ANG": a})
    with ThreadPoolExecutor(max_workers=os.cpu_count() or 4) as ex:
        fut = {k: ex.submit(export, g, **d) for k, (g, d) in jobs.items()}
        paths = {k: f.result() for k, f in fut.items()}
    print(f"{len(paths)} Gruppen exportiert")

    statics = ["frame", "hopper", "transfer", "hood", "gutter_closed", "housing", "world"]
    pairs = list(itertools.combinations(statics, 2))
    for p in phis:
        for s in ["frame", "hopper", "transfer", "hood", "gutter_closed", "world", "bottles"]:
            pairs.append((f"disc_{p}", s))
    for a in rots:
        for s in ["housing", "gutter_closed", "gutter_open", "world"]:
            pairs.append((f"rot_{a}", s))
    for s in statics + ["rot_0"]:
        pairs.append(("bottles", s))
    pairs.append(("gutter_open", "housing"))
    pairs.append(("gutter_open", "transfer"))

    bad = 0
    for a, b in pairs:
        v, bb = overlap(paths[a], paths[b])
        if v > TOL:
            bad += 1
            print(f"KOLLISION {a:15s} x {b:15s}  {v:10.1f} mm3  bbox {bb}")
    print(f"{len(pairs)} Paare geprueft, {bad} Kollisionen")
    return 1 if bad else 0

if __name__ == "__main__":
    sys.exit(main())
