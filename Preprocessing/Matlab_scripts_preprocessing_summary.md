# Pre-processing Scripts Summary

This folder contains MATLAB scripts for converting AFNI voxel time-course text
files into smaller `.mat` files, filtering voxels, computing event-related
averages (ERAs), and selecting reliable voxels using ERA/SD and correlation
criteria.

Script folder:

```text
scripts/pre-processing scripts/
```

The scripts are named in pipeline order:

```text
i_process_txtfiles.m
ii_1500cutoff.m
iii_get_common_voxels_sessions.m
iv_get_era_sd_cutoffs.m
v_apply_era_sd_cutoff_commonSessions.m
vi_get_corr_cutoff.m
vii_get_voxel_ERA_SD_CORRth.m
viii_apply_ERA_SD_commonSess_corr_cutoff.m
ix_get_ERAs_no_corrth.m
```

## Important Notes

- Most scripts contain hard-coded paths, subject ranges, session ranges, and
  file suffixes. Check the configuration block near the top of each script
  before running.
- Several scripts assume subject folders like `s01`, `s02`, etc. and session
  folders like `ses1`, `ses2`, etc.
- The ERA window is usually set from stimulus onset to 18 TRs after onset:
  `pre_stimulus_duration = 0`, `post_stimulus_duration = 18`.
- Baseline is computed from three time points around onset:
  `onset-1`, `onset`, and `onset+1`.
- Percent signal change is computed as:

```matlab
((response - baseline) ./ baseline) * 100
```

## Pipeline Overview

1. Convert large AFNI `.txt` files into smaller MATLAB chunks.
2. Remove low-intensity voxels using a `1500` threshold.
3. Keep only voxels present across all requested sessions.
4. Estimate ERA and trial-to-trial SD thresholds.
5. Apply ERA and SD thresholds to define a cleaned voxel set.
6. Estimate correlation thresholds from trial-wise ERA reliability.
7. Save voxel sets that pass different correlation thresholds.
8. Compute ERAs and cross-session reliability for correlation-filtered voxels.
9. Optionally compute ERAs without the correlation threshold.

## Script Details

### 1. `i_process_txtfiles.m`

Purpose:

Converts large AFNI pre-processed voxel time-course `.txt` files into smaller
`.mat` chunks that are faster to load in later scripts.

Expected input:

```text
s0X/s0X_timecourse_sesY_meanspace_brain_smooth.txt
```

The text file is assumed to have rows formatted as:

```text
i j k timepoint_1 timepoint_2 ... timepoint_N
```

Main outputs:

```text
s0X/sesY/s0X_timecourse_sesY_partZ.mat
```

Key variables saved:

```matlab
test
```

Notes:

- The script saves a new part file every `50000` voxels.
- `nTimePoints` must match the number of time points in the AFNI text file.
- Remove text headers before running.

### 2. `ii_1500cutoff.m`

Purpose:

Combines the chunked `.mat` files for each session and removes low-intensity
voxels. Voxels are discarded if any time point is below `1500`.

Expected input:

```text
s0X/sesY/s0X_timecourse_sesY_partZ.mat
```

Main outputs:

```text
s0X/sesY/s0X_sesY_cutoff1500.mat
```

Key variables saved:

```matlab
voxels_XYZ
voxel_time_course
voxels
```

Notes:

- Set `nParts` to match the number of part files created by
  `i_process_txtfiles.m`.
- The `1500` threshold is intended to remove zero/low-value edge voxels.

### 3. `iii_get_common_voxels_sessions.m`

Purpose:

Finds voxels that survive the `1500` cutoff and are present in all requested
sessions. This produces session-specific time courses restricted to the common
voxel set.

Expected input:

```text
s0X/sesY/s0X_sesY_cutoff1500.mat
```

Main outputs:

```text
s0X/sesY/s0X_sesY_cutoff1500_common_sessions.mat
```

Key variables saved:

```matlab
voxels_XYZ
voxel_time_course
```

Notes:

- Preferably run this across all sessions intended for later comparison.
- If only one session is requested, the script simply saves that session's
  voxel data.

### 4. `iv_get_era_sd_cutoffs.m`

Purpose:

Computes event-related responses and trial-to-trial standard deviations across
common-session voxels. It estimates percentile-based thresholds for later voxel
cleaning.

Expected input:

```text
s0X/sesY/s0X_sesY_cutoff1500_common_sessions.mat
concat_Runs1-6StimTimesHRF.1D
```

Main outputs:

```text
s0X/s0X_cutoff1500_commonsessions_stats.mat
s0X_all_sd_cutoff1500_commonsesssions.mat
```

Key variables saved:

```matlab
limspt01   % 0.01 and 99.99 percentiles of ERA values
lims1      % 1 and 99 percentiles of ERA values
sd_95      % 95th percentile of trial SD values
sd_98      % 98th percentile of trial SD values
all_sd
```

Notes:

- Also plots ERA and standard deviation histograms for each subject.
- Use the resulting percentiles to choose `lims` and `lim_sd` in the next
  script.

### 5. `v_apply_era_sd_cutoff_commonSessions.m`

Purpose:

Applies ERA amplitude limits and trial-to-trial SD limits to remove noisy or
implausible voxels. It then keeps voxels common across sessions after these
corrections.

Expected input:

```text
s0X_sesY_cutoff1500_common_sessions.mat
concat_Runs1-6StimTimesHRF.1D
```

Main output:

```text
vox_cutoff1500_cmnSessions_ERA_SD.mat
```

Key variables saved:

```matlab
vox_1500_cmnSessions_ERA_SD
vox_1500_cmnSessions_ERA_SD_XYZ
```

