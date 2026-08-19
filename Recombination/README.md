# Knob and recombination

The reference analysis included chromosome-wide rates and local tests contrasting knob-rich, low-knob, and knob-free windows. This module separates the calculation from the interpretation: it annotates each existing recombination window with exact knob overlap and nearest-array distance, preserving the rate units provided by the caller.

```bash
python3 Recombination/knob_window_overlap.py recombination_windows.tsv knob_arrays.bed results/recombination/annotated_windows.tsv
Rscript Recombination/plot_knob_recombination.R results/recombination/annotated_windows.tsv results/recombination/knob_overlap
```

`recombination_windows.tsv` must have `chrom`, `start`, `end`, and `recomb_rate` columns. Use consistent genome assemblies and coordinate systems. The scatterplot is descriptive; test effects with a model that controls for chromosome, centromere distance, TE density, callable sequence, and window autocorrelation.
