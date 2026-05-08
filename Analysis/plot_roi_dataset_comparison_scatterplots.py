"""
Plot ROI parameter scatterplots comparing matched participants from the
original and replication datasets.

Input:
- ROI_combined_data.xlsx from create_roi_parameter_datatable.m.

Output:
- PNG and PDF files showing ROI-wise Peak, FWHM, and Amplitude scatterplots
  for matched original/replication dataset participant pairs.

Dataset1 is the original dataset; Dataset2 is the replication dataset.
Last changed May 2026 (LS)
"""

import pandas as pd
import matplotlib.pyplot as plt
from adjustText import adjust_text
import numpy as np
from scipy.stats import spearmanr

# Paths
filename = '/path/to/auditory_HRF/analyses_2025/ROI_peak_fwhm_amp/ROI_combined_data.xlsx'
outpath = '/path/to/auditory_HRF/analyses_2025/dataset_comparison/comparison_grid_correctspreadsheet_Spearman'

# Load data
data = pd.read_excel(filename)

# === Quick sanity checks ===
print("=== Shape ===", data.shape)
print("=== Columns ===", list(data.columns))
print("=== Head ===")
print(data.head())
print("=== Dtypes ===")
print(data.dtypes)
print("=== Nulls ===")
print(data.isna().sum())

# Normalize and ensure numeric
data['Dataset'] = data['Dataset'].str.lower().str.strip()
data['ROI'] = data['ROI'].str.strip()
data['Participant'] = data['Participant'].str.strip()
for col in ['Peak', 'FWHM', 'Amp']:
    data[col] = pd.to_numeric(data[col], errors='coerce')

# Assert expectations
required_cols = {'Dataset','ROI','Participant','Peak','FWHM','Amp'}
missing = required_cols - set(data.columns)
assert not missing, f"Missing columns: {missing}"

expected_datasets = {'dataset1','dataset2'}
found = set(data['Dataset'].unique())
unexpected = found - expected_datasets
assert not unexpected, f"Unexpected Dataset values found: {unexpected}"

# Parameters and pairs
parameters = ['Peak', 'FWHM', 'Amp']
pairs = [('s07', 's01'), ('s05', 's02'), ('s03', 's03'), ('s02', 's04')]
title_map = {'Peak': 'Peak latency', 'FWHM': 'FWHM', 'Amp': 'Amplitude'}

fig, axes = plt.subplots(nrows=len(pairs), ncols=len(parameters), figsize=(18, 12))

for row_idx, (repl_id, orig_id) in enumerate(pairs):
    for col_idx, param in enumerate(parameters):
        ax = axes[row_idx, col_idx]

        # Filter data (NOTE: '&' not '&amp;')
        replData = data[(data['Participant'] == repl_id) &
                        (data['Dataset'] == 'dataset2') &
                        (~data[param].isna())]
        origData = data[(data['Participant'] == orig_id) &
                        (data['Dataset'] == 'dataset1') &
                        (~data[param].isna())]

        # Print a couple values to confirm
        print(f"\n--- Pair ({repl_id} vs {orig_id}) | {param} ---")
        print(f"replData rows: {len(replData)}, origData rows: {len(origData)}")
        print("replData sample:")
        print(replData[['Participant','Dataset','ROI',param]].head(3))
        print("origData sample:")
        print(origData[['Participant','Dataset','ROI',param]].head(3))

        commonROIs = sorted(set(replData['ROI']).intersection(origData['ROI']) - {'RA5', 'CA5'})
        
        for roi in commonROIs:
            vals_orig = origData.loc[origData['ROI'] == roi, param]
            vals_repl = replData.loc[replData['ROI'] == roi, param]
            print(f"{param} | {roi}: original={len(vals_orig)} values, replication={len(vals_repl)} values")

        if len(commonROIs) == 0:
            ax.text(0.5, 0.5, 'No data', ha='center', va='center', fontsize=14)
            ax.set_xticks([])
            ax.set_yticks([])
        else:
            origVals = np.array([origData.loc[origData['ROI'] == roi, param].mean() for roi in commonROIs])
            replVals = np.array([replData.loc[replData['ROI'] == roi, param].mean() for roi in commonROIs])

            colors = ['blue' if roi.upper() in ['R', 'A1', 'RT'] else 'green' for roi in commonROIs]
            ax.scatter(origVals, replVals, s=80, c=colors)

            texts = [ax.text(x, y, label, fontsize=10) for x, y, label in zip(origVals, replVals, commonROIs)]
            adjust_text(
                texts,
                ax=ax,
                arrowprops=dict(arrowstyle="->", color='gray', lw=0.5),
                expand_points=(1.5, 1.5),
                expand_text=(1.5, 1.5),
                force_text=(0.5, 0.5),
                lim=100
            )

            if len(origVals) > 1:
                r, pval = spearmanr(origVals, replVals)
                p_text = f'p = {pval:.4f}'
        if orig_id == 's01' and param == 'Amp':
            ax.text(0.62, 0.95, f'rho = {r:.2f}\n{p_text}',
            transform=ax.transAxes,
            fontsize=16,
            verticalalignment='top',
            horizontalalignment='left',
            multialignment='left')
        else:
            ax.text(0.05, 0.95, f'rho = {r:.2f}\n{p_text}',
            transform=ax.transAxes,
            fontsize=16,
            verticalalignment='top',
            horizontalalignment='left',
            multialignment='left')

        if row_idx == 0:
            title_map = {'Peak': 'Peak latency', 'FWHM': 'FWHM', 'Amp': 'Amplitude'}
            ax.set_title(title_map.get(param, param), fontsize=18)
        if col_idx == 0:
            ax.set_ylabel(f'{orig_id}', fontsize=18)

        ax.tick_params(axis='both', labelsize=18)
        ax.xaxis.set_major_formatter(plt.FormatStrFormatter('%.1f'))
        ax.yaxis.set_major_formatter(plt.FormatStrFormatter('%.1f'))
        ax.locator_params(axis='x', nbins=4)
        ax.locator_params(axis='y', nbins=3)

fig.supxlabel('Original dataset', fontsize=24, y=0.01)
fig.supylabel('Replication dataset', fontsize=24, x=0.01)
plt.tight_layout(rect=[0.06, 0.06, 1, 0.96])


plt.tight_layout(rect=[0, 0, 1, 0.96])

# Save
fig.set_size_inches(14, 16, forward=True)
plt.tight_layout(rect=[0, 0, 1, 0.96])

dpi = 300
fig.savefig(f"{outpath}.png", dpi=dpi)
fig.savefig(f"{outpath}.pdf")

print(f"Saved combined figure:\n- {outpath}.png\n- {outpath}.pdf")
