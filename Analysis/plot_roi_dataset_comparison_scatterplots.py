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
from matplotlib.lines import Line2D
from adjustText import adjust_text
import numpy as np
from scipy.stats import spearmanr


# Paths
filename = '/path/to/auditory_HRF/analyses_2025/ROI_peak_fwhm_amp/ROI_combined_data.xlsx'
outpath = '/path/to/auditory_HRF/analyses_2025/dataset_comparison/comparison_grid_correctspreadsheet_Spearman'

# Plot settings
AUDITORY_CORE_ROIS = {'R', 'A1', 'RT'}
CORE_COLOR = '#1f77b4'
NON_CORE_COLOR = '#2ca02c'
TITLE_FONTSIZE = 24
AXIS_FONTSIZE = 21
TICK_FONTSIZE = 17
ROI_LABEL_FONTSIZE = 15
STATS_FONTSIZE = 17
LEGEND_FONTSIZE = 21

# Load data
data = pd.read_excel(filename)

# Normalize and ensure numeric
data['Dataset'] = data['Dataset'].str.lower().str.strip()
data['ROI'] = data['ROI'].str.strip()
data['Participant'] = data['Participant'].str.strip()
for col in ['Peak', 'FWHM', 'Amp']:
    data[col] = pd.to_numeric(data[col], errors='coerce')

# Assert expectations
required_cols = {'Dataset', 'ROI', 'Participant', 'Peak', 'FWHM', 'Amp'}
missing = required_cols - set(data.columns)
assert not missing, f"Missing columns: {missing}"

expected_datasets = {'dataset1', 'dataset2'}
found = set(data['Dataset'].unique())
unexpected = found - expected_datasets
assert not unexpected, f"Unexpected Dataset values found: {unexpected}"

# Parameters and pairs
parameters = ['Peak', 'FWHM', 'Amp']
pairs = [('s07', 's01'), ('s05', 's02'), ('s03', 's03'), ('s02', 's04')]
title_map = {'Peak': 'Peak latency (s)', 'FWHM': 'FWHM (s)', 'Amp': 'Amplitude (%)'}

fig, axes = plt.subplots(
    nrows=len(pairs),
    ncols=len(parameters),
    figsize=(20, 18)
)

legend_handles = [
    Line2D(
        [0], [0],
        marker='o',
        color='w',
        markerfacecolor=NON_CORE_COLOR,
        markeredgecolor='black',
        markeredgewidth=0.5,
        markersize=10,
        label='Non-auditory core'
    ),
    Line2D(
        [0], [0],
        marker='o',
        color='w',
        markerfacecolor=CORE_COLOR,
        markeredgecolor='black',
        markeredgewidth=0.5,
        markersize=10,
        label='Auditory core'
    )
]

for row_idx, (repl_id, orig_id) in enumerate(pairs):
    for col_idx, param in enumerate(parameters):
        ax = axes[row_idx, col_idx]

        replData = data[(data['Participant'] == repl_id) &
                        (data['Dataset'] == 'dataset2') &
                        (~data[param].isna())]
        origData = data[(data['Participant'] == orig_id) &
                        (data['Dataset'] == 'dataset1') &
                        (~data[param].isna())]

        commonROIs = sorted(set(replData['ROI']).intersection(origData['ROI']) - {'RA5', 'CA5'})
        r = np.nan
        p_text = 'p = n/a'

        if len(commonROIs) == 0:
            ax.text(0.5, 0.5, 'No data', ha='center', va='center', fontsize=AXIS_FONTSIZE)
            ax.set_xticks([])
            ax.set_yticks([])
        else:
            origVals = np.array([origData.loc[origData['ROI'] == roi, param].mean() for roi in commonROIs])
            replVals = np.array([replData.loc[replData['ROI'] == roi, param].mean() for roi in commonROIs])

            colors = [
                CORE_COLOR if roi.upper() in AUDITORY_CORE_ROIS else NON_CORE_COLOR
                for roi in commonROIs
            ]
            ax.scatter(
                origVals,
                replVals,
                s=95,
                c=colors,
                edgecolors='black',
                linewidths=0.45
            )
            ax.margins(x=0.18, y=0.18)

            # Draw y = x behind the points without changing the axis limits.
            x_limits = ax.get_xlim()
            y_limits = ax.get_ylim()
            ax.axline((0, 0), slope=1, color='black', linestyle='--',
                      linewidth=1.5, zorder=0)
            ax.set_xlim(x_limits)
            ax.set_ylim(y_limits)

            texts = [
                ax.text(x, y, label, fontsize=ROI_LABEL_FONTSIZE)
                for x, y, label in zip(origVals, replVals, commonROIs)
            ]
            adjust_text(
                texts,
                ax=ax,
                arrowprops=dict(arrowstyle="->", color='gray', lw=0.5),
                expand_points=(1.4, 1.4),
                expand_text=(1.35, 1.35),
                force_text=(0.45, 0.45),
                lim=120
            )

            if len(origVals) > 1:
                r, pval = spearmanr(origVals, replVals)
                p_text = f'p = {pval:.4f}'

        if row_idx == 0 and col_idx == 0:
            stats_x = 0.05
            stats_ha = 'left'
            stats_y = 0.95
        elif orig_id == 's04' and param == 'Peak':
            stats_x = 0.95
            stats_ha = 'right'
            stats_y = 0.16
        elif orig_id == 's01' and param == 'Amp':
            stats_x = 0.68
            stats_ha = 'left'
            stats_y = 0.95
        else:
            stats_x = 0.05
            stats_ha = 'left'
            stats_y = 0.95

        ax.text(
            stats_x,
            stats_y,
            f'rho = {r:.2f}\n{p_text}',
            transform=ax.transAxes,
            fontsize=STATS_FONTSIZE,
            verticalalignment='top',
            horizontalalignment=stats_ha,
            multialignment='left'
        )

        if row_idx == 0:
            ax.set_title(title_map.get(param, param), fontsize=TITLE_FONTSIZE, pad=12)

        ax.set_xlabel('Original dataset', fontsize=AXIS_FONTSIZE, labelpad=7)
        ax.set_ylabel('Replication dataset', fontsize=AXIS_FONTSIZE, labelpad=7)
        ax.tick_params(axis='both', labelsize=TICK_FONTSIZE)
        ax.xaxis.set_major_formatter(plt.FormatStrFormatter('%.1f'))
        ax.yaxis.set_major_formatter(plt.FormatStrFormatter('%.1f'))
        ax.locator_params(axis='x', nbins=4)
        ax.locator_params(axis='y', nbins=3)

fig.legend(
    handles=legend_handles,
    loc='upper left',
    bbox_to_anchor=(0.11, 0.985),
    ncol=2,
    fontsize=LEGEND_FONTSIZE,
    frameon=True,
    framealpha=0.9,
    borderpad=0.45,
    handletextpad=0.4,
    labelspacing=0.35
)

plt.subplots_adjust(
    left=0.11,
    right=0.985,
    top=0.89,
    bottom=0.065,
    wspace=0.34,
    hspace=0.30
)

for row_idx, (_, orig_id) in enumerate(pairs):
    row_box = axes[row_idx, 0].get_position()
    row_center = row_box.y0 + row_box.height / 2
    fig.text(
        0.025,
        row_center,
        orig_id,
        fontsize=TITLE_FONTSIZE,
        fontweight='bold',
        ha='left',
        va='center'
    )

dpi = 300
fig.savefig(f"{outpath}.png", dpi=dpi)
fig.savefig(f"{outpath}.pdf")

print(f"Saved combined figure:\n- {outpath}.png\n- {outpath}.pdf")
