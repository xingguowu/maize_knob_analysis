#!/usr/bin/env bash
# Merge nearby monomer hits into knob arrays while retaining family/orientation summaries.
# Input BED columns: chrom, start, end, family, copies, strand. BED is 0-based, half-open.
# Usage: bash merge_knob_arrays.sh monomer_hits.bed output.bed [max_gap_bp=10000]
set -euo pipefail
if [[ $# -lt 2 || $# -gt 3 ]]; then echo "Usage: $0 monomer_hits.bed output.bed [max_gap_bp=10000]" >&2; exit 64; fi
input=$1; output=$2; gap=${3:-10000}
for p in bedtools sort; do command -v "$p" >/dev/null || { echo "Missing required program: $p" >&2; exit 69; }; done
[[ -s "$input" ]] || { echo "Input BED is empty or unreadable: $input" >&2; exit 66; }
mkdir -p "$(dirname "$output")"
# Do not merge across strands: adjacent opposite-orientation arrays remain distinguishable.
bedtools sort -i "$input" | bedtools merge -d "$gap" -s -c 4,5,6 -o distinct,sum,distinct > "$output"
echo "Wrote merged arrays: $output"
