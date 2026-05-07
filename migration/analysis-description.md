# Auditory HRF Project Analysis Description

**Updated:** 25/08/25

## 1. Pre-processing

1. Tcat: remove first 8 TRs
2. Volreg: align to `MIN_OUTLIER`
3. Blip correction: forward = SB image run1, reverse = SB PErev image run1

Script:

- `/Users/letitia/Dropbox/auditory_HRF/Experiment1/Sep_2023/scripts/final_scripts/updated_Feb_2025/Pre-processing_aud_HRF_2024.csh`

## 2. tSNR Mask

1. Calculate tSNR maps for each run (`pb02.volreg.r*`) by dividing mean by stdev
2. Create average tSNR map across all runs (`3dMean`)
3. Zeropad image
4. Warp into midspace
5. Binarise (`step(a-35)`)
6. Use min outlier image in midspace to create a brainmask
7. Only use voxels common to image 5 and image 6 (`and(a,b)`)

Scripts:

- Steps 1-2: `/Users/letitia/Dropbox/auditory_HRF/Experiment1/Sep_2023/scripts/final_scripts/Surface_smoothing_GLM_aud_HRF_2024.csh`
  - This should be added to the Rawdata smoothed script.
- Steps 3-7: `/Users/letitia/Dropbox/auditory_HRF/Experiment1/Sep_2023/scripts/final_scripts/updated_Feb_2025/Rawdata_ERA_260724.csh`
  - This script is only used to create TSNR mask; should be added to Rawdata smoothed script.

## 3. Prepare Timeseries for ERA Calculation

1. Zeropad each run
2. Warp into midspace
3. Surface smooth (`mris_volsmooth`)
4. Concatenate all runs
5. Print timeseries within tSNR mask (`3dmaskdump`)

Script:

- Steps 1-5: `/Users/letitia/Dropbox/auditory_HRF/analyses_2025/scripts/Rawdata_ERA_260724_smoothed.csh`

### What's Missing?

`Min_outlier_zpad`:

- `/Users/letitia/Dropbox/auditory_HRF/Experiment1/Sep_2023/scripts/Session_registration_bbregister.csh`

How did I come up with `min_outlier_zpad_session1.midspace.nii.gz`?

- `/Users/letitia/Dropbox/auditory_HRF/Experiment1/Sep_2023/scripts/final_scripts/updated_Feb_2025/Sessionregistration_aud_HRF_2024.csh`

## Figure 1: Cluster

Bbregister to midspace:

- `/Users/letitia/Dropbox/auditory_HRF/Experiment1/Sep_2023/scripts/final_scripts/updated_Feb_2025/Sessionregistration_aud_HRF_2024.csh`

Workflow:

1. Create clustering files from `ix` script
2. Save `sessX_smoothed_for_clustering_ERA_SD` as CSV for both sessions
3. JMP > save cluster means
4. Determine cluster groups by eye
5. Plot group means + error bars and create heatmap (`heatmap(cluster_means);`)
6. Create per subject a text file containing `i,j,k` and:
   - cluster group
   - ERA correlation values between ses1 and ses2
7. Use text files to create EPI then surface images (`3dUndump`, `mri_binarize`, `mri_vol2surf`)
8. Plot cluster group + correlations separately in surface for each participant/hemisphere

Data used for clustering:

- `/Users/letitia/Dropbox/auditory_HRF/analyses_2025/Clustering/cluster_data_280425.txt`

Scripts and outputs:

