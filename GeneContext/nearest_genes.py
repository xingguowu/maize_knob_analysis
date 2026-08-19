#!/usr/bin/env python3
"""Report genes nearest to each knob array. Both inputs are BED, 0-based/half-open."""
import argparse, csv, os
from collections import defaultdict
p = argparse.ArgumentParser(description=__doc__); p.add_argument("knobs_bed"); p.add_argument("genes_bed"); p.add_argument("output_tsv"); args = p.parse_args()
genes = defaultdict(list)
with open(args.genes_bed) as f:
    for r in csv.reader(f, delimiter="\t"):
        if r and not r[0].startswith("#"): genes[r[0]].append((int(r[1]), int(r[2]), r[3] if len(r)>3 else "."))
for chrom in genes: genes[chrom].sort()
os.makedirs(os.path.dirname(args.output_tsv) or ".", exist_ok=True)
with open(args.output_tsv, "w", newline="") as out:
    w=csv.writer(out, delimiter="\t"); w.writerow(["knob_chrom","knob_start","knob_end","nearest_gene","gene_start","gene_end","distance_bp"])
    for r in csv.reader(open(args.knobs_bed), delimiter="\t"):
        if not r or r[0].startswith("#"): continue
        s,e=int(r[1]),int(r[2]); candidates=genes[r[0]]
        if not candidates: w.writerow(r[:3]+["", "", "", ""]); continue
        dist=lambda g:max(0, g[0]-e, s-g[1]); g=min(candidates,key=dist); w.writerow([r[0],s,e,g[2],g[0],g[1],dist(g)])
