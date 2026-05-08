# ROI Dataset Comparison Scatterplots

This script plots ROI-wise HRF parameter comparisons between matched participants from the original and replication datasets.

## GitHub File

- `Analysis/plot_roi_dataset_comparison_scatterplots.py`

## Workflow Step

Run `plot_roi_dataset_comparison_scatterplots.py` after creating `ROI_combined_data.xlsx` with `create_roi_parameter_datatable.m`. The script reads ROI Peak, FWHM, and Amplitude values, matches selected original/replication participant pairs, computes Spearman correlations across common ROIs, and saves the combined scatterplot as PNG and PDF.

## External Inputs And Outputs

Large derived files are not included in the GitHub upload. Expected local inputs/outputs include:

- `ROI_combined_data.xlsx`
- `comparison_grid_correctspreadsheet_Spearman.png`
- `comparison_grid_correctspreadsheet_Spearman.pdf`
