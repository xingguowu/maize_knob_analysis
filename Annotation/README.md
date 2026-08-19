# Knob annotation and array construction

Knob calls commonly start as monomer-level hits. `merge_knob_arrays.sh` joins nearby, same-strand hits into arrays, retaining distinct repeat families, total monomer counts, and strand. The default maximum gap is 10 kb, matching the “merge nearby hits” logic in the original exploratory scripts, but it is an analytical parameter rather than a biological constant.

```bash
bash Annotation/merge_knob_arrays.sh monomer_hits.bed results/annotation/knob_arrays.bed 10000
python3 Annotation/summarize_arrays.py results/annotation/knob_arrays.bed results/annotation/knob
```

The monomer BED needs six fields: chromosome, 0-based start, end, family (`knob180`, `TR-1`, or another label), copy count, and strand. The included `example_monomer_hits.bed` illustrates the schema only.
