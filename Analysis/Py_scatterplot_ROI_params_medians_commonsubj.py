# Description:
# Plot dataset-comparison scatterplots for median ROI HRF parameters in
# common subjects, with label adjustment and basic input validation.

import pandas as pd
import matplotlib.pyplot as plt
from adjustText import adjust_text
import numpy as np
from scipy.stats import pearsonr

# Paths
filename = '/path/to/auditory_HRF/analyses_2025/ROI_peak_fwhm_amp/ROI_combined_data.xlsx'
outpath = '/path/to/auditory_HRF/analyses_2025/dataset_comparison/comparison_grid_all_pairs'

# ----------------------------
# Load data + minimal validation
# ----------------------------
data = pd.read_excel(filename)

print("\n=== BASIC READ CHECKS ===")
print("Shape:", data.shape)
print("Columns:", list(data.columns))
print("Head (first 5 rows):")
print(data.head())

# Normalize strings for robust matching (but we'll DISPLAY ROI labels as-is from the data below)
data['Dataset'] = data['Dataset'].astype(str).str.lower().str.strip()
# Keep ROI as-is for display; still strip whitespace to avoid duplicates like "A1 " vs "A1"
data['ROI'] = data['ROI'].astype(str).str.strip()
if 'Participant' in data.columns:
    data['Participant'] = data['Participant'].astype(str).str.lower().str.strip()

# Quick category checks
print("\nDatasets found:", sorted(data['Dataset'].unique()))
if 'Participant' in data.columns:
    print("Participants sample:", sorted(data['Participant'].unique())[:20])
print("ROIs sample (as displayed):", sorted(data['ROI'].unique())[:20])

# Ensure numeric parameters; show any non-numeric examples before coercion
for col in ['Peak', 'FWHM', 'Amp']:
    if col in data.columns:
        bad = data.loc[pd.to_numeric(data[col], errors='coerce').isna(), col].dropna().unique()
        print(f"\nNon-numeric examples in {col} (up to 10): {bad[:10]}")
        data[col] = pd.to_numeric(data[col], errors='coerce')
    else:
        raise AssertionError(f"Missing required column: {col}")

# ----------------------------
# Participant subsets per dataset
# ----------------------------
subset_participants = {
    'dataset1': {'s01', 's02', 's03', 's04'},
    'dataset2': {'s02', 's03', 's05', 's07'},
}

# ROIs and parameter pairs
allROIs = sorted(data['ROI'].unique())
param_pairs = [('Peak', 'FWHM'), ('Peak', 'Amp')]
datasets = ['dataset1', 'dataset2']  # lowercase to match normalization

# Create one big figure
fig, axes = plt.subplots(nrows=len(datasets), ncols=len(param_pairs), figsize=(14, 16))

for row_idx, dataset in enumerate(datasets):
    # Apply participant subset filter for this dataset
    subset = data[(data['Dataset'] == dataset) & (data['Participant'].isin(subset_participants[dataset]))]

    # Light check: subset size and participants present
    print(f"\n=== Subset check for {dataset} ===")
    print(f"Rows after filter: {len(subset)}")
    print(f"Participants present: {sorted(subset['Participant'].unique())}")
    print(f"ROIs present (sample): {sorted(subset['ROI'].unique())[:20]}")

    for col_idx, (x_param, y_param) in enumerate(param_pairs):
        ax = axes[row_idx, col_idx]

        # Compute medians per ROI (collapsed across the selected participants within this dataset)
        x_vals, y_vals, roi_labels = [], [], []
        sample_medians = []

        for roi in allROIs:
            roi_data = subset[subset['ROI'] == roi]
            x_med = roi_data[x_param].median(skipna=True)
            y_med = roi_data[y_param].median(skipna=True)
            if not np.isnan(x_med) and not np.isnan(y_med):
                x_vals.append(x_med)
                y_vals.append(y_med)
                roi_labels.append(roi)  # <-- DISPLAY LABELS EXACTLY AS IN DATA (no caps, no changes)
                if len(sample_medians) < 5:
                    sample_medians.append((roi, float(x_med), float(y_med)))

        # Print a small sample of medians used for this panel
        print(f"Panel [{dataset}] {x_param} vs {y_param}: "
              f"{len(roi_labels)} ROIs with medians. Sample (ROI, {x_param}, {y_param}): {sample_medians}")

        x_vals = np.array(x_vals)
        y_vals = np.array(y_vals)

        # Scatter plot
        ax.scatter(x_vals, y_vals, s=80, color=(0, 0.5, 0))

        # ROI labels with adjustText — NO ARROWS (no 'dashes')
        texts = [ax.text(x, y, label, fontsize=10) for x, y, label in zip(x_vals, y_vals, roi_labels)]
        adjust_text(
            texts, ax=ax,
            # no arrowprops → no arrow “dashes”
            expand_points=(1.5, 1.5),
            expand_text=(1.5, 1.5),
            force_text=(0.5, 0.5),
            lim=100
        )

        # Axis labels and title
        ax.set_xlabel(f'Median {x_param}', fontsize=18)
        ax.set_ylabel(f'Median {y_param}', fontsize=18)
        # ax.set_title(f'{dataset}: {x_param} vs {y_param}', fontsize=16)

        # Regression line and Pearson correlation
        if len(x_vals) > 1:
            slope, intercept = np.polyfit(x_vals, y_vals, 1)
            xfit = np.linspace(x_vals.min(), x_vals.max(), 100)
            yfit = slope * xfit + intercept
            ax.plot(xfit, yfit, 'k--', linewidth=1.5)

            r, pval = pearsonr(x_vals, y_vals)
            # Significance stars + two-decimal p
            if pval < 0.001:
                stars = '***'
            elif pval < 0.01:
                stars = '**'
            elif pval < 0.05:
                stars = '*'
            else:
                stars = ''
            ax.text(0.05, 0.95, f'r={r:.2f}, p={pval:.2f} {stars}',
                    transform=ax.transAxes, fontsize=16, verticalalignment='top')

        # Tick formatting
        ax.xaxis.set_major_formatter(plt.FormatStrFormatter('%.1f'))
        ax.yaxis.set_major_formatter(plt.FormatStrFormatter('%.1f'))
        ax.locator_params(axis='x', nbins=4)
        ax.locator_params(axis='y', nbins=3)
        ax.tick_params(axis='both', labelsize=18)

plt.tight_layout(rect=[0, 0, 1, 0.94])
fig.subplots_adjust(top=0.92)

# Make figure slightly taller and slimmer
fig.set_size_inches(14, 16, forward=True)

# Save figure
dpi = 300
fig.savefig(f"{outpath}.png", dpi=dpi)
fig.savefig(f"{outpath}.pdf")

print(f"Saved combined figure:\n- {outpath}.png\n- {outpath}.pdf")
