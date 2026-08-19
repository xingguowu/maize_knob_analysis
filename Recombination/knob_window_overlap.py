#!/usr/bin/env python3
"""Add knob overlap and nearest-knob distance to recombination windows.

Windows TSV must have: chrom, start, end, recomb_rate. BED knob intervals are 0-based,
half-open. Output rates are retained exactly as supplied; no unit conversion is assumed.
"""
import argparse, csv, os
from bisect import bisect_left
from collections import defaultdict

p = argparse.ArgumentParser(description=__doc__)
p.add_argument("windows_tsv"); p.add_argument("knobs_bed"); p.add_argument("output_tsv")
args = p.parse_args()
knobs = defaultdict(list)
with open(args.knobs_bed, encoding="utf-8") as f:
    for row in csv.reader(f, delimiter="\t"):
        if row and not row[0].startswith("#"): knobs[row[0]].append((int(row[1]), int(row[2])))
for chrom in knobs: knobs[chrom].sort()
os.makedirs(os.path.dirname(args.output_tsv) or ".", exist_ok=True)
with open(args.windows_tsv, encoding="utf-8") as inp, open(args.output_tsv, "w", newline="", encoding="utf-8") as out:
    reader = csv.DictReader(inp, delimiter="\t")
    required = {"chrom", "start", "end", "recomb_rate"}
    if not reader.fieldnames or not required.issubset(reader.fieldnames): raise ValueError("Windows TSV needs columns: chrom, start, end, recomb_rate")
    fields = reader.fieldnames + ["knob_overlap_bp", "knob_fraction", "nearest_knob_midpoint_distance_bp"]
    writer = csv.DictWriter(out, fieldnames=fields, delimiter="\t"); writer.writeheader()
    for row in reader:
        start, end = int(row["start"]), int(row["end"]); intervals = knobs[row["chrom"]]; overlap = sum(max(0, min(end, e) - max(start, s)) for s, e in intervals)
        midpoint = (start + end) / 2; distances = [max(0, s - midpoint, midpoint - e) for s, e in intervals]
        row.update(knob_overlap_bp=overlap, knob_fraction=overlap / (end - start), nearest_knob_midpoint_distance_bp=min(distances) if distances else "")
        writer.writerow(row)
print(f"Wrote annotated windows: {args.output_tsv}")
