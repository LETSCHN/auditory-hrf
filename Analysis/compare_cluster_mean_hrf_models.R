# Compare adjusted R-squared values for cluster-mean HRF model fits.
#
# Input columns expected in the Excel file:
# Canonical, Informed_basis_set, GLM_single, Best_model.
#
# Last updated March 2026 (LS).

rm(list = ls())

library(ggplot2)
library(dplyr)
library(rstatix)
library(tidyr)
library(readxl)

rsq_file <- "/path/to/auditory_HRF/analyses_2025/fitting_twogamma_clustermeans/Cluster_means_fits_Rsq_ses2_March2026.xlsx"

cluster_data <- read_excel(rsq_file, col_names = TRUE)
cluster_data <- cluster_data %>%
  mutate(across(c(Canonical, Informed_basis_set, GLM_single, Best_model), as.numeric))

data <- cluster_data %>%
  pivot_longer(
    cols = c(Canonical, Informed_basis_set, GLM_single, Best_model),
    names_to = "Model",
    values_to = "R_Squared"
  )

ggplot(data, aes(x = Model, y = R_Squared)) +
  geom_boxplot() +
  ggtitle("Adjusted R-squared by model") +
  theme_minimal() +
  ylim(-4, 4)

wilcox_results <- data %>%
  pairwise_wilcox_test(R_Squared ~ Model, paired = TRUE, p.adjust.method = "bonferroni")
print(wilcox_results)

p_values <- c(
  wilcox.test(cluster_data$Canonical, cluster_data$Best_model, paired = TRUE)$p.value,
  wilcox.test(cluster_data$Informed_basis_set, cluster_data$Best_model, paired = TRUE)$p.value,
  wilcox.test(cluster_data$GLM_single, cluster_data$Best_model, paired = TRUE)$p.value
)

p.adjust(p_values, method = "bonferroni")
