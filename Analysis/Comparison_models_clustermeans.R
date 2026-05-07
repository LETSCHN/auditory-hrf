# Assuming cluster_data is your dataframe with the columns "canonical", "Informed basis set", and "Best model"
# Load necessary libraries
rm(list = ls())
library(ggplot2)
library(dplyr)
library(rstatix)
library(tidyr)
library(readxl)

# Read the data
cluster_data <- read_excel("/Users/letitia/Dropbox/auditory_HRF/analyses_2025/fitting_twogamma_clustermeans/Cluster_means_fits_Rsq_ses2_March2026.xlsx", col_names = TRUE)

#In case you have NaN values
cluster_data <- cluster_data %>%
  mutate(across(c(Canonical, Informed_basis_set, GLM_single, Best_model), as.numeric))

# Combine the data into a long format for ggplot2
data <- cluster_data %>%
  pivot_longer(cols = c("Canonical", "Informed_basis_set", "GLM_single", "Best_model"), names_to = "Model", values_to = "R_Squared")

# Box plot of R-squared values
ggplot(data, aes(x = Model, y = R_Squared)) +
  geom_boxplot() +
  ggtitle("Box Plot of R-squared Values") +
  theme_minimal() + # Use a minimal theme to remove grey shading
  ylim(-4, 4) # Set y-axis limit to 2

# Pairwise comparisons using Wilcoxon tests (non-parametric)
#pairwise_wilcox_test <- data %>%
 # pairwise_wilcox_test(R_Squared ~ Model, p.adjust.method = "bonferroni")

#print(pairwise_wilcox_test)

# Kruskal-Wallis test on R-squared values
#kruskal_result <- kruskal.test(R_Squared ~ Model, data = data)
#print(kruskal_result)

library(rstatix)
library(tidyr)
library(dplyr)

# Ensure numeric columns
cluster_data <- cluster_data %>%
  mutate(across(c(Canonical, Informed_basis_set, GLM_single, Best_model), as.numeric))

# Convert to long format
data_long <- cluster_data %>%
  pivot_longer(cols = c(Canonical, Informed_basis_set, GLM_single, Best_model),
               names_to = "Model", values_to = "R_Squared")

# Paired Wilcoxon signed-rank tests
wilcox_results <- data_long %>%
  pairwise_wilcox_test(R_Squared ~ Model, paired = TRUE, p.adjust.method = "bonferroni")

# View results table
print(wilcox_results)

###For a paired test
# Assuming cluster_data has columns: Canonical, Informed_basis_set, GLM_single, Best_model
# Convert to numeric just in case
cluster_data <- cluster_data %>%
  mutate(across(c(Canonical, Informed_basis_set, GLM_single, Best_model), as.numeric))

# Paired Wilcoxon signed-rank tests
#wilcox.test(cluster_data$Canonical, cluster_data$Informed_basis_set, paired = TRUE)
#wilcox.test(cluster_data$Canonical, cluster_data$GLM_single, paired = TRUE)
wilcox.test(cluster_data$Canonical, cluster_data$Best_model, paired = TRUE)
#wilcox.test(cluster_data$Informed_basis_set, cluster_data$GLM_single, paired = TRUE)
wilcox.test(cluster_data$Informed_basis_set, cluster_data$Best_model, paired = TRUE)
wilcox.test(cluster_data$GLM_single, cluster_data$Best_model, paired = TRUE)

# Apply Bonferroni correction manually
p_values <- c(
  wilcox.test(cluster_data$Canonical, cluster_data$Best_model, paired = TRUE)$p.value,
  wilcox.test(cluster_data$Informed_basis_set, cluster_data$Best_model, paired = TRUE)$p.value,
  wilcox.test(cluster_data$GLM_single, cluster_data$Best_model, paired = TRUE)$p.value
)
#wilcox.test(cluster_data$Canonical, cluster_data$Informed_basis_set, paired = TRUE)$p.value,
#wilcox.test(cluster_data$Canonical, cluster_data$GLM_single, paired = TRUE)$p.value,
#wilcox.test(cluster_data$Informed_basis_set, cluster_data$GLM_single, paired = TRUE)$p.value,


# Bonferroni adjustment
p.adjust(p_values, method = "bonferroni")