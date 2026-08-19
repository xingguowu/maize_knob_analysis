#!/usr/bin/env bash
# Normalize and filter a VCF before population analyses.
# Usage: bash filter_variants.sh input.vcf.gz reference.fa output_dir [min_qual] [min_maf] [max_missing]
set -euo pipefail

if [[ $# -lt 3 || $# -gt 6 ]]; then
  echo "Usage: $0 input.vcf.gz reference.fa output_dir [min_qual=30] [min_maf=0.05] [max_missing=0.8]" >&2
  exit 64
fi
vcf=$1; reference=$2; outdir=$3; min_qual=${4:-30}; min_maf=${5:-0.05}; max_missing=${6:-0.8}
for program in bcftools tabix; do command -v "$program" >/dev/null || { echo "Missing required program: $program" >&2; exit 69; }; done
[[ -r "$vcf" ]] || { echo "Cannot read VCF: $vcf" >&2; exit 66; }
[[ -r "$reference" ]] || { echo "Cannot read reference FASTA: $reference" >&2; exit 66; }
mkdir -p "$outdir"

# Keep biallelic SNPs. Change -v snps deliberately if indels/SVs are in scope.
bcftools norm --fasta-ref "$reference" --multiallelics -any --check-ref w "$vcf" -Ou \
  | bcftools view --types snps --min-ac 1:n -Ou \
  | bcftools +fill-tags -Ou -- -t AN,AC,AF,F_MISSING \
  | bcftools view --include "QUAL>=${min_qual} && MAF>=${min_maf} && F_MISSING<=${max_missing}" -Oz -o "$outdir/filtered.snps.vcf.gz"
tabix -f -p vcf "$outdir/filtered.snps.vcf.gz"
bcftools stats "$outdir/filtered.snps.vcf.gz" > "$outdir/filtered.snps.stats.txt"
bcftools query -f '%CHROM\t%POS\t%REF\t%ALT\t%QUAL\t%INFO/AF\t%INFO/F_MISSING\n' "$outdir/filtered.snps.vcf.gz" > "$outdir/filtered.snps.site_metrics.tsv"
echo "Filtered VCF: $outdir/filtered.snps.vcf.gz"
