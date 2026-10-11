#!/usr/bin/env python3
"""Funktionspruefung der Flaschenfuehrung (Geometrie, inkl. Toleranzen).

1. Lichtschranken-Logik im Rotor: Orientierung / Praesenz fuer beide Lagen,
   Nennmass und Grenzmasse (L 101.5..103.5, D 29.7..30.3).
2. Abwurf "Boden am Anschlag" (Rotor -62 Grad): noetige Einwaertsverschiebung
   der Flasche entlang des Weges (muss klein und stetig sein -> Rampe).
3. Abwurf "Hals am Anschlag" (Rotor +118): Hals in Nut frei bis Abrutschen,
   danach Flasche am Einlaufende frei bis zur Abwurfoeffnung.
4. Freier Fall durch Oeffnung/Schacht, Auslauf auf dem Band unter dem Gehaeuse.
5. Rinnendurchlauf (Sperre/Klemme offen) G1 -> G2 -> Rotor.
"""
import os, sys, threading, subprocess, hashlib, json
from concurrent.futures import ThreadPoolExecutor
import numpy as np, trimesh, manifold3d as m3d

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.dirname(__file__))
import check_collisions as cc

FS = os.path.join(ROOT, "cad", "checks", "function.scad")
OUT = os.path.join(ROOT, "build", "function"); os.makedirs(OUT, exist_ok=True)

def fexport(**d):
    dd = {k: (f'"{v}"' if isinstance(v, str) else (str(v).lower() if isinstance(v, bool) else repr(v))) for k, v in d.items()}
    dd["SIMPLE"] = "true"
    key = hashlib.md5((cc.SRC + json.dumps(dd, sort_keys=True)).encode()).hexdigest()[:12]
    path = os.path.join(OUT, f"{d.get('MODE','x')}_{key}.stl")
    if not os.path.exists(path):
        tmp = path + f".{os.getpid()}.{threading.get_ident()}.tmp.stl"
        args = ["openscad", "-o", tmp]
        for k, v in dd.items(): args += ["-D", f"{k}={v}"]
        args.append(FS)
        r = subprocess.run(args, capture_output=True, text=True, timeout=1800)
        if os.path.exists(tmp): os.replace(tmp, path)
        if not os.path.exists(path):
            print(r.stderr[-1500:]); raise RuntimeError(str(d))
    return path

def vol(pa, pb):
    return (cc.load(pa) ^ cc.load(pb)).volume()

def pmap(fn, items):
    with ThreadPoolExecutor(max_workers=os.cpu_count() or 4) as ex:
        return list(ex.map(fn, items))

