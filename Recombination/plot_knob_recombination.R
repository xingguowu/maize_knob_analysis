#!/usr/bin/env Rscript
# Plot recombination rate against proportion of each analysis window covered by knob.
# Usage: Rscript plot_knob_recombination.R annotated_windows.tsv output_prefix
args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 2) stop("Usage: Rscript plot_knob_recombination.R annotated_windows.tsv output_prefix", call. = FALSE)
if (!requireNamespace("ggplot2", quietly = TRUE)) stop("Install ggplot2 first.", call. = FALSE)
x <- read.delim(args[[1]], check.names = FALSE)
needed <- c("recomb_rate", "knob_fraction", "knob_overlap_bp")
if (!all(needed %in% names(x))) stop("Input must be made by knob_window_overlap.py.", call. = FALSE)
x$recomb_rate <- as.numeric(x$recomb_rate); x$knob_fraction <- as.numeric(x$knob_fraction)
x$class <- ifelse(x$knob_overlap_bp > 0, "knob-overlapping", "non-knob")
p <- ggplot2::ggplot(x, ggplot2::aes(knob_fraction, recomb_rate, colour = class)) + ggplot2::geom_point(alpha = .55, size = 1) + ggplot2::geom_smooth(method = "lm", se = TRUE, colour = "black") + ggplot2::scale_colour_manual(values = c("knob-overlapping" = "#0aa858", "non-knob" = "grey60")) + ggplot2::labs(x = "Window fraction covered by knob", y = "Recombination rate (input units)", colour = NULL) + ggplot2::theme_bw()
ggplot2::ggsave(paste0(args[[2]], ".pdf"), p, width = 7, height = 5)
write.table(aggregate(recomb_rate ~ class, x, mean, na.rm = TRUE), paste0(args[[2]], ".group_means.tsv"), sep = "\t", quote = FALSE, row.names = FALSE)
