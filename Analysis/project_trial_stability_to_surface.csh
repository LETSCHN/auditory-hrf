#! /bin/csh
##This script is used for showing run stability where we show both Rsq and the run at which Rsq was within 80% of the highest Rsq.
##Input: subject-specific s0X_run.txt and s0X_rsq.txt files from analyze_trial_effect_stability.m, plus the subject midspace master image and registration file.
##Output: subject-specific run and Rsq NIfTI files and surface-projected .mgh files.
##This script uses output from analyze_trial_effect_stability.m
##Because "run" file has one value, e.g. 1 per voxel but interpolating (--projfrac-avg) into the surface
##creates intermediate values, we circumvent this by binarising each group with mri_binarize, and project separately for plotting (https://colab.research.google.com/drive/1NLJ615qBGcbCynxbAGRuJeNykqzylgqV#scrollTo=UwdFpY0nhfZb)
##Adapted from clustgroup_corr script
##Last changed May 2026 (LS)

set dir = /path/to/auditory_HRF/Experiment1/Sep_2023/session_comparison_March
set results_dir = /path/to/auditory_HRF/analyses_2025/trial_effects
set subj = dataset1_sub05_session_dir #S01: dataset1_sub01_session_dir, S02: dataset1_sub02_session_dir, S03: dataset1_sub03_session_dir, S04: dataset1_sub04_session_dir, S05: dataset1_sub05_session_dir
set subject = s05
set subjreg = S05s1

##RUNS

##1. Create EPI from text file
3dUndump -master $dir/$subj/warp/$subj.TSNRavg.zpad.bin_brain_midspace.nii.gz \
-datum float -prefix $results_dir/"$subject"_run.nii.gz -ijk $results_dir/"$subject"_run.txt  

##2. Binarise to avoid intermediate values on surface
foreach i (1 2 3 4 5 6)
    mri_binarize --i $results_dir/"$subject"_run.nii.gz --min $i --max $i --o $results_dir/"$subject"_run_${i}.nii.gz
end

##3. Project into surface
foreach run (1 2 3 4 5 6)
	foreach hemi (lh rh)
		mri_vol2surf --mov $results_dir/"$subject"_run_"$run".nii.gz \
		--reg $dir/$subj/warp/midspace_"$subjreg".reg.dat \
		--hemi $hemi --projfrac-avg 0.0 0.8 0.2 --o $results_dir/"$subject"_"$hemi"_run_"$run"bin.mgh
	end
end

##RSQUARES

3dUndump -master $dir/$subj/warp/$subj.TSNRavg.zpad.bin_brain_midspace.nii.gz \
-datum float -prefix $results_dir/"$subject"_rsq.nii.gz -ijk $results_dir/"$subject"_rsq.txt 

foreach hemi (lh rh)
		mri_vol2surf --mov $results_dir/"$subject"_rsq.nii.gz \
		--reg $dir/$subj/warp/midspace_"$subjreg".reg.dat \
		--hemi $hemi --projfrac-avg 0.0 0.8 0.2 --o $results_dir/"$subject"_"$hemi"_rsq.mgh
end
