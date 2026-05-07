##17/10/24 This script uses clustering output in text format (from JMP, with column "Cluster)
###and groups clusters according to pre-defined similarity (in Excel sheet)
###The output files are the input to the Matlab script "Cluster_groups_correlations....m")


install.packages("dplyr")
library(dplyr)

cluster_data <- read.table("/Users/letitia/Dropbox/auditory_HRF/analyses_2025/Clustering/Clusters_110425_ses1.txt", header=TRUE)
#if column names need to be renamed
colnames(cluster_data)[colnames(cluster_data) == "V24"] <- "Cluster"
colnames(cluster_data)[colnames(cluster_data) == "V4"] <- "Subject"
colnames(cluster_data)[colnames(cluster_data) == "V1"] <- "i"
colnames(cluster_data)[colnames(cluster_data) == "V2"] <- "j"
colnames(cluster_data)[colnames(cluster_data) == "V3"] <- "k"

# Define groups as a list (take from Matlab script)
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

# Iterate over unique combinations of Subject and Group
output_dir <- "/Users/letitia/Dropbox/auditory_HRF/analyses_2025/Clustering/"  

# Iterate over unique combinations of Subject and Group
# Iterate over unique combinations of Subject and Group
# unique_subjects <- unique(cluster_data$sub)
# unique_groups <- unique(cluster_data$group)
# 
# # Loop through each subject and group
# for (subject in unique_subjects) {
#   for (group in unique_groups) {
#     
#     # Filter data for the current subject and group
#     subject_group_data <- cluster_data %>% filter(subject == subject & group == group)
#     
#     # Check if there is any data for the current subject and group
#     if (nrow(subject_group_data) > 0) {
#       
#       # Select only the i, j, k columns
#       subject_group_data <- subject_group_data %>% select(i, j, k)
#       
#       # Create a file name based on the subject and group
#       output_filename <- paste0(output_dir, "Subject_", subject, "_Group_", group, ".txt")
#       
#       # Write the filtered data to the text file
#       write.table(subject_group_data, file = output_filename, row.names = FALSE, col.names = TRUE, quote = FALSE, sep = " ")
#     } else {
#       message("No data for Subject ", subject, " in Group ", group)
#     }
#   }
# }

write.table(cluster_data, file = file.path(output_dir, "cluster_data_280425.txt"), row.names = FALSE, quote = FALSE, col.names = FALSE)