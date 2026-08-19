# Population differentiation (FST)

Place population-differentiation workflows here. State the estimator, window size/step, sample counts, variant filters, callable bases, and the handling of sparse windows. High FST in repeat-rich regions is not conclusive alone: inspect mapping bias, missingness, per-population allele counts, and matched genome-wide controls.

## Included commands

`calculate_fst.sh` runs every pairwise comparison represented by `populations/*.txt`, one sample ID per line. It uses VCFtools' Weir-Cockerham estimator and requires `vcftools`.

```bash
bash Fst/calculate_fst.sh results/variants/filtered.snps.vcf.gz Fst/populations results/fst 50000 10000
Rscript Fst/summarize_fst.R results/fst results/fst/fst_windows.tsv 0.99
```

The R summary adds a comparison name and a `high_fst` flag based on the supplied empirical quantile. It is a prioritization tool, not a significance test. Replace the illustrative sample files before analysis.