- Cluster file: `/Users/letitia/Dropbox/auditory_HRF/auditory-hrf/analyses_2025/scripts/pre-processing scripts/ix_get_ERAs_no_corrth.m`
- Cluster means: `/Users/letitia/Dropbox/auditory_HRF/Experiment1/Sep_2023/session_comparison_March/Clustering_160924_t18_ses1/Cluster_means_ses1_160924.txt`
- Cluster grouping:
  - `/Users/letitia/Dropbox/auditory_HRF/analyses_2025/Clustering/Cluster_characteristics_updated_1504.xlsx`
  - `/Users/letitia/Dropbox/auditory_HRF/Experiment1/Sep_2023/scripts/Cluster_groups_updated291124.R`
  - `/Users/letitia/Dropbox/auditory_HRF/Experiment1/Sep_2023/session_comparison_March/Clustering_160924_t18_ses1/analyze_clusters.m`
  - `/Users/letitia/Documents/Isma_auditoryHRF_scripts/ERA_t18/Cluster_groups_correlations_031224.m`
- Text files with cluster group and correlation for each voxel per participant: `/Users/letitia/Dropbox/auditory_HRF/analyses_2025/scripts/Cluster_groups_correlations_031224.m`
- Put text files into volume/surface space: `/Users/letitia/Dropbox/auditory_HRF/Experiment1/Sep_2023/scripts/final_scripts/updated_Feb_2025/surface_ERA_corr_clustgroup.csh`
- Cluster groups + correlation between sessions:
  - https://colab.research.google.com/drive/1Chs8oh9dCvmVzUs-psIzue_f5AQB2u0U#scrollTo=bISCO2kTURkK
  - `/Users/letitia/Dropbox/auditory_HRF/analyses_2025/Figures/Clustering/Cluster_nvoxels_groups_Fig1.m`
- Run figure:
  - https://colab.research.google.com/drive/1NLJ615qBGcbCynxbAGRuJeNykqzylgqV#scrollTo=bISCO2kTURkK
- Peak / amplitude figure:
  - https://colab.research.google.com/drive/1hs0JLtpO3bP9mfwlSpoHVFAHW6uN6j6J

## Figure: Fitting Twogamma Cluster Means

1. Load correct cluster means file; choose between ses1 and ses2
2. Run script and inspect individual fits; check if using Rsq or Rsqadj
3. Choose clusters where fit of canonical models is not good
4. Put in example cluster number for figure in subplot script
5. Save out adjusted Rsq per model from the script:
   - canonical: `rsq_canonical`
   - IBS: `rsq_bfs`
   - GLM single: `glm_single_best`
   - our models: `rsq`
6. Do pairwise comparison between model fits
7. Plot selected cluster means

Scripts and outputs:

- Steps 1-3:
  - `/Users/letitia/Dropbox/auditory_HRF/analyses_2025/scripts/fitting cluster means/fitting_twogamma_clustermeans.m`
  - `/Users/letitia/Dropbox/auditory_HRF/analyses_2025/scripts/fitting cluster means/getAdjustedRsquared.m`
  - `/Users/letitia/Dropbox/auditory_HRF/analyses_2025/scripts/fitting cluster means/create_basisfunction.m`
- Step 4: `/Users/letitia/Dropbox/auditory_HRF/analyses_2025/scripts/fitting cluster means/fitting_twogamma_clustermeans_subplot.m`
- Steps 5-6:
  - `/Users/letitia/Dropbox/auditory_HRF/analyses_2025/Clustering/Cluster_means_fits_Rsq_ses2.xlsx`
  - `/Users/letitia/Dropbox/auditory_HRF/analyses_2025/Clustering/Comparison_models_clustermeans.R`
- Step 7: `/Users/letitia/Dropbox/auditory_HRF/analyses_2025/scripts/fitting cluster means/fitting_twogamma_clustermeans_subplot.m`

## Figure 3: ROIs Mapping

1. Get ROIs in native subject space
2. Put them from surface to EPI space
3. Get text files per ROI with `i,j,k` coordinates
4. Remove duplicate voxels across ROIs
5. Get average ERA per ROI and fit models on average
6. Zero out ROIs with bad fits / `<5vxs`
7. Concatenate all ROIs per subject for each parameter (`peak`, `fwhm`, `amp`) and generate as text file and Excel file
8. Convert text to nifti file per subject/hemisphere
9. Put nifti into surface space
10. Load each participant/hemisphere surface file and plot with participant-specific limits/color bar

