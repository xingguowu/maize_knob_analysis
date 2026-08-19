# Knob monomer sequence analysis

`kmer_cluster.py` clusters monomer FASTA records using canonical k-mer composition, so reverse complements receive the same feature representation. It is suitable for exploratory subfamily detection in knob180/TR-1 monomers.

```bash
python3 Sequence/kmer_cluster.py knob_monomers.fa results/sequence/knob180 --k 15 --clusters 7
```

Install its Python dependencies with `python3 -m pip install -r requirements.txt`. Cluster number and k-mer length should be selected from diagnostics and biological reasoning; cluster labels are arbitrary and must be interpreted with representative sequences, length distribution, and genomic positions.
