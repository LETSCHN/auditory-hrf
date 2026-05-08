##17/10/24 This script uses clustering output in text format (from JMP, with column "Cluster)
###and groups clusters according to pre-defined similarity (in Excel sheet)
###The output files are the input to the Matlab script "Cluster_groups_correlations....m")
### LS (2024)


install.packages("dplyr")
library(dplyr)

cluster_data <- read.table("/path/to/auditory_HRF/analyses_2025/Clustering/Clusters_110425_ses1.txt", header=TRUE)
#if column names need to be renamed
colnames(cluster_data)[colnames(cluster_data) == "V24"] <- "Cluster"
colnames(cluster_data)[colnames(cluster_data) == "V4"] <- "Subject"
colnames(cluster_data)[colnames(cluster_data) == "V1"] <- "i"
colnames(cluster_data)[colnames(cluster_data) == "V2"] <- "j"
colnames(cluster_data)[colnames(cluster_data) == "V3"] <- "k"

# Cluster groups copied from analyze_clusters.m, April 2025 grouping
# based on visual inspection of Cluster_means_110425.txt.
grp <- list(
  grp1 = c(18, 19, 20, 21, 22),
  grp2 = c(9, 10, 11, 12),
  grp3 = c(3, 5, 6),
  grp4 = c(4, 13, 14, 16),
  grp5 = c(7, 23, 24, 27, 28, 32),
  grp6 = c(25, 26, 29, 31, 34),
  grp7 = c(30, 33, 35, 36, 37, 38, 39, 40)
)

# Assign group numbers based on cluster value using case_when
cluster_data <- cluster_data %>%
  mutate(group = case_when(
    Cluster %in% grp[[1]] ~ 1,
    Cluster %in% grp[[2]] ~ 2,
    Cluster %in% grp[[3]] ~ 3,
    Cluster %in% grp[[4]] ~ 4,
    Cluster %in% grp[[5]] ~ 5,
    Cluster %in% grp[[6]] ~ 6,
    Cluster %in% grp[[7]] ~ 7,
    TRUE ~ NA_real_  # Default to NA if not in any group
  ))

output_dir <- "/path/to/auditory_HRF/analyses_2025/Clustering/"  

write.table(cluster_data, file = file.path(output_dir, "cluster_data_280425.txt"), row.names = FALSE, quote = FALSE, col.names = FALSE)