Important parameters:

```matlab
lims = [-13 12];  % ERA value limits
lim_sd = 2.7;     % trial SD cutoff
```

Notes:

- Adjust `lims` and `lim_sd` based on outputs from
  `iv_get_era_sd_cutoffs.m`.

### 6. `vi_get_corr_cutoff.m`

Purpose:

Estimates correlation thresholds for trial-wise ERA reliability. For each voxel,
the script correlates responses across repetitions and aggregates the
correlation distribution across subjects/sessions.

Expected input:

```text
s0X_sesY_cutoff1500_common_sessions.mat
vox_cutoff1500_cmnSessions_ERA_SD.mat
concat_Runs1-6StimTimesHRF.1D
```

Main output:

```text
all_correlation_cutoffs_allSessions_cleanERA_SD.mat
```

Key variables saved:

```matlab
all_r
lims_corr_70
lims_corr_80
lims_corr_85
lims_corr_90
lims_corr_95
```

Notes:

- The script plots correlation distributions per subject and across all
  subjects.
- Thresholds are percentile-based and can be changed depending on analysis
  stringency.

### 7. `vii_get_voxel_ERA_SD_CORRth.m`

Purpose:

Applies the correlation thresholds from script 6 to the ERA/SD-cleaned voxel
set. Saves voxel indices and coordinates for multiple correlation thresholds.

Expected input:

```text
s0X_sesY_cutoff1500_common_sessions.mat
vox_cutoff1500_cmnSessions_ERA_SD.mat
all_correlation_cutoffs_allSessions_cleanERA_SD.mat
concat_Runs1-6StimTimesHRF.1D
```

Main output:

```text
vox_cutoff1500_commonSessions_cleanERA_SD_CORR.mat
```

Key variables saved:

```matlab
vox_corr_th_70
vox_corr_th_85
vox_corr_th_90
vox_corr_th_95
vox_corr_th_70_XYZ
vox_corr_th_85_XYZ
vox_corr_th_90_XYZ
vox_corr_th_95_XYZ
```

Notes:

- The `85th` percentile threshold is used as the default in the next script,
  but this can be changed.

### 8. `viii_apply_ERA_SD_commonSess_corr_cutoff.m`

Purpose:

Computes ERAs for voxels that pass all corrections: `1500` cutoff, common
session requirement, ERA/SD cleanup, and correlation threshold. It also computes
cross-session ERA reliability.

Expected input:

```text
s0X_sesY_cutoff1500_common_sessions.mat
vox_cutoff1500_commonSessions_cleanERA_SD_CORR.mat
concat_Runs1-6StimTimesHRF.1D
```

Main outputs:

```text
smoothed_data_cutoff1500_ERA_SD_CORR85.mat
smoothed_for_clustering_sess1_ERA_SD_CORR85.mat
```

Key variables saved:

```matlab
average_eras_norm
all_reps_eras_norm
r_spearman
r_pearson
vox_corr_th_85_XYZ
for_clustering
```

Notes:

- The default threshold is `vox_corr_th_85`.
- Cross-session correlations are computed between session 1 and later
  sessions.
- The clustering output combines subjects into rows with:

```text
i, j, k, subject, ERA_timepoints...
```

### 9. `ix_get_ERAs_no_corrth.m`

Purpose:

Computes ERAs after the `1500`, common-session, ERA, and SD filters, but without
applying the correlation threshold. This is useful for ROI analyses where a
larger voxel set is needed.

Expected input:

```text
s0X/sesY/s0X_sesY_cutoff1500_common_sessions.mat
vox_cutoff1500_cmnSessions_ERA_SD.mat
concat_Runs1-6StimTimesHiHi.1D
```

Main output:

```text
s0X/s0X_smoothed_data_cutoff1500_ERA_SD.mat
```

Key variables saved:

```matlab
average_eras_norm
all_reps_eras_norm
vox_1500_cmnSessions_ERA_SD_XYZ
```

Notes:

- This script is an alternative endpoint to the correlation-thresholded
  pipeline.
- It is useful when downstream analyses should include voxels that pass ERA/SD
  cleanup but not necessarily correlation reliability filtering.

## Typical Outputs by Stage

| Stage | Output |
|---|---|
| Text split | `s0X_timecourse_sesY_partZ.mat` |
| Intensity cutoff | `s0X_sesY_cutoff1500.mat` |
| Common sessions | `s0X_sesY_cutoff1500_common_sessions.mat` |
| ERA/SD stats | `s0X_cutoff1500_commonsessions_stats.mat` |
| ERA/SD voxel list | `vox_cutoff1500_cmnSessions_ERA_SD.mat` |
| Correlation thresholds | `all_correlation_cutoffs_allSessions_cleanERA_SD.mat` |
| Correlation voxel list | `vox_cutoff1500_commonSessions_cleanERA_SD_CORR.mat` |
| Correlation-filtered ERAs | `smoothed_data_cutoff1500_ERA_SD_CORR85.mat` |
| Clustering table | `smoothed_for_clustering_sess1_ERA_SD_CORR85.mat` |
| ERAs without correlation filter | `s0X_smoothed_data_cutoff1500_ERA_SD.mat` |

## Before Running on a New Dataset

Check and update:

- `inpath` and `outpath`
- subject list, e.g. `subjects = 1:7`
- session list, e.g. `nSessions = 1:4`
- number of time points, e.g. `nTimePoints = 1452`
- number of text-file chunks, e.g. `nParts = 2`
- stimulus onset file path
- ERA window
- ERA and SD thresholds
- correlation threshold selected for final output

