#! /bin/csh

##This pre-processing script uses afni proc-py to remove initial TRs, motion- and distortion correct EPI data, registers EPI to surface
# min_outlier is used because external volreg base won't get distortion corrected. Regress block is used because demeaned motion runs are used for 3dDecon
##Letitia Schneider, July 2024

## CHANGE 
set subj = 230922_151637
set subjectname = rahraz 
##
set func_dir = /Users/letitia/Documents/auditory_HRF/DICOMS/fspace
set subj_dir = /Users/letitia/Documents/auditory_HRF/Experiment1/Sep_2023
set results_dir = /Users/letitia/Documents/auditory_HRF/Experiment1/Sep_2023/$subj.results
cd subj_dir

## SET A > P AND P > A (SB volumes)

set forward = 230922_151637_cmrr_mbep2d_AudHRF-Run1_20230922151826_3
set reverse = 230922_151637_cmrr_mbep2d_AudHRF-Run1-PERev_20230922151826_5
 
# # ## HERE, SET VARIABLE NAMES FOR RUNS 1-6 
 
set run_1 = 230922_151637_cmrr_mbep2d_AudHRF-Run1_20230922151826_4
set run_2 = 230922_151637_cmrr_mbep2d_AudHRF-Run2_20230922151826_8
set run_3 = 230922_151637_cmrr_mbep2d_AudHRF-Run3_20230922151826_10
set run_4 = 230922_151637_cmrr_mbep2d_AudHRF-Run4_20230922151826_12
set run_5 = 230922_151637_cmrr_mbep2d_AudHRF-Run5_20230922151826_14
set run_6 = 230922_151637_cmrr_mbep2d_AudHRF-Run6_20230922151826_16

## number of TRs to discard for *each run*
 
set init_discard_TR = 8 # call this in the script 
 
afni_proc.py -subj_id $subj -dsets                                                         		                    \
	$func_dir/$subj/$run_1.nii $func_dir/$subj/$run_2.nii $func_dir/$subj/$run_3.nii $func_dir/$subj/$run_4.nii $func_dir/$subj/$run_5.nii $func_dir/$subj/$run_6.nii	\
    -blocks volreg regress 									                        		                 		\
    -volreg_align_to MIN_OUTLIER																					\
    -blip_forward_dset $func_dir/$subj/$forward.nii																	\
	-blip_reverse_dset $func_dir/$subj/$reverse.nii																	\
	-tcat_remove_first_trs $init_discard_TR 	

# csh proc.$subj

rm $results_dir/pb00.*
rm $results_dir/pb01.*
rm $results_dir/pb03.* 
rm $results_dir/blip_warp_Rev_WARP*
rm $results_dir/errts.*
rm $results_dir/all_runs.*