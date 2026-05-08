# Fast-Slow Maps

This workflow converts ROI HRF peak and amplitude values into participant-level and group-level z-scores, maps those z-scores to a shared colour scale across datasets, and prepares fsaverage Marty Sereno ROI labels for visualising the colours on the surface.

## GitHub Files

- `Analysis/compute_fast_slow_roi_zscores.m`
- `Analysis/plot_fast_slow_zscore_colours.m`
- `Analysis/create_fsaverage_marty_roi_labels.csh`

## Workflow Steps

1. Run `compute_fast_slow_roi_zscores.m` to read `ROI_combined_data.xlsx`, average peak and amplitude across hemispheres for each participant/dataset/ROI, compute z-scores within participant and dataset, average z-scores across participants, and save per-dataset `.mat` files.
2. Run `plot_fast_slow_zscore_colours.m` to load the per-dataset z-score files, apply a shared colour scale across datasets, and plot ROI colour assignments.
3. Run `create_fsaverage_marty_roi_labels.csh` to generate Marty ROI labels for fsaverage from the CsurfMaps1 annotation.
4. Visualise the fsaverage labels and apply the colours generated from the z-score plotting script.

## External Inputs And Outputs

Large derived files are not included in the GitHub upload. Expected local inputs/outputs include:

- `ROI_combined_data.xlsx`
- `dataset1_zscores.mat`
- `dataset2_zscores.mat`
- CsurfMaps1 fsaverage annotation files
- fsaverage Marty ROI label files
- generated ROI colour figure or manually applied surface visualisation
