#! /bin/csh
##16/05/25: This script is used for showing run stability where we show both Rsq and run at which the Rsq which was in 20% range of the highest Rsq. 
##This script uses output from Isma's 'analyze_stability_effects.m' file
##Because "run" file has one value, e.g. 1 per voxel but interpolating (--projfrac-avg) into the surface
##creates intermediate values, we circumvent this by binarising each group with mri_binarize, and project separately for plotting (https://colab.research.google.com/drive/1NLJ615qBGcbCynxbAGRuJeNykqzylgqV#scrollTo=UwdFpY0nhfZb)
##Adapted from clustgroup_corr script

set dir = /Users/letitia/Dropbox/auditory_HRF/Experiment1/Sep_2023/session_comparison_March
set results_dir = /Users/letitia/Dropbox/auditory_HRF/analyses_2025/trial_effects
set subj = 230920_193223 #S01: 230914_161321, S02: 230914_175651, S03: 230918_133842, S04: 230920_124951, S05: 230920_193223
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

