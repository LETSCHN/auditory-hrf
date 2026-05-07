#This script is used to assess the relationship between R1 and peak/amp for dset1/2. 
#Change inputs depending on whether you run Peak or Amp (especially annotation of p value in Fig)
#Clear up everything
rm(list = ls())
# Load required libraries

library(lme4)
library(lmerTest)
library(readr)
library(ggplot2)

# Toggle these two values
outcome <- "Peak"      # "Peak" or "Amp"
dataset_id <- "dset1"  # "dset1" or "dset2"

file_map <- list(
  dset1 = "/Users/letitia/Dropbox/auditory_HRF/analyses_2025/ROI_peak_fwhm_amp/dset1_ROI_params_MPM_combined_data.csv",
  dset2 = "/Users/letitia/Dropbox/auditory_HRF/analyses_2025/ROI_peak_fwhm_amp/dset2_ROI_params_MPM_combined_data.csv"
)

dataset_label_map <- list(
  dset1 = "Dataset1",
  dset2 = "Dataset2"
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

# Read the merged data
data <- read_csv(file_map[[dataset_id]], show_col_types = FALSE)

# Demean R1
data$R1_demeaned <- scale(data$R1, center = TRUE, scale = FALSE)
data$OutcomeValue <- data[[outcome]]

# Fit the linear mixed-effects model with random intercept and slope for R1 (Fred suggests second option)
model_formula <- as.formula(
  paste0(outcome, " ~ Hemisphere + R1_demeaned + (1 + R1_demeaned | Subject)")
)
#model_formula_alt <- as.formula(
#  paste0(outcome, " ~ Hemisphere + R1_demeaned + (1 | Subject) + (R1_demeaned | Subject)")
#)

model <- lmer(model_formula, data = data)
#model1 <- lmer(model_formula_alt, data = data)

# Display model summary
summary(model)

# Optional: ANOVA table with Satterthwaite approximation
anova(model, ddf = "Satterthwaite")

# Get ANOVA table
anova_table <- anova(model, ddf = "Satterthwaite")

# Extract p-value for R1_demeaned
p_val <- anova_table["R1_demeaned", "Pr(>F)"]

# Determine stars based on significance
#stars <- ifelse(p_val < 0.001, "***",
#                ifelse(p_val < 0.01, "**",
#                       ifelse(p_val < 0.05, "*", "")))

#if (p_val < 0.0001) {
#  p_text <- paste0("p < .0001 ", stars)
#} else if (p_val < 0.001) {
#  p_text <- paste0("p < .001 ", stars)
#} else if (p_val < 0.01) {
#  p_text <- paste0("p < .01 ", stars)
#} else {
#  p_text <- paste0("p = ", formatC(p_val, format = "f", digits = 4), " ", stars)
#}
p_text <- paste0("p = ", formatC(p_val, format = "f", digits = 4), " ")

# Plot with annotation
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

##Old analysis (without demeaning)
# Fit the linear mixed-effects model
#model <- lmer(Peak ~ Hemisphere + R1 + (1 | Subject), data = data)

# Display model summary
#summary(model)

# Optional: ANOVA table with Satterthwaite approximation
#anova(model, ddf = "Satterthwaite")

#library(ggplot2)
#library(readr)

# Plot with linear fit, grouped by Hemisphere
#ggplot(data, aes(x = R1, y = Peak, color = Hemisphere)) +
# geom_point(alpha = 0.6) +
#geom_smooth(method = "lm", se = TRUE) +
#labs(title = "Relationship Between Peak and R1 by Hemisphere",
#    x = "R1",
#   y = "Peak") +
#ylim(2,7) +
#theme_minimal()
