#!/usr/bin/env bash
# Extract variants overlapping knob intervals. BED input is 0-based, half-open.
# Usage: bash extract_knob_variants.sh filtered.vcf.gz knobs.bed output.vcf.gz
set -euo pipefail
if [[ $# -ne 3 ]]; then echo "Usage: $0 filtered.vcf.gz knobs.bed output.vcf.gz" >&2; exit 64; fi
vcf=$1; regions=$2; output=$3
for program in bcftools tabix; do command -v "$program" >/dev/null || { echo "Missing required program: $program" >&2; exit 69; }; done
[[ -r "$vcf" && -r "$regions" ]] || { echo "VCF or BED cannot be read." >&2; exit 66; }
mkdir -p "$(dirname "$output")"
bcftools view --regions-file "$regions" "$vcf" -Oz -o "$output"
tabix -f -p vcf "$output"
bcftools stats "$output" > "${output%.gz}.stats.txt"
echo "Extracted knob-overlapping variants: $output"
