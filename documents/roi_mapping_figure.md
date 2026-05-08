# Figure ROI Mapping

This workflow maps Marty Sereno auditory ROIs into EPI space, removes duplicate ROI voxels, fits HRF models to average ROI ERAs and exports ROI parameter text files.

## GitHub Files

- `Analysis/map_marty_labels_to_epi.sh`
- `Analysis/remove_duplicate_roi_voxels.m`
- `Analysis/fit_roi_average_hrf_models_auditory_hrf.m`
- `Analysis/export_roi_parameter_textfiles.m`
- `Analysis/create_roi_parameter_datatable.m`

The ROI model-fitting scripts also depend on the shared HRF fitting helpers in `Analysis/`, including the bound-check functions and R-squared helper functions.

## Workflow Steps

1. Run `map_marty_labels_to_epi.sh` to map Marty auditory labels to native/EPI space and export ROI coordinate text files.
2. Run `remove_duplicate_roi_voxels.m` where ROI text files need duplicate voxel coordinates removed.
3. Run `fit_roi_average_hrf_models_auditory_hrf.m` for Auditory HRF ROI-average model fits.
4. Run `export_roi_parameter_textfiles.m` to export peak, FWHM, and amplitude parameter text files from fitted `.mat` outputs.
5. Run `create_roi_parameter_datatable.m` to combine ROI parameters into `.mat` and `.xlsx` tables for downstream analyses.
6. Surface projection for supplementary figures is handled separately and is not part of the Figure GitHub upload set.

## External Inputs And Outputs

Large derived data files are not included as source code in the GitHub upload. The scripts expect local copies of:

- ROI coordinate text files
- per-subject ERA `.mat` files
- fitted ROI parameter `.mat` files
- output ROI parameter `.txt`, `.nii.gz`, `.mgh`, `.mat`, and `.xlsx` files

The GitHub-facing scripts use placeholder paths such as `/path/to/external_drive/...` and `/path/to/auditory_HRF/...`.
