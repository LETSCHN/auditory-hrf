# Cluster Figure

This document summarises the scripts and data flow used to create the cluster figure outputs.

## Purpose

The cluster figure workflow creates:

- cluster heatmap
- stacked voxel-count bar plot by participant and cluster
- cluster-group surface maps
- session-to-session ERA correlation surface maps

## Workflow

1. Create ERA and clustering input data.

   Script:

   - `For_github/Preprocessing/viii_apply_ERA_SD_commonSess_corr_cutoff.m`

   Outputs:

   - `smoothed_data_cutoff1500_ERA_SD_CORR85.mat`
   - `smoothed_for_clustering_sess1_ERA_SD_CORR85.mat`

2. Cluster session 1 ERA data externally.

   Input:

   - `smoothed_for_clustering_sess1_ERA_SD_CORR85.mat`

   External output files used by later scripts:

   - `Clusters_110425_ses1.txt`
   - `Cluster_means_110425.txt` `(session 1)`

3. Inspect cluster groups.

   Script:

   - `For_github/Analysis/inspect_cluster_groups.m`

   Input:

   - `Cluster_means_110425.txt`

   Role:

   - plots group-average cluster timecourses
   - plots individual cluster timecourses within each group
   - documents the April 2025 cluster grouping used by the figure

4. Assign cluster groups to the full clustered voxel table.

   Script:

   - `For_github/Analysis/assign_cluster_groups.R`

   Input:

   - `Clusters_110425_ses1.txt`

   Output:

   - `cluster_data_280425.txt`

5. Create subject-level cluster-group and correlation text files.

   Script:

   - `For_github/Analysis/Cluster_groups_correlations_analyses_2025.m`

   Inputs:

   - `cluster_data_280425.txt`
   - `smoothed_data_cutoff1500_ERA_SD_CORR85.mat`

   Outputs:

   - `s*_ERA_clustgroup.txt`
   - `s*_ERA_corr.txt`
   - `perS_correlation_summary.csv`
   - `overall_correlation_summary.csv`

6. Project cluster groups and correlations to surface.

   Script:

   - `For_github/Analysis/surface_ERA_corr_clustgroup.csh`

   Inputs:

   - `s*_ERA_clustgroup.txt`
   - `s*_ERA_corr.txt`
   - `*.TSNRavg.zpad.bin_brain_midspace.nii.gz`
   - `midspace_*.reg.dat`

   Outputs:

   - cluster-group surface files
   - ERA correlation surface files

7. Create cluster heatmap and voxel-count plot.

   Script:

   - `For_github/Analysis/Cluster_nvoxels_groups.m`

   Inputs:

   - `Cluster_means_110425.txt`
   - `cluster_data_280425.txt`

   Outputs:

   - cluster heatmap
   - stacked voxel-count bar plot

## Cluster Group Definitions

The April 2025 cluster grouping is defined consistently in:

- `For_github/Analysis/inspect_cluster_groups.m`
- `For_github/Analysis/assign_cluster_groups.R`

Groups:

- Group 1: `18, 19, 20, 21, 22`
- Group 2: `9, 10, 11, 12`
- Group 3: `3, 5, 6`
- Group 4: `4, 13, 14, 16`
- Group 5: `7, 23, 24, 27, 28, 32`
- Group 6: `25, 26, 29, 31, 34`
- Group 7: `30, 33, 35, 36, 37, 38, 39, 40`

Clusters `1`, `2`, `8`, `15`, and `17` are excluded from the grouped plots because they were not assigned to a cluster group.

## Notes

- `Cluster_means_110425.txt` is the session 1 cluster means file.
- `cluster_data_280425.txt` is the full clustered voxel table with cluster IDs and assigned group labels.
- `Cluster_nvoxels_groups.m` loads both files directly; cluster means no longer need to be manually pasted into the script.
