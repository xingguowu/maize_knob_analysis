#!/usr/bin/env Rscript
# Combine VCFtools windowed FST output and flag high-scoring windows.
# Usage: Rscript summarize_fst.R results/fst results/fst/fst_windows.tsv 0.99
args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 2 || length(args) > 3) stop("Usage: Rscript summarize_fst.R input_dir output.tsv [quantile=0.99]", call. = FALSE)
input_dir <- args[[1]]; output <- args[[2]]; threshold_q <- as.numeric(ifelse(length(args) == 3, args[[3]], .99))
if (!dir.exists(input_dir) || !is.finite(threshold_q) || threshold_q <= 0 || threshold_q >= 1) stop("Input directory must exist; quantile must be between 0 and 1.", call. = FALSE)
files <- list.files(input_dir, pattern = "windowed\\.weir\\.fst$", full.names = TRUE)
if (!length(files)) stop("No VCFtools *.windowed.weir.fst files found.", call. = FALSE)
read_one <- function(path) {
  x <- read.table(path, header = TRUE, sep = "\t", check.names = FALSE, stringsAsFactors = FALSE)
  names(x) <- sub("^MEAN_FST$", "mean_fst", names(x)); names(x) <- sub("^WEIGHTED_FST$", "weighted_fst", names(x))
  x$comparison <- sub("\\.windowed\\.weir\\.fst$", "", basename(path)); x
}
all_windows <- do.call(rbind, lapply(files, read_one))
score <- if ("weighted_fst" %in% names(all_windows)) all_windows$weighted_fst else all_windows$mean_fst
cutoff <- unname(quantile(score, threshold_q, na.rm = TRUE))
all_windows$high_fst <- !is.na(score) & score >= cutoff
write.table(all_windows, output, sep = "\t", quote = FALSE, row.names = FALSE)
writeLines(sprintf("quantile\t%s\ncutoff\t%s\n", threshold_q, cutoff), paste0(output, ".threshold.txt"))
message("Wrote ", nrow(all_windows), " windows; high-FST cutoff = ", signif(cutoff, 5))
