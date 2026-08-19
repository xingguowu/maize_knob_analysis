#!/usr/bin/env Rscript
# Plot knob180 sequence-length distributions by population group.
# Usage: Rscript Frequency.R --input data/tr1_all_groups_lengths.txt --output-dir results

required <- c("ggplot2", "dplyr", "readr")
missing <- required[!vapply(required, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing)) stop("Install missing packages: ", paste(missing, collapse = ", "), call. = FALSE)
suppressPackageStartupMessages({ library(ggplot2); library(dplyr); library(readr) })

usage <- paste(
  "Usage: Rscript Frequency.R [options]", "",
  "Input is a TSV with ID, Length, Group columns (a header is optional).", "",
  "Options:",
  "  --input PATH          Input table (default: data/tr1_all_groups_lengths.txt)",
  "  --output-dir PATH     Output directory (default: results)",
  "  --binwidth NUMBER     Histogram bin width in bp (default: 1)",
  "  --x-min NUMBER        Minimum x-axis value (default: 100)",
  "  --x-max NUMBER        Maximum x-axis value (default: 380)",
  "  --top-n INTEGER       Number of common lengths per group (default: 20)",
  "  --help                Print this message", sep = "\n")

parse_args <- function(args) {
  opt <- list(input = "data/tr1_all_groups_lengths.txt", output_dir = "results", binwidth = 1, x_min = 100, x_max = 380, top_n = 20)
  if ("--help" %in% args) { cat(usage, "\n"); quit(status = 0) }
  if (length(args) %% 2) stop("Options must be supplied as --name value.\n\n", usage, call. = FALSE)
  for (i in seq(1, length(args), by = 2)) {
    key <- gsub("-", "_", sub("^--", "", args[[i]]))
    if (!key %in% names(opt)) stop("Unknown option: ", args[[i]], "\n\n", usage, call. = FALSE)
    opt[[key]] <- args[[i + 1]]
  }
  opt$binwidth <- as.numeric(opt$binwidth); opt$x_min <- as.numeric(opt$x_min)
  opt$x_max <- as.numeric(opt$x_max); opt$top_n <- as.integer(opt$top_n)
  if (any(!is.finite(unlist(opt[c("binwidth", "x_min", "x_max", "top_n")]))) || opt$binwidth <= 0 || opt$x_min >= opt$x_max || opt$top_n < 1) stop("Invalid numeric option values.", call. = FALSE)
  opt
}

read_lengths <- function(path) {
  if (!file.exists(path)) stop("Input file does not exist: ", path, call. = FALSE)
  line <- readLines(path, n = 1, warn = FALSE)
  if (!length(line) || !nzchar(line)) stop("Input file is empty: ", path, call. = FALSE)
  has_header <- identical(tolower(strsplit(line, "\\t")[[1]][1]), "id")
  dat <- read_tsv(path, col_names = has_header, show_col_types = FALSE, progress = FALSE)
  if (!has_header) { if (ncol(dat) != 3) stop("Headerless input must have three columns: ID, Length, Group.", call. = FALSE); names(dat) <- c("ID", "Length", "Group") }
  if (!all(c("ID", "Length", "Group") %in% names(dat))) stop("Input must contain ID, Length, Group columns.", call. = FALSE)
  dat %>% transmute(ID = as.character(ID), Length = suppressWarnings(as.numeric(Length)), Group = as.character(Group)) %>% filter(!is.na(Length), !is.na(Group), nzchar(Group))
}

opt <- parse_args(commandArgs(trailingOnly = TRUE))
length_data <- read_lengths(opt$input)
if (!nrow(length_data)) stop("No valid records remain after input validation.", call. = FALSE)
dir.create(opt$output_dir, recursive = TRUE, showWarnings = FALSE)
length_data$Group <- factor(length_data$Group, levels = unique(length_data$Group))
group_colors <- setNames(scales::hue_pal()(nlevels(length_data$Group)), levels(length_data$Group))

p <- ggplot(length_data, aes(Length, fill = Group)) +
  geom_histogram(binwidth = opt$binwidth, alpha = .85, color = "black", linewidth = .2) +
  facet_wrap(~ Group, scales = "free_y", ncol = 1) + scale_fill_manual(values = group_colors) +
  scale_y_continuous(expand = expansion(mult = c(0, .05))) + coord_cartesian(xlim = c(opt$x_min, opt$x_max)) +
  labs(x = "Sequence length (bp)", y = "Count", title = "Histogram of knob180 lengths by group") +
  theme_bw() + theme(panel.grid = element_blank(), strip.background = element_blank(), strip.text = element_text(face = "bold"), legend.position = "none")

top_lengths <- length_data %>% count(Group, Length, name = "Count", sort = TRUE) %>% group_by(Group) %>% slice_max(Count, n = opt$top_n, with_ties = FALSE) %>% arrange(Group, desc(Count), Length) %>% mutate(Rank = row_number()) %>% ungroup() %>% select(Group, Rank, Length, Count)
summary_by_group <- length_data %>% group_by(Group) %>% summarise(n_sequences = n(), min_length_bp = min(Length), median_length_bp = median(Length), mean_length_bp = mean(Length), max_length_bp = max(Length), .groups = "drop")
ggsave(file.path(opt$output_dir, "knob180_length_histogram.pdf"), p, width = 8, height = 5, dpi = 300)
write_tsv(top_lengths, file.path(opt$output_dir, "top_lengths_by_group.tsv"))
write_tsv(summary_by_group, file.path(opt$output_dir, "length_summary_by_group.tsv"))
message("Wrote results to: ", normalizePath(opt$output_dir))
