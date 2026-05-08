# Fitting Twogamma Cluster Means

This workflow fits HRF model families to the session 2 cluster-mean ERA time courses and plots selected cluster examples where standard HRF models didn't perform well.

## GitHub Files

- `Analysis/fit_cluster_mean_hrf_models.m`
- `Analysis/plot_cluster_mean_hrf_model_fits.m`
- `Analysis/compare_cluster_mean_hrf_models.R`
- `Analysis/create_basisfunction.m`
- `Analysis/getAdjustedRsquared.m`
- `Analysis/getRsquared.m`
- `Analysis/checkatBoundM1.m`
- `Analysis/checkatBoundM2.m`
- `Analysis/checkatBoundM3_8.m`
- `Analysis/checkatBoundM6.m`

## External Inputs

These files are inputs to the workflow and are not included as source code in the GitHub upload:

- `Cluster_means_session2_Sep25.txt`
- `getcanonicalhrflibrary.tsv` from the GLMsingle HRF library
- `Cluster_means_fits_Rsq_ses2_March2026.xlsx`

The MATLAB scripts point to these files with placeholder paths:

- `/path/to/auditory_HRF/analyses_2025/Clustering/Cluster_means_session2_Sep25.txt`
- `/path/to/user_documents/GLMsingle-main/glmsingle/hrf/getcanonicalhrflibrary.tsv`

The R script points to the adjusted R-squared spreadsheet with:

- `/path/to/auditory_HRF/analyses_2025/fitting_twogamma_clustermeans/Cluster_means_fits_Rsq_ses2_March2026.xlsx`

## Workflow Steps

1. Run `fit_cluster_mean_hrf_models.m` to fit all cluster-mean time courses.
2. Record/export the adjusted R-squared values for the canonical HRF, informed basis set, GLMsingle HRF, and best custom model.
3. Save the adjusted R-squared table as `Cluster_means_fits_Rsq_ses2_March2026.xlsx`.
4. Run `compare_cluster_mean_hrf_models.R` to compare model performance using paired Wilcoxon tests.
5. Run `plot_cluster_mean_hrf_model_fits.m` to plot the selected cluster examples used in the figure.

## Notes

- The current GitHub-facing fitting script is based on the March 2026 analysis version.
- The March 2026 update uses beta estimation for the canonical, informed-basis, and GLMsingle fits instead of simple rescaling.
- Large derived data tables, Excel files, and figure exports should are documented rather than uploaded directly
