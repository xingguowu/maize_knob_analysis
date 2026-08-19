#!/usr/bin/env python3
"""Summarize merged knob arrays (BED6: chrom start end families copies strands)."""
import argparse, csv, os
from collections import defaultdict

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("arrays_bed", help="Merged BED6 output from merge_knob_arrays.sh")
parser.add_argument("output_prefix", help="Prefix for .arrays.tsv and .chromosomes.tsv")
args = parser.parse_args()

arrays, chrom = [], defaultdict(lambda: [0, 0, 0])
with open(args.arrays_bed, encoding="utf-8") as handle:
    for n, row in enumerate(csv.reader(handle, delimiter="\t"), 1):
        if not row or row[0].startswith("#"): continue
        if len(row) < 6: raise ValueError(f"Line {n}: expected BED6, found {len(row)} fields")
        start, end = int(row[1]), int(row[2])
        if start < 0 or end <= start: raise ValueError(f"Line {n}: invalid interval")
        length, copies = end - start, float(row[4])
        arrays.append([row[0], start, end, length, row[3], copies, row[5]])
        chrom[row[0]][0] += 1; chrom[row[0]][1] += length; chrom[row[0]][2] += copies
if not arrays: raise ValueError("No arrays found")
os.makedirs(os.path.dirname(args.output_prefix) or ".", exist_ok=True)
with open(args.output_prefix + ".arrays.tsv", "w", newline="", encoding="utf-8") as out:
    writer = csv.writer(out, delimiter="\t"); writer.writerow(["chrom", "start", "end", "array_length_bp", "families", "monomer_copy_sum", "strands"]); writer.writerows(arrays)
with open(args.output_prefix + ".chromosomes.tsv", "w", newline="", encoding="utf-8") as out:
    writer = csv.writer(out, delimiter="\t"); writer.writerow(["chrom", "n_arrays", "total_array_bp", "monomer_copy_sum"])
    for name in sorted(chrom): writer.writerow([name] + chrom[name])
print(f"Wrote {len(arrays)} arrays to {args.output_prefix}.arrays.tsv")
