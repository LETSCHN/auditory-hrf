# Figure Trial Effects

This workflow fits voxelwise HRF models, estimates how model fits change as trials/runs accumulate, identifies stable voxels and the run at which each voxel stabilises, then prepares run-stability and adjusted R-squared files for surface plotting.

## GitHub Files

- `Analysis/simulate_trial_effect_data.m`
- `Analysis/fit_trial_effect_models_simulated_data.m`
- `Analysis/fit_trial_effect_models_all_sessions.m`
- `Analysis/fit_trial_effect_models_single_session.m`
- `Analysis/analyze_trial_effect_stability.m`
- `Analysis/plot_trial_effect_trajectories.m`
- `Analysis/project_trial_stability_to_surface.csh`

These scripts also depend on the shared HRF fitting helper functions in `Analysis/`, including the bound-check functions.

## Workflow Steps

1. Run `simulate_trial_effect_data.m` and `fit_trial_effect_models_simulated_data.m` for simulated-data trial-effect checks.
2. Run `fit_trial_effect_models_all_sessions.m` for observed trial-effect fitting across sessions.
3. Run `fit_trial_effect_models_single_session.m` for the single-session version. It is currently configured with `sess = 2`, which creates the session-2 trajectory input.
4. Run `analyze_trial_effect_stability.m` to identify stable voxels and create run/R-squared outputs.
5. Run `plot_trial_effect_trajectories.m` to create the trial-effects trajectory figure.
6. Run `project_trial_stability_to_surface.csh` to convert stability text files to volume/surface maps for plotting.

## External Inputs And Outputs

Large derived files are not included in the GitHub upload. Expected local inputs/outputs include:

- `smoothed_data_cutoff1500_ERA_SD_CORR85.mat`
- `simulated_data_nVox1000_288reps.mat` or generated simulated-data `.mat` files
- `training_s*_trialeffect.mat`
- `training_s*_sess2_trialeffect.mat`
- `stability_allsubs_20pcnt.mat`
- subject-specific `s*_run.txt` and `s*_rsq.txt`
- derived `.nii.gz` and `.mgh` surface-projection outputs

