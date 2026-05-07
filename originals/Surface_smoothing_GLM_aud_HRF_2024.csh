#! /bin/csh

#This script smoothes EPI data in surface space, taking vasculature into account by removing low tSNR voxels 
#Per subject and session, (un)smoothed data convolved with TWOGAM and CSPLIN will be available
#Letitia Schneider, July 2024

## CHANGE
set subj = S02_s2 #S01: 230914_161321, S02: 230914_175651, S03: 230918_133842,S04: 230920_124951, S05: 230920_193223; session2: S01: 230922_161751, for S02: 230922_151637, S03: 230926_131602, S04: 230927_145751, S05: 230927_183731

set statsdir = /Users/letitia/Documents/auditory_HRF/Experiment1/Sep_2023/$subj.results #relevant for 3dDecon, also storing demeaned motion parameters in here
cd $statsdir
mkdir CSPLIN
mkdir TWOGAM
set CSPLIN = $statsdir/CSPLIN
set TWOGAM = $statsdir/TWOGAM

##CHANGE
set results_dir = $CSPLIN 
set initial_results_dir = $results_dir
cd $results_dir
mkdir noblur.results
set results_dir = $results_dir/noblur.results

# 1. Create tSNR maps for each run 
foreach run (pb02."$subj".r01.volreg+orig pb02."$subj".r02.volreg+orig pb02."$subj".r03.volreg+orig \
pb02."$subj".r04.volreg+orig pb02."$subj".r05.volreg+orig pb02."$subj".r06.volreg+orig)
	3dTstat -prefix $results_dir/rm.mean."$run" $statsdir/$run							#create mean signal of each run
	3dTstat -stdev -prefix $results_dir/rm.stdev."$run" $statsdir/$run					#create stdev of each run's timeseries
	3dcalc -a $results_dir/rm.mean."$run"                                        					 \
	-b $results_dir/rm.stdev."$run"				                                        			 \
	-expr 'a/b' -prefix $results_dir/TSNR.$run
end       	


# # # # 2. Calculate average tSNR of all runs' tSNR to use as mask for surface smoothing
cd $results_dir
3dMean -prefix $results_dir/TSNR."$subj".allruns.nii.gz TSNR.pb02."$subj".r01.volreg+orig TSNR.pb02."$subj".r02.volreg+orig TSNR.pb02."$subj".r03.volreg+orig \
TSNR.pb02."$subj".r04.volreg+orig  TSNR.pb02."$subj".r05.volreg+orig  TSNR.pb02."$subj".r06.volreg+orig 

# # # # # # # ##Check how many volumes the image has, it should be 1 
echo "The image you just created has this number of volumes:"
3dinfo -nt $results_dir/TSNR."$subj".allruns.nii.gz

# # # # # # ## 3. Binarise tSNR average over of all runs (== exclude low tSNR voxels from mask)
3dcalc -a $results_dir/TSNR."$subj".allruns.nii.gz -expr 'step(a-35)' \
 -prefix $results_dir/TSNRbigger35.$subj
# # #  
3dcopy $results_dir/TSNRbigger35."$subj"+orig $results_dir/TSNRbigger35."$subj".nii.gz #convert into zipped file
# 
# # 4. On a run-by-run basis, A) create a mask that excludes low tSNR voxels, B) use mask for smoothing within cortical ribbon
# # C) Multiply that output with the mask again to avoid partial volume effects, D) Scale image by using mean
# 
# # #Simplify run names and convert into zipped nifti format
foreach run (r01 r02 r03 r04 r05 r06)
	3dcopy $statsdir/pb02."$subj".$run.volreg+orig $results_dir/$run.nii.gz      
end   
############################################################################################################
## With smoothing
if ( "$results_dir" == "$initial_results_dir/noblur.results" ) then
    ## Without smoothing
    foreach run (r01 r02 r03 r04 r05 r06)
        3dcalc -a $results_dir/TSNRbigger35."$subj".nii.gz -b $results_dir/"$run".nii.gz 			   \
        -expr 'a*b' -prefix $results_dir/TSNRbigger35_"$run".nii.gz         								
        3dTstat -prefix $results_dir/"$run".rm.mean.nii $results_dir/TSNRbigger35_"$run".nii.gz  			
        3dcalc -a $results_dir/TSNRbigger35_"$run".nii.gz  -b $results_dir/"$run".rm.mean.nii			\
        -expr 'min(200, a/b*100)*step(a)*step(b)' -prefix $results_dir/"$run"_scale.nii.gz												
    end

    set run1 = r01_scale
    set run2 = r02_scale
    set run3 = r03_scale
    set run4 = r04_scale
    set run5 = r05_scale
    set run6 = r06_scale

