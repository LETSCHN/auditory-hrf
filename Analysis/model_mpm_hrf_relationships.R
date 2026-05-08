# This script is used to assess the relationship between R1 and peak/amp for the original dataset or replication dataset.
# Input: original dataset CSV (dset1_ROI_params_MPM_combined_data.csv) or replication dataset CSV (dset2_ROI_params_MPM_combined_data.csv)
# from combine_mpm_roi_hrf_parameters_original_dataset.m or equivalent replication dataset workflow.
# Output: linear mixed-effects model summary/ANOVA in the R console and a ggplot scatter/fit figure.
# Change inputs depending on whether you run Peak or Amp (especially annotation of p value in Fig).
# Last changed May 2026 (LS)

rm(list = ls())

library(lme4)
library(lmerTest)
library(readr)
library(ggplot2)

outcome <- "Peak"      # "Peak" or "Amp"
dataset_id <- "original_dataset"  # "original_dataset" or "replication_dataset"

file_map <- list(
  original_dataset = "/path/to/auditory_HRF/analyses_2025/ROI_peak_fwhm_amp/dset1_ROI_params_MPM_combined_data.csv",
  replication_dataset = "/path/to/auditory_HRF/analyses_2025/ROI_peak_fwhm_amp/dset2_ROI_params_MPM_combined_data.csv"
)

dataset_label_map <- list(
  original_dataset = "Original dataset",
  replication_dataset = "Replication dataset"
)

y_limits_map <- list(
  Peak = c(2, 7),
  Amp = c(0, 1.1)
)

annotate_y_map <- list(
  Peak = 6.8,
  Amp = 1.1
)

outcome_label_map <- list(
  Peak = "Peak latency",
  Amp = "Amplitude"
)

outcome_label <- outcome_label_map[[outcome]]

dataset_label <- dataset_label_map[[dataset_id]]
y_limits <- y_limits_map[[outcome]]
annotate_y <- annotate_y_map[[outcome]]

data <- read_csv(file_map[[dataset_id]], show_col_types = FALSE)

data$R1_demeaned <- scale(data$R1, center = TRUE, scale = FALSE)
data$OutcomeValue <- data[[outcome]]

model_formula <- as.formula(
  paste0(outcome, " ~ Hemisphere + R1_demeaned + (1 + R1_demeaned | Subject)")
)

model <- lmer(model_formula, data = data)

summary(model)

anova(model, ddf = "Satterthwaite")

anova_table <- anova(model, ddf = "Satterthwaite")

p_val <- anova_table["R1_demeaned", "Pr(>F)"]

p_text <- paste0("p = ", formatC(p_val, format = "f", digits = 4), " ")

plot <- ggplot(data, aes(x = R1_demeaned, y = OutcomeValue)) +
  geom_point(alpha = 0.6, color = "mediumblue") +
  geom_smooth(method = "lm", se = TRUE, color = "mediumblue") +
  labs(title = dataset_label,
       x = expression(R[1] * " (demeaned)"),
       y = outcome_label) +
  coord_cartesian(ylim = y_limits) +
  theme_minimal() +
  theme(
    panel.grid = element_blank(),
    axis.text = element_text(size = 16),
    axis.title = element_text(size = 18),
    plot.title = element_text(size = 20, hjust = 0.5)
  ) +
  annotate("text", x = max(data$R1_demeaned, na.rm = TRUE), y = annotate_y,
           label = p_text, hjust = 1, size = 6)

print(plot)
