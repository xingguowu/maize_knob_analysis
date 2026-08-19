#!/usr/bin/env bash
# Pairwise Weir-Cockerham FST in fixed genomic windows using VCFtools.
# Usage: bash calculate_fst.sh filtered.vcf.gz population_lists_dir output_dir [window_bp] [step_bp]
set -euo pipefail
if [[ $# -lt 3 || $# -gt 5 ]]; then echo "Usage: $0 filtered.vcf.gz population_lists_dir output_dir [window_bp=50000] [step_bp=10000]" >&2; exit 64; fi
vcf=$1; popdir=$2; outdir=$3; window=${4:-50000}; step=${5:-10000}
command -v vcftools >/dev/null || { echo "Missing required program: vcftools" >&2; exit 69; }
[[ -r "$vcf" && -d "$popdir" ]] || { echo "VCF or population-list directory cannot be read." >&2; exit 66; }
mkdir -p "$outdir"
mapfile -t populations < <(find "$popdir" -maxdepth 1 -type f -name '*.txt' -print | sort)
[[ ${#populations[@]} -ge 2 ]] || { echo "Provide at least two *.txt population files in $popdir." >&2; exit 65; }
for pop in "${populations[@]}"; do [[ -s "$pop" ]] || { echo "Empty population file: $pop" >&2; exit 65; }; done
for ((i=0; i<${#populations[@]}-1; i++)); do
  for ((j=i+1; j<${#populations[@]}; j++)); do
    left=$(basename "${populations[i]}" .txt); right=$(basename "${populations[j]}" .txt); prefix="$outdir/${left}_vs_${right}"
    vcftools --gzvcf "$vcf" --weir-fst-pop "${populations[i]}" --weir-fst-pop "${populations[j]}" --fst-window-size "$window" --fst-window-step "$step" --out "$prefix"
  done
done
echo "FST tables written to: $outdir"
