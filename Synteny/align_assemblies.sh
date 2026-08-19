#!/usr/bin/env bash
# Whole-assembly alignment suitable as a starting point for synteny inspection.
# Usage: bash align_assemblies.sh reference.fa query.fa output_dir [preset=asm5]
set -euo pipefail
if [[ $# -lt 3 || $# -gt 4 ]]; then echo "Usage: $0 reference.fa query.fa output_dir [preset=asm5]" >&2; exit 64; fi
reference=$1; query=$2; outdir=$3; preset=${4:-asm5}
for program in minimap2 sort awk; do command -v "$program" >/dev/null || { echo "Missing required program: $program" >&2; exit 69; }; done
[[ -r "$reference" && -r "$query" ]] || { echo "Reference or query FASTA cannot be read." >&2; exit 66; }
mkdir -p "$outdir"
minimap2 -x "$preset" -c --cs "$reference" "$query" > "$outdir/assembly_alignment.paf"
# PAF positions are 0-based, half-open. Retain primary alignments >=10 kb for browser loading.
awk 'BEGIN{OFS="\t"} $12=="tp:A:P" && $11>=10000 {print $6,$8,$9,$1":"$3"-"$4,$11,"+"}' "$outdir/assembly_alignment.paf" | sort -k1,1 -k2,2n > "$outdir/primary_alignments_10kb.bed"
echo "Wrote $outdir/assembly_alignment.paf and primary_alignments_10kb.bed"
