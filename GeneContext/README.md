# Genes near knob arrays

`nearest_genes.py` identifies the nearest gene for each knob array using interval distance. It is a transparent first pass for the nearby-gene analysis represented in the source materials.

```bash
python3 GeneContext/nearest_genes.py knob_arrays.bed genes.bed results/gene_context/nearest_genes.tsv
```

Inputs use BED coordinates (0-based, half-open); the fourth gene BED field is reported as the gene ID. This does not test regulatory impact. For expression analyses, use matched control regions and report gene-ID version conversion, expression normalization, and the treatment of genes overlapping an array.
