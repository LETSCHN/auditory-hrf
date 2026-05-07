#! /bin/csh
##02/12/24: This script is used for Fig.1, where we show different shapes derived from cluster (groups) and their reliability across sessions
##This script uses output from Matlab script 'Cluster_groups_correlations_031223'
##Due to two different values per voxel, the files need to be split in two. Because "clustgroup" file has one value, e.g. 1 per voxel but interpolating (--projfrac-avg) into the surface
##creates intermediate values, we circumvent this by binarising each group with mri_binarize, and project separately for plotting (https://colab.research.google.com/drive/1NLJ615qBGcbCynxbAGRuJeNykqzylgqV#scrollTo=UwdFpY0nhfZb)

set dir = /Users/letitia/Documents/auditory_HRF/Experiment1/Sep_2023/session_comparison_March/Clustering_160924_t18_ses1/test291124
set results_dir = /Users/letitia/Documents/auditory_HRF/Experiment1/Sep_2023/session_comparison_March
set subj = 230914_161321 #S01: 230914_161321, S02: 230914_175651, S03: 230918_133842, S04: 230920_124951, S05: 230920_193223
set subject = s1
# 
3dUndump -master $results_dir/$subj/warp/$subj.TSNRavg.zpad.bin_brain_midspace.nii.gz \
-datum float -prefix $dir/"$subj"_clustgroup.nii.gz -ijk $dir/"$subject"_ERA_clustgroup.txt  
# 
foreach i (1 2 3 4 5 6 7)
    mri_binarize --i $dir/"$subj"_clustgroup.nii.gz --min $i --max $i --o $dir/"$subj"_clustgroup_${i}.nii.gz
end

#Change clustgroups_i here. In my experience freesurfer functions don't work great with loops so I do it manually
#Also change registration file according to subject

foreach group (1 2 3 4 5 6 7)
	foreach hemi (lh rh)
		mri_vol2surf --mov $dir/"$subj"_clustgroup_"$group".nii.gz \
		--reg $results_dir/$subj/warp/midspace_S01s1.reg.dat \
		--hemi $hemi --projfrac-avg 0.0 0.8 0.2 --o $dir/"$subject"_"$hemi"_clustergroup_"$group"bin.mgh
	end
end


##CORRELATIONS
# 3dUndump -master $results_dir/$subj/warp/$subj.TSNRavg.zpad.bin_brain_midspace.nii.gz \
# -datum float -prefix $dir/"$subj"_corr.nii.gz -ijk $dir/"$subject"_ERA_corr.txt 
# 
# foreach hemi (lh rh)
# 		mri_vol2surf --mov $dir/"$subj"_corr.nii.gz \
# 		--reg $results_dir/$subj/warp/midspace_S05s1.reg.dat \
# 		--hemi $hemi --projfrac-avg 0.0 0.8 0.2 --o $dir/"$subject"_"$hemi"_corr.mgh
# end