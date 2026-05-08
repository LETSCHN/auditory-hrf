# MPM Analyses

This workflow combines previously extracted ROI-level MPM R1 values with ROI HRF parameters and fits linear mixed-effects models to assess the relationship between MPM R1 and HRF timing/amplitude measures.

## GitHub Files

- `Analysis/combine_mpm_roi_hrf_parameters_original_dataset.m`
- `Analysis/model_mpm_hrf_relationships.R`

## Workflow Steps

1. Run `combine_mpm_roi_hrf_parameters_original_dataset.m` to extract R1 values for target ROIs and merge them with ROI HRF parameter values from `ROI_combined_data.xlsx`.
2. Run `model_mpm_hrf_relationships.R` to fit the linear mixed-effects model for the selected dataset and outcome (`Peak` or `Amp`) and generate the corresponding scatter/fit plot.

## External Inputs And Outputs

Large derived files are not included in the GitHub upload. Expected local inputs/outputs include:

- participant MPM parameter maps (`R1`).
- participant FreeSurfer reconstructions and `CsurfMaps1` ROI annotations
- MPM ROI table text files
- `ROI_combined_data.xlsx`
- `dset1_ROI_params_MPM_combined_data.csv`
- `dset2_ROI_params_MPM_combined_data.csv` if running the replication dataset workflow
- R console model summaries/ANOVA tables and generated ggplot figures

## Notes

- MPM ROI table text files are assumed to have been extracted before this workflow using the standard FreeSurfer procedure: MPM maps were registered to participant surfaces, projected to surface space, converted to `.crv`, and sampled within Marty Sereno ROI annotations.
- The MPM ROI table text files are not uploaded here.
