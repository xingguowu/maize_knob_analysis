#!/usr/bin/env python3
"""Cluster knob monomer FASTA sequences by canonical k-mer composition."""
import argparse, csv, os
from collections import Counter
import numpy as np
try:
    from sklearn.feature_extraction import DictVectorizer
    from sklearn.cluster import MiniBatchKMeans
except ImportError as error:
    raise SystemExit("Missing dependency: scikit-learn. Install project Python dependencies with: python3 -m pip install -r requirements.txt") from error

def fasta(path):
    name, seq = None, []
    for line in open(path, encoding="utf-8"):
        line = line.strip()
        if line.startswith(">"):
            if name: yield name, "".join(seq)
            name, seq = line[1:].split()[0], []
        elif line: seq.append(line.upper())
    if name: yield name, "".join(seq)
def canonical(kmer): return min(kmer, kmer.translate(str.maketrans("ACGT", "TGCA"))[::-1])
p = argparse.ArgumentParser(description=__doc__); p.add_argument("fasta"); p.add_argument("output_prefix"); p.add_argument("--k", type=int, default=15); p.add_argument("--clusters", type=int, default=7); args = p.parse_args()
records = list(fasta(args.fasta))
if len(records) < args.clusters: raise ValueError("Number of sequences must be at least --clusters")
features = [Counter(canonical(s[i:i+args.k]) for i in range(len(s)-args.k+1) if set(s[i:i+args.k]) <= set("ACGT")) for _, s in records]
X = DictVectorizer(dtype=np.float32).fit_transform(features)
labels = MiniBatchKMeans(n_clusters=args.clusters, random_state=42, n_init=10, batch_size=4096).fit_predict(X)
os.makedirs(os.path.dirname(args.output_prefix) or ".", exist_ok=True)
with open(args.output_prefix + ".clusters.tsv", "w", newline="") as out:
    w = csv.writer(out, delimiter="\t"); w.writerow(["sequence_id", "length_bp", "cluster"]); w.writerows((n, len(s), int(c)) for (n,s), c in zip(records, labels))
print(f"Wrote clusters for {len(records)} sequences")