else
    ## With smoothing
    foreach run (r01 r02 r03 r04 r05 r06)
        3dcalc -a $results_dir/TSNRbigger35."$subj".nii.gz -b $results_dir/"$run".nii.gz				  \
        -expr 'a*b' -prefix $results_dir/TSNRbigger35_"$run".nii.gz         								
        mris_volsmooth --i $results_dir/TSNRbigger35_"$run".nii.gz --o $results_dir/"$run"_smoothed.nii.gz \
        --reg $statsdir/"$subj".reg.dat --projfrac-avg 0.2 0.8 0.3 --fwhm 2 										
        3dcalc -a  $results_dir/TSNRbigger35_"$run".nii.gz  -b $results_dir/"$run"_smoothed.nii.gz 			\
        -expr 'a*b' -prefix $results_dir/"$run"_smoothed_final.nii.gz										
        3dTstat -prefix $results_dir/"$run".rm.mean.nii $results_dir/"$run"_smoothed_final.nii.gz			
        3dcalc -a $results_dir/"$run"_smoothed_final.nii.gz -b $results_dir/"$run".rm.mean.nii				\
        -expr 'min(200, a/b*100)*step(a)*step(b)' -prefix $results_dir/"$run"_smoothed.scale.nii.gz												
    end

    set run1 = r01_smoothed.scale
    set run2 = r02_smoothed.scale
    set run3 = r03_smoothed.scale
    set run4 = r04_smoothed.scale
    set run5 = r05_smoothed.scale
    set run6 = r06_smoothed.scale
endif
############################################################################################################
#Check results
# afni $results_dir
rm $results_dir/TSNRbigger35_r*.nii.gz  
rm $results_dir/TSNR.pb*
rm $results_dir/TSNRbigger35.*+orig.*
rm $results_dir/r01.nii.gz $results_dir/r02.nii.gz $results_dir/r03.nii.gz $results_dir/r04.nii.gz $results_dir/r05.nii.gz $results_dir/r06.nii.gz
rm $results_dir/r0*_smoothed.nii.gz
rm $results_dir/r0*_smoothed_final.nii.gz
rm $results_dir/r0*.rm.mean.nii.gz
rm $results_dir/rm.*
rm $results_dir/r0*.rm.mean.nii

# # 5. 3dDeconvolve
cd $results_dir
if ( "$initial_results_dir" == "$CSPLIN" ) then
    3dDeconvolve -input $results_dir/$run1.nii.gz $results_dir/$run2.nii.gz $results_dir/$run3.nii.gz \
    $results_dir/$run4.nii.gz $results_dir/$run5.nii.gz $results_dir/$run6.nii.gz                      \
        -ortvec $statsdir/motion_demean.1D mot_demean                  \
        -polort 2 -float                                               \
        -num_stimts 1                                                  \
        -stim_times 1 /Users/letitia/Documents/auditory_HRF/Experiment1/Runs1-6StimTimesHRF.1D  'CSPLINzero(0,20,21)' \
        -stim_label 1 hrf                                              \
        -iresp 1 iresp_hrf.$subj                                       \
        -jobs 4                                                        \
        -gltsym 'SYM: hrf'                                             \
        -glt_label 1 HRF                                               \
        -fout -tout -x1D X.xmat.1D -xjpeg X.jpg   					   \
        -x1D_uncensored X.nocensor.xmat.1D               			   \
        -errts errts.${subj}                                           \
        -bucket stats.$subj
else if ( "$initial_results_dir" == "$TWOGAM" ) then
    3dDeconvolve -input $results_dir/$run1.nii.gz $results_dir/$run2.nii.gz $results_dir/$run3.nii.gz \
    $results_dir/$run4.nii.gz $results_dir/$run5.nii.gz $results_dir/$run6.nii.gz                      \
        -ortvec $statsdir/motion_demean.1D mot_demean                  \
        -polort 2 -float                                               \
        -num_stimts 1                                                  \
        -stim_times 1 /Users/letitia/Documents/auditory_HRF/Experiment1/Runs1-6StimTimesHRF.1D  'TWOGAMpw(2,5,0.2,8,10,1)' \
        -stim_label 1 hrf                                              \
        -jobs 4                                                        \
        -gltsym 'SYM: hrf'                                             \
        -glt_label 1 HRF                                               \
        -fout -tout -x1D X.xmat.1D -xjpeg X.jpg  					   \
        -x1D_uncensored X.nocensor.xmat.1D            			       \
        -errts errts.${subj}                                           \
        -bucket stats.$subj
endif
############################################################################################################
1d_tool.py -show_df_info -infile X.xmat.1D |& tee out.df_info.txt
# # 
# # -- execute the 3dREMLfit script, written by 3dDeconvolve --
tcsh -x stats.REML_cmd 

#if 3dREMLfit fails, terminate the script
if ( $status != 0 ) then
    echo '---------------------------------------'
    echo '** 3dREMLfit error, failing...'
    exit
endif

rm $results_dir/errts.*