Scripts and outputs:

- Steps 1-2: `/Users/letitia/Dropbox/auditory_HRF/Experiment1/Sep_2023/scripts/final_scripts/updated_Feb_2025/Marty-labels-EPI-22-11-24.sh`
- Step 4: `/Users/letitia/Documents/Isma_auditoryHRF_scripts/Marty_ROIs_090125/roi_remove_duplicates_modified_110225.m`
- Steps 5-7:
  - `/Users/letitia/Dropbox/auditory_HRF/analyses_2025/scripts/training_model_fitting_roi_avg_no_ERA_SD_corr_fittingallses.m`
  - `/Users/letitia/Dropbox/HiHi/scripts/training_model_fitting_roi_avg_no_ERA_SD_corr_fittingallses.m`
  - `/Users/letitia/Dropbox/auditory_HRF/analyses_2025/scripts/ROI_mat_to_textfiles.m`
  - `/Users/letitia/Dropbox/auditory_HRF/analyses_2025/scripts/Create_datatable_ROIs_params.m`
- Steps 8-9: `/Users/letitia/Dropbox/auditory_HRF/Experiment1/Sep_2023/scripts/final_scripts/updated_Feb_2025/peak_fwhm_Marty-ROIs-surface.csh`
- Step 10: https://colab.research.google.com/drive/1hs0JLtpO3bP9mfwlSpoHVFAHW6uN6j6J

## Figure 2: Trial Effects

1. Get voxelwise fits (training)
2. Get fits for trial averaged ERAs for simulated data and observed data. Averaged over 1 or 2 sessions?
3. Save out stable voxels: run + rsq with max stability
4. Create trial effects figure showing trajectory per participant and calculate Rsq gain per run by running trial effects script
5. Copy `.mat` files with run and rsq per participant/voxel into text files
6. Convert text file into EPI using `i,j,k`
7. Binarise run nifty to avoid intermediate values on surface
8. Project niftis into surface: one for rsq and one for run, per participant
9. `output_stability{s} = [vox_corr_th_85_XYZ{s,1}, bm(6,:)', stability(:,6), stable_rep'];`
   - I just averaged the last column for each voxel across all participants and got 4.4.
10. Save `.mat` files to subject-specific text files
11. Plot

Scripts and outputs:

- Step 1: `/Users/letitia/Dropbox/auditory_HRF/analyses_2025/scripts/training_model_fitting.m`
- Steps 2-3:
  - `/Users/letitia/Dropbox/auditory_HRF/analyses_2025/trial_effects/simulate_data.m`
  - `/Users/letitia/Dropbox/auditory_HRF/analyses_2025/trial_effects/training_model_fitting_trialeffect_simulatedData.m`
  - `/Users/letitia/Dropbox/auditory_HRF/analyses_2025/trial_effects/training_model_fitting_trialeffect.m`
  - `/Users/letitia/Dropbox/auditory_HRF/analyses_2025/trial_effects/training_model_fitting_trialeffect_sess2.m`
  - `/Users/letitia/Dropbox/auditory_HRF/analyses_2025/trial_effects/analyze_stability_effects.m`
- Step 4: `/Users/letitia/Dropbox/auditory_HRF/analyses_2025/trial_effects/analyze_trial_effects.m`
- Steps 5-10:
  - `/Users/letitia/Dropbox/auditory_HRF/analyses_2025/trial_effects/analyze_stability_effects.m`
  - `/Users/letitia/Dropbox/auditory_HRF/analyses_2025/scripts/surface_run_stability.csh`
- Step 11: https://colab.research.google.com/drive/1NLJ615qBGcbCynxbAGRuJeNykqzylgqV#scrollTo=UwdFpY0nhfZb

## ROIs ERAs: HiHi vs aud HRF

