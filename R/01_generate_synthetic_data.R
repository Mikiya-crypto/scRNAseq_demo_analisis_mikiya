# R/01_generate_synthetic_data.R
# Generates a small synthetic scRNA-seq count matrix.
# If env var DATA_COUNTS_PATH is set, skips simulation and uses that file instead.
# Saves: data/sim_counts.rds (dgCMatrix)

suppressPackageStartupMessages({
  library(Matrix)
})

data_dir <- "data"
out_counts <- file.path(data_dir, "sim_counts.rds")

counts_path <- Sys.getenv("DATA_COUNTS_PATH", unset = "")
if (nzchar(counts_path) && file.exists(counts_path)) {
  message("Using existing counts at: ", counts_path)
  counts <- readRDS(counts_path)
  if (!inherits(counts, "dgCMatrix")) {
    stop("Expected a dgCMatrix in DATA_COUNTS_PATH")
  }
  saveRDS(counts, out_counts)
  quit(save="no")
}

# Try Splatter for better simulation
use_splatter <- requireNamespace("splatter", quietly = TRUE) &&
                requireNamespace("SingleCellExperiment", quietly = TRUE)

if (use_splatter) {
  message("Simulating counts with splatter...")
  library(splatter)
  library(SingleCellExperiment)
  set.seed(123)
  params <- splatEstimate(SingleCellExperiment(matrix(rpois(1000, 1), nrow=100, ncol=10)))
  params <- setParam(params, "nGenes", 2000)
  params <- setParam(params, "batchCells", 800)
  sim <- splatSimulate(params, method = "groups", group.prob = c(0.4, 0.35, 0.25))
  counts <- as(sim@assays@data$counts, "dgCMatrix")
} else {
  message("Simulating counts with simple Poisson (splatter not available)...")
  set.seed(123)
  n_genes <- 2000
  n_cells <- 800
  # three latent groups with different lambda scalings
  groups <- sample(1:3, n_cells, replace = TRUE, prob = c(0.4, 0.35, 0.25))
  base_lambda <- runif(n_genes, min = 0.01, max = 2.0)
  lambda_mat <- outer(base_lambda, c(1.0, 1.5, 0.6)[groups])
  mat <- matrix(rpois(n_genes * n_cells, lambda = lambda_mat), nrow = n_genes, ncol = n_cells)
  rownames(mat) <- paste0("Gene", seq_len(n_genes))
  colnames(mat) <- paste0("Cell", seq_len(n_cells))
  counts <- as(mat, "dgCMatrix")
}

dir.create(data_dir, showWarnings = FALSE, recursive = TRUE)
saveRDS(counts, out_counts)
message("Saved synthetic counts to ", out_counts)
