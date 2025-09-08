# R/02_run_pipeline.R
# Minimal Seurat pipeline on synthetic or provided counts.
suppressPackageStartupMessages({
  library(Seurat)
  library(SeuratObject)
  library(Matrix)
  library(dplyr)
  library(ggplot2)
  library(patchwork)
})

data_dir <- "data"
res_dir <- "results"
dir.create(res_dir, showWarnings = FALSE, recursive = TRUE)

counts_rds <- file.path(data_dir, "sim_counts.rds")
if (!file.exists(counts_rds)) {
  stop("Counts not found: ", counts_rds, ". Run R/01_generate_synthetic_data.R first.")
}

counts <- readRDS(counts_rds)
if (!inherits(counts, "dgCMatrix")) stop("counts must be a dgCMatrix")

seu <- CreateSeuratObject(counts = counts, project = "synthetic", min.cells = 3, min.features = 200)
seu[["percent.mt"]] <- PercentageFeatureSet(seu, pattern = "^MT-")

# Basic QC filter (adjust as needed)
seu <- subset(seu, subset = nFeature_RNA > 200 & nFeature_RNA < 4000 & percent.mt < 20)

seu <- NormalizeData(seu)
seu <- FindVariableFeatures(seu, selection.method = "vst", nfeatures = 2000)
seu <- ScaleData(seu, features = VariableFeatures(seu))
seu <- RunPCA(seu, features = VariableFeatures(seu), npcs = 30)
seu <- RunUMAP(seu, dims = 1:20)
seu <- FindNeighbors(seu, dims = 1:20)
seu <- FindClusters(seu, resolution = 0.5)

# Save small outputs
saveRDS(seu, file.path(res_dir, "seurat_object_small.rds"))
g1 <- DimPlot(seu, reduction = "umap", group.by = "seurat_clusters") + ggtitle("UMAP by cluster")
ggsave(filename = file.path(res_dir, "umap_clusters.png"), plot = g1, width = 6, height = 5, dpi = 150)

# Marker genes (quick example)
markers <- FindAllMarkers(seu, only.pos = TRUE, min.pct = 0.25, logfc.threshold = 0.25) %>%
  group_by(cluster) %>%
  slice_max(order_by = avg_log2FC, n = 10)
write.csv(markers, file.path(res_dir, "top10_markers_per_cluster.csv"), row.names = FALSE)

message("Pipeline complete. Outputs in 'results/'.")
