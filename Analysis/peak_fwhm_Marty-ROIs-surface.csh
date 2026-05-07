#! /bin/csh
##21/02/25: This script is used to plot peak and fwhm values of the best model of average ROI from Marty in surface
##It takes the output from Matlab script: training_model_fitting_roi_avg
set results_dir = /Users/letitia/Dropbox/auditory_HRF/Experiment1/Sep_2023/session_comparison_March
set subj = 230920_193223 #S01: 230914_161321, S02: 230914_175651, S03: 230918_133842, S04: 230920_124951, S05: 230920_193223
set subject = s05
# 

# ##PEAK
# foreach hemi (lh rh)
# 	3dUndump -master $results_dir/$subj/warp/$subj.TSNRavg.zpad.bin_brain_midspace.nii.gz \
# 	-datum float -prefix $results_dir/$subj/warp/"$subject"_"$hemi"_peak_Marty_ROIs_bm.nii.gz -ijk $results_dir/$subj/warp/"$subject"_"$hemi"_peak_Marty_ROIs_bm.txt 
# end
# #
# foreach hemi (lh rh)
# 		mri_vol2surf --mov $results_dir/$subj/warp/"$subject"_"$hemi"_peak_Marty_ROIs_bm.nii.gz \
# 		--reg $results_dir/$subj/warp/midspace_"$subject"s1.reg.dat \
# 		--hemi $hemi --projfrac-avg 0.0 0.8 0.2 --o $results_dir/$subj/warp/"$subject"_"$hemi"_peak_Marty_ROIs_bm.mgh
# end
# 
# ##FWHM
# foreach hemi (lh rh)
# 	3dUndump -master $results_dir/$subj/warp/$subj.TSNRavg.zpad.bin_brain_midspace.nii.gz \
# 	-datum float -prefix $results_dir/$subj/warp/"$subject"_"$hemi"_fwhm_Marty_ROIs_bm.nii.gz -ijk $results_dir/$subj/warp/"$subject"_"$hemi"_fwhm_Marty_ROIs_bm.txt 
# end
# foreach hemi (lh rh)
# 		mri_vol2surf --mov $results_dir/$subj/warp/"$subject"_"$hemi"_fwhm_Marty_ROIs_bm.nii.gz \
# 		--reg $results_dir/$subj/warp/midspace_"$subject"s1.reg.dat \
# 		--hemi $hemi --projfrac-avg 0.0 0.8 0.2 --o $results_dir/$subj/warp/"$subject"_"$hemi"_fwhm_Marty_ROIs_bm.mgh
# end
# 

##AMP
foreach hemi (lh rh)
	3dUndump -master $results_dir/$subj/warp/$subj.TSNRavg.zpad.bin_brain_midspace.nii.gz \
	-datum float -prefix $results_dir/$subj/warp/"$subject"_"$hemi"_amp_Marty_ROIs_bm.nii.gz -ijk $results_dir/$subj/warp/"$subject"_"$hemi"_amp_Marty_ROIs_bm.txt 
end

foreach hemi (lh rh)
		mri_vol2surf --mov $results_dir/$subj/warp/"$subject"_"$hemi"_amp_Marty_ROIs_bm.nii.gz \
		--reg $results_dir/$subj/warp/midspace_"$subject"s1.reg.dat \
		--hemi $hemi --projfrac-avg 0.0 0.8 0.2 --o $results_dir/$subj/warp/"$subject"_"$hemi"_amp_Marty_ROIs_bm.mgh
end


# freeview -f $results_dir/$subj/warp/"$subject"_lh_fwhm_Marty_ROIs_bm.mgh
# freeview -f $results_dir/$subj/warp/"$subject"_rh_fwhm_Marty_ROIs_bm.mgh
# 