For aud HRF:

- `/Users/letitia/Dropbox/auditory_HRF/analyses_2025/scripts/eras rois/ERAs_forLetitia_rois_nocorrcriteria_avgsessions_n0_tSNRERAsSD.m`
- `/Volumes/Elements/HiHi/ERAs_no_tSNR_corr/test_plot_per_subject.m`

For HiHi:

- `/Volumes/Elements/HiHi/scripts/ERAs_forLetitia_rois_nocorrcriteria_avgsessions_n0_tSNRERAsSD.m`
- `/Volumes/Elements/HiHi/ERAs_no_tSNR_corr/test_plot_per_subject.m`

## ROIs ERAs

- `/Users/letitia/Dropbox/auditory_HRF/analyses_2025/scripts/ERAs_rois_nocorrections.m`
- `/Users/letitia/Dropbox/auditory_HRF/analyses_2025/scripts/ERAs_ROIs_reshape_datatable.m`

## Fitting All Sessions vs One Session

- `/Users/letitia/Dropbox/HiHi/scripts/training_model_fitting_roi_avg_no_ERA_SD_corr_fittingses1.m`
- `/Users/letitia/Dropbox/HiHi/scripts/training_model_fitting_roi_avg_no_ERA_SD_corr_fittingallses.m`

## ROIs Fitting Spreadsheet Copying

- `/Users/letitia/Dropbox/auditory_HRF/analyses_2025/scripts/scatterplot_parameters_audHRF_HiHi_modified020725.m`

## ROIs Scatterplots Dataset Comparison

Initial script:

- `/Users/letitia/Dropbox/auditory_HRF/analyses_2025/scripts/ROI_parameter_corr_plot_audHRF_HiHi.m`

Current workflow:

1. `source .venv/bin/activate` in VS Code
2. Run this in VS Code: `/Users/letitia/Dropbox/auditory_HRF/analyses_2025/scripts/Py_scatterplot_bigplot_correct_CSV.py`

## ROIs Scatterplot Params Comparison for Common Subjects

Medians:

- `/Users/letitia/Dropbox/auditory_HRF/analyses_2025/scripts/Py_scatterplot_ROI_params_medians_commonsubj.py`

## MPM

- `/Users/letitia/Dropbox/auditory_HRF/analyses_2025/MPM/MPM-sample-ROI-letitia.csh`
- `/Users/letitia/Dropbox/auditory_HRF/analyses_2025/scripts/MPM_fmri_analyses_dset1only.m`
- `Users/letitia/Dropbox/auditory_HRF/analyses_2025/MPM/LME_221025.R`

## Fast-slow Maps

1. Get parameters in a spreadsheet for each ROI/Dataset/Hemisphere/Participant
2. Read in relevant parameters and average across hemispheres
3. Get z score for all ROIs per participant and dataset
4. Average across participants to get a zscore list per ROI and per dataset
5. Read in/paste the z scores from step 4 for both datasets; make sure ROI order is correctly defined on top of script
6. Define min and max z value across datasets and normalise map colors accordingly so both datasets are on the same colorscale
7. Plot ROIs in assigned jet colours for both datasets and save png
8. Generate Marty labels in fsaverage; these will be in `freesurfer > subjects > fsaverage`
9. Visualise all labels for one hemisphere, e.g. rh inflated, and colour according to colours created in step 7 for both datasets

Scripts:

- Steps 1-4: `/Users/letitia/Dropbox/auditory_HRF/analyses_2025/ROI_peak_fwhm_amp/zscore_fast_slow_maps.m`
- Steps 4-7: `/Users/letitia/Dropbox/auditory_HRF/analyses_2025/ROI_peak_fwhm_amp/zscore_fast_slow_maps_colourscale.m`
- Steps 8-9: `/Users/letitia/Dropbox/HiHi/scripts/FSaverage_Marty_ROIS.csh`
