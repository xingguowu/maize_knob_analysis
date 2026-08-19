# Maize knob analysis

Reproducible utilities for exploring maize knob180 repeat variation. The repository currently provides a length-frequency workflow; `Variants`, `Fst`, and `Synteny` reserve clear homes for downstream analyses.

## Current workflow

`Frequency.R` reads a tab-separated table of knob180 sequence lengths and population groups. It validates the input and writes a faceted histogram (`knob180_length_histogram.pdf`), the most frequent lengths per group (`top_lengths_by_group.tsv`), and a group-level descriptive summary (`length_summary_by_group.tsv`). Groups are derived from the input rather than hard-coded, so the script works for any population scheme.

Install the R dependencies once:

```r
install.packages(c("ggplot2", "dplyr", "readr"))
```

Run the included example:

```bash
Rscript Frequency.R --input data/example_lengths.tsv --output-dir results/example
```

Run an analysis table:

```bash
Rscript Frequency.R --input /path/to/tr1_all_groups_lengths.txt --output-dir results/length_frequency --binwidth 1 --x-min 100 --x-max 380 --top-n 20
```

Use `Rscript Frequency.R --help` for options. Generated results are ignored by Git.

## Input format

Input must be UTF-8, tab-separated, with the following columns. A header is optional; headerless files must use this exact order.

```text
ID\tLength\tGroup
ZM001\t180\tTemperate
ZM002\t190\tTropical
```

`Length` must be numeric and is assumed to be base pairs. Rows with missing/non-numeric lengths or missing groups are excluded; the script stops if no valid data remains.

## Layout

```text
Frequency.R       reproducible length-frequency analysis
data/             small, versioned example input only
results/          generated output (ignored)
Variants/         VCF normalization/filtering and knob-interval extraction
Fst/              pairwise windowed FST calculation and summarization
Synteny/          assembly alignment and knob-flanking-window utilities
```

## Interpretation notes

Length distributions are descriptive. Apparent group differences may reflect biological variation, sequencing/assembly quality, repeat annotation settings, or filtering. Before comparing groups, record the reference genome, detection method, thresholds, samples per group, and whether each value represents a repeat, an array, or a genome. For inference, pre-specify tests and account for relatedness and unequal group sizes.

Do not commit raw reads, assemblies, BAM/CRAM, VCF, or large intermediates. Every future analysis folder should document inputs, reference/software versions, commands, output fields, and biological question.

## External command-line tools

The R length plot needs `ggplot2`, `dplyr`, and `readr`. The optional genomics workflows additionally use `bcftools`/`tabix` (Variants), `vcftools` (FST), and `minimap2` plus `bedtools` (Synteny). Their directory READMEs give exact commands and coordinate conventions.
