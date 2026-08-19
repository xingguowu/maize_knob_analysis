#!/usr/bin/env bash
# Make clipped flanking windows around knob annotations for unique-anchor checks.
# Usage: bash make_knob_flanks.sh knobs.bed genome.sizes output.bed [flank_bp=50000]
set -euo pipefail
if [[ $# -lt 3 || $# -gt 4 ]]; then echo "Usage: $0 knobs.bed genome.sizes output.bed [flank_bp=50000]" >&2; exit 64; fi
knobs=$1; sizes=$2; output=$3; flank=${4:-50000}
command -v bedtools >/dev/null || { echo "Missing required program: bedtools" >&2; exit 69; }
[[ -r "$knobs" && -r "$sizes" ]] || { echo "BED or genome sizes file cannot be read." >&2; exit 66; }
mkdir -p "$(dirname "$output")"
bedtools slop -i "$knobs" -g "$sizes" -b "$flank" > "$output"
echo "Wrote flanking windows: $output"
