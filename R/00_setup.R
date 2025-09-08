# R/00_setup.R
pkgs <- c(
  "Seurat", "SeuratObject", "Matrix", "ggplot2", "dplyr", "patchwork",
  "rmarkdown"
)
optional <- c("splatter", "SingleCellExperiment")

install_if_missing <- function(x){
  for(p in x){
    if(!requireNamespace(p, quietly = TRUE)){
      install.packages(p, repos = "https://cloud.r-project.org")
    }
  }
}

install_if_missing(pkgs)
install_if_missing(optional)

message("Setup complete. Consider using renv::init() to lock versions.")