TOLS = [(102.5, 30.0), (101.5, 29.7), (103.5, 30.3), (101.5, 30.3), (103.5, 29.7)]
HOU = None
def main():
    ok = True
    global HOU
    HOU = fexport(MODE="housing_only")
    rotor0 = fexport(MODE="rotor_at", A=0)
    beams = {b: fexport(MODE="beam", BEAM=b) for b in ["orient", "pres"]}

    # ---- 1. Lichtschranken
    print("1) Lichtschranken im Rotor (Ladestellung)")
    # Endlage: Boden am Anschlag -> Boden bei s = 58.58 (Landungen der Halsnut)
    #          Hals am Anschlag  -> Schulter auf Nutkanten (s=59), Halsspitze s = 59 + 17.1
    for (L, D) in TOLS:
        cases = {"Boden am Anschlag": (58.5, -1), "Hals am Anschlag": (59 + 16.8 - L, +1)}
        for name, (s0, dr) in cases.items():
            b = fexport(MODE="rotor_bottle", A=0, S0=s0, DIR=dr, BL=L, BD=D)
            vo, vp = vol(b, beams["orient"]), vol(b, beams["pres"])
            vh, vr = vol(b, HOU), vol(b, rotor0)
            want_o = name.startswith("Boden")
            good = (vo > 0.5) == want_o and vp > 0.5 and vh < 2 and vr < 2
            ok &= good
            print(f"   L={L:5.1f} D={D:4.1f} {name:18s} Orient={'belegt' if vo>0.5 else 'frei ':6s} "
                  f"Praesenz={'belegt' if vp>0.5 else 'frei'}  Ueberschn. Geh={vh:5.2f} Rot={vr:5.2f}  {'OK' if good else 'FEHLER'}")

    # ---- 2. Abwurf Boden am Anschlag (-62)
    print("2) Abwurf 'Boden am Anschlag' (Rotor 0 -> -62): noetige Einwaertsverschiebung")
    angs = list(range(0, -63, -4)) + [-62]
    def need_shift(a, L=103.5, D=30.3):
        for sh in [0, 0.25, 0.5, 0.75, 1.0, 1.5, 2.0, 2.5, 3.0, 4.0, 6.0]:
            b = fexport(MODE="rotor_bottle", A=a, S0=58.5, DIR=-1, SHIFT=-sh, BL=L, BD=D)
            if vol(b, HOU) < 1.0: return sh
        return None
    res = pmap(need_shift, angs)
    print("   Winkel : " + " ".join(f"{a:5d}" for a in angs))
    print("   Shift  : " + " ".join(f"{(r if r is not None else -1):5.2f}" for r in res))
    ok &= all(r is not None and r <= 2.0 for r in res)

    # ---- 3. Abwurf Hals am Anschlag (+118)
    print("3) Abwurf 'Hals am Anschlag' (Rotor 0 -> +118)")
    L, D = 103.5, 30.3
    s_neck = 59 + 16.8 - L
    a1 = list(range(0, 119, 6))
    r1 = pmap(lambda a: vol(fexport(MODE="rotor_bottle", A=a, S0=s_neck, DIR=1, BL=L, BD=D), HOU), a1)
    print("   Hals in Nut, starr  : " + " ".join(f"{a}:{v:.1f}" for a, v in zip(a1, r1)))
    # Flasche nach dem Abrutschen am Einlaufende (Boden am Gehaeuse r=59, |n|<=15 -> s=-57.06)
    a2 = list(range(30, 119, 8)) + [118]
    r2 = pmap(lambda a: vol(fexport(MODE="rotor_bottle", A=a, S0=-57.0, DIR=1, BL=L, BD=D), HOU), a2)
    print("   am Einlaufende      : " + " ".join(f"{a}:{v:.1f}" for a, v in zip(a2, r2)))
    first_hit = next((a for a, v in zip(a1, r1) if v > 1.0), None)
    print(f"   -> Hals muss vor Rotorwinkel {first_hit} Grad aus der Nut gerutscht sein (Firmware: Haltepunkt)")
    ok &= all(v < 1.0 for v in r2)

    # ---- 4. Fall + Auslauf
    print("4) Freier Fall und Auslauf")
    from math import isclose
    shaft = fexport(MODE="shaft_only")
    ROT_Z = 900 + 172; BELT = 900
    zs = [float(z) for z in np.arange(ROT_Z - 59.0, BELT - 0.1, -10)] + [float(BELT)]
    # frei fallend: Achse im Schacht zwischen V-Anlage und Dach (n = 0..+3.5) und X +-1.2
    # Achse frei im Schacht: n = 0..+3.2 (V-Anlage .. Dach), X +-1.0.  Sobald der Boden im
    # Trichter/Fallschacht ist (Z < ROT_Z-50) fuehrt der Trichter auf |Y| <= 16.75-15.15 = 1.6.
    RH = {a: fexport(MODE="rotor_housing_at", A=a) for a in (-62, 118)}
    def fall(z):
        worst = 0
        # zulaessige Lagen (px,py): im V nur px~0, mit Abstand zum V auch seitlich
        pts = [(0.0, 0.3), (0.0, 1.6), (-1.0, 1.6), (1.0, 1.6)]
        if z > ROT_Z - 50: pts += [(0.0, 3.2), (-1.0, 3.2), (1.0, 3.2)]
        for a, sgn in [(-62, 1), (118, -1)]:
            for D in [30.3, 29.7]:
                for px, py in pts:
                    if True:
                        b = fexport(MODE="bottle_world", PX=px, PY=sgn*py, PZ=round(z, 2), BL=103.5, BD=D)
                        worst = max(worst, vol(b, RH[a]), vol(b, shaft))
        return worst
    rf = pmap(fall, zs)
    print("   Fall (Z Boden: max. Ueberschneidung aller Varianten): " + " ".join(f"{z:.0f}:{v:.1f}" for z, v in zip(zs, rf)))
    ok &= all(v < 1.0 for v in rf)
    xs = list(range(0, 141, 10))
    housing_grp = cc.export("housing")
    rx = pmap(lambda x: vol(fexport(MODE="bottle_world", PX=float(x), PY=0.0, PZ=float(BELT), BL=103.5, BD=30.3), housing_grp), xs)
    print("   Auslauf auf Band (X, Ueberschn.): " + " ".join(f"{x}:{v:.1f}" for x, v in zip(xs, rx)))
    ok &= all(v < 1.0 for v in rx)

    # ---- 5. Rinnendurchlauf
    print("5) Rinnendurchlauf (Sperre + Klemme offen)")
    g_open = cc.export("gutter", GATE_EXT=False)
    fixed = cc.export("module_fixed")
    ss = list(range(-470, 0, 15))
    def gut(s, dr):
        b = fexport(MODE="bottle_gutter", S0=float(s), DIR=dr, BL=103.5, BD=30.3)
        return max(vol(b, g_open), vol(b, HOU), vol(b, rotor0), vol(b, fixed))
    rg = pmap(lambda s: max(gut(s, 1), gut(s + 103.5, -1)), [s for s in ss if s + 103.5 <= 58.5])
    print("   s:Ueberschn. " + " ".join(f"{s}:{v:.1f}" for s, v in zip(ss, rg)))
    ok &= all(v < 1.0 for v in rg)

    print("ERGEBNIS:", "ALLE FUNKTIONSPRUEFUNGEN OK" if ok else "FEHLER GEFUNDEN")
    return 0 if ok else 1

if __name__ == "__main__":
    sys.exit(main())
