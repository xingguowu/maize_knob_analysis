# Synteny analysis

Place genome-collinearity workflows here. Record assembly and annotation releases, alignment tool/parameters, and coordinate convention. For knob regions, combine anchor-based synteny with sequence alignment and flanking unique genes; a missing repeat alignment can result from assembly collapse or expansion rather than biological absence.

## Included commands

`align_assemblies.sh` produces a whole-assembly PAF alignment and a BED of primary alignments at least 10 kb long. It requires `minimap2`. `make_knob_flanks.sh` expands knob BED intervals while respecting chromosome boundaries; it requires `bedtools`.

```bash
bash Synteny/align_assemblies.sh B73.fa NAM_parent.fa results/synteny asm5
bash Synteny/make_knob_flanks.sh knobs.bed Synteny/example_genome.sizes results/synteny/knob_flanks_50kb.bed 50000
```

The example genome sizes are placeholders. Use the `.fai` or genome-size table corresponding to the assembly being queried.
