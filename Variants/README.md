# Variant analysis

Place scripts and documentation here for knob-associated SNP, indel, structural-variant, or repeat presence/absence analyses. Document the reference assembly/annotation, sample set, software versions, filters, and treatment of repetitive regions. Report callable-site masks and missingness: knob regions are difficult to map.

## Included commands

`filter_variants.sh` normalizes multiallelic sites against a FASTA, retains biallelic SNPs, fills allele/missingness tags, then filters QUAL, minor-allele frequency, and missingness. It requires `bcftools` and `tabix`.

```bash
bash Variants/filter_variants.sh raw.vcf.gz B73.fa results/variants 30 0.05 0.8
bash Variants/extract_knob_variants.sh results/variants/filtered.snps.vcf.gz Variants/example_knobs.bed results/variants/knob.snps.vcf.gz
```

BED intervals are 0-based and half-open. `example_knobs.bed` is illustrative only: replace it with knob180 coordinates from the same assembly as the VCF.
