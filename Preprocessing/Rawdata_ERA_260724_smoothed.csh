#! /bin/csh

## This script prepares smoothed EPI time courses for event-related-average
# analyses across two sessions. It first creates a high tSNR mask,
# then starts from the AFNI preprocessed volreg runs,
# warps each run to session midspace, smooths the midspace runs on the surface,
# concatenates runs, and dumps masked time courses to text files.
#
## Letitia Schneider, July 2024

if ( $#argv < 5 ) then
    echo "Usage:"
    echo "  tcsh $0 <session_comparison_dir> <preproc_dir> <session1_id> <session2_id> <registration_id> [tsnr_threshold] [fwhm] [nitorch_env]"
    echo ""
    echo "Example:"
    echo "  tcsh $0 /path/to/session_comparison /path/to/preproc sub-01_ses-01 sub-01_ses-02 sub-01_ses-01 35 2 nitorch"
    exit 1
endif

set dir = "$argv[1]"
set fdir = "$argv[2]"
set subjses1 = "$argv[3]"
set subjses2 = "$argv[4]"
set subjreg = "$argv[5]"

set tsnr_threshold = 35
if ( $#argv >= 6 ) then
    set tsnr_threshold = "$argv[6]"
endif

set smooth_fwhm = 2
if ( $#argv >= 7 ) then
    set smooth_fwhm = "$argv[7]"
endif

set nitorch_env = "nitorch"
if ( $#argv >= 8 ) then
    set nitorch_env = "$argv[8]"
endif

conda activate "$nitorch_env"

# Create the high-tSNR brain mask used for extracting ERA time courses.
foreach ses ($subjses1)
    set warp_dir = "$dir/$ses/warp"
    set results_dir = "$fdir/$ses.results"

    foreach run (01 02 03 04 05 06)
        set run_label = r"$run"

        3dTstat -prefix "$warp_dir/rm.mean.pb02.$ses.$run_label.volreg" \
            "$results_dir/pb02.$ses.$run_label.volreg+orig"

        3dTstat -stdev -prefix "$warp_dir/rm.stdev.pb02.$ses.$run_label.volreg" \
            "$results_dir/pb02.$ses.$run_label.volreg+orig"

        3dcalc                                                    \
            -a "$warp_dir/rm.mean.pb02.$ses.$run_label.volreg+orig" \
            -b "$warp_dir/rm.stdev.pb02.$ses.$run_label.volreg+orig" \
            -expr 'a/b'                                          \
            -prefix "$warp_dir/TSNR.pb02.$ses.$run_label.volreg"
    end

    3dMean -prefix "$warp_dir/TSNR.$ses.allruns.nii.gz"          \
        "$warp_dir/TSNR.pb02.$ses.r01.volreg+orig"               \
        "$warp_dir/TSNR.pb02.$ses.r02.volreg+orig"               \
        "$warp_dir/TSNR.pb02.$ses.r03.volreg+orig"               \
        "$warp_dir/TSNR.pb02.$ses.r04.volreg+orig"               \
        "$warp_dir/TSNR.pb02.$ses.r05.volreg+orig"               \
        "$warp_dir/TSNR.pb02.$ses.r06.volreg+orig"

    3dZeropad -I 6 -S 6                                      \
        -prefix "$warp_dir/TSNR.allruns.zpad.nii.gz"          \
        "$warp_dir/TSNR.$ses.allruns.nii.gz"

    nitorch reslice "$warp_dir/TSNR.allruns.zpad.nii.gz"      \
        -il2 "$warp_dir/rigid.lta"                            \
        -iv2 "$warp_dir/svf.nii.gz"                           \
        -t "$warp_dir/svf.nii.gz"                             \
        -i 3                                                   \
        -o "$warp_dir/$ses.TSNRavg.zpad.midspace.nii.gz"

    3dcalc -a "$warp_dir/$ses.TSNRavg.zpad.midspace.nii.gz"   \
        -expr "step(a-$tsnr_threshold)"                       \
        -prefix "$warp_dir/$ses.TSNRavg.zpad.bin_midspace.nii.gz"

    3dAutomask                                                \
        -prefix "$warp_dir/min_outlier_zpad_brain_session1.midspace.nii.gz" \
        "$warp_dir/min_outlier_zpad_session1.midspace.nii.gz"

    3dcalc                                                    \
        -a "$warp_dir/min_outlier_zpad_brain_session1.midspace.nii.gz" \
        -b "$warp_dir/$ses.TSNRavg.zpad.bin_midspace.nii.gz"  \
        -expr 'and(a,b)'                                      \
        -prefix "$warp_dir/$ses.TSNRavg.zpad.bin_brain_midspace.nii.gz"

    rm -f "$warp_dir"/rm.mean.pb02.$ses.r*.volreg+orig.*
    rm -f "$warp_dir"/rm.stdev.pb02.$ses.r*.volreg+orig.*
    rm -f "$warp_dir"/TSNR.pb02.$ses.r*.volreg+orig.*
end

foreach ses ($subjses2)
    set warp_dir = "$dir/$ses/warp"
    set results_dir = "$fdir/$ses.results"

    foreach run (01 02 03 04 05 06)
        set run_label = r"$run"

        3dTstat -prefix "$warp_dir/rm.mean.pb02.$ses.$run_label.volreg" \
            "$results_dir/pb02.$ses.$run_label.volreg+orig"

        3dTstat -stdev -prefix "$warp_dir/rm.stdev.pb02.$ses.$run_label.volreg" \
            "$results_dir/pb02.$ses.$run_label.volreg+orig"

        3dcalc                                                    \
            -a "$warp_dir/rm.mean.pb02.$ses.$run_label.volreg+orig" \
            -b "$warp_dir/rm.stdev.pb02.$ses.$run_label.volreg+orig" \
            -expr 'a/b'                                          \
            -prefix "$warp_dir/TSNR.pb02.$ses.$run_label.volreg"
    end

    3dMean -prefix "$warp_dir/TSNR.$ses.allruns.nii.gz"          \
        "$warp_dir/TSNR.pb02.$ses.r01.volreg+orig"               \
        "$warp_dir/TSNR.pb02.$ses.r02.volreg+orig"               \
        "$warp_dir/TSNR.pb02.$ses.r03.volreg+orig"               \
        "$warp_dir/TSNR.pb02.$ses.r04.volreg+orig"               \
        "$warp_dir/TSNR.pb02.$ses.r05.volreg+orig"               \
        "$warp_dir/TSNR.pb02.$ses.r06.volreg+orig"

    3dZeropad -I 6 -S 6                                      \
        -prefix "$warp_dir/TSNR.allruns.zpad.nii.gz"          \
        "$warp_dir/TSNR.$ses.allruns.nii.gz"

    nitorch reslice "$warp_dir/TSNR.allruns.zpad.nii.gz"      \
        -l2 "$warp_dir/rigid.lta"                             \
        -v2 "$warp_dir/svf.nii.gz"                            \
        -t "$warp_dir/svf.nii.gz"                             \
        -i 3                                                   \
        -o "$warp_dir/$ses.TSNRavg.zpad.midspace.nii.gz"

    3dcalc -a "$warp_dir/$ses.TSNRavg.zpad.midspace.nii.gz"   \
        -expr "step(a-$tsnr_threshold)"                       \
        -prefix "$warp_dir/$ses.TSNRavg.zpad.bin_midspace.nii.gz"

    3dAutomask                                                \
        -prefix "$warp_dir/min_outlier_zpad_brain_session2.midspace.nii.gz" \
        "$warp_dir/min_outlier_zpad_session2.midspace.nii.gz"

    3dcalc                                                    \
        -a "$warp_dir/min_outlier_zpad_brain_session2.midspace.nii.gz" \
        -b "$warp_dir/$ses.TSNRavg.zpad.bin_midspace.nii.gz"  \
        -expr 'and(a,b)'                                      \
        -prefix "$warp_dir/$ses.TSNRavg.zpad.bin_brain_midspace.nii.gz"

    rm -f "$warp_dir"/rm.mean.pb02.$ses.r*.volreg+orig.*
    rm -f "$warp_dir"/rm.stdev.pb02.$ses.r*.volreg+orig.*
    rm -f "$warp_dir"/TSNR.pb02.$ses.r*.volreg+orig.*
end

foreach ses ($subjses1)
    set warp_dir = "$dir/$ses/warp"
    set results_dir = "$fdir/$ses.results"

    foreach run (01 02 03 04 05 06)
        set run_label = r"$run"

        3dcopy "$results_dir/pb02.$ses.$run_label.volreg+orig" \
            "$results_dir/pb02.$ses.$run_label.volreg.nii.gz"

        3dZeropad -I 6 -S 6                                      \
            -prefix "$warp_dir/pb02.$ses.$run_label.volreg_zpad.nii.gz" \
            "$results_dir/pb02.$ses.$run_label.volreg.nii.gz"

        nitorch reslice "$warp_dir/pb02.$ses.$run_label.volreg_zpad.nii.gz" \
            -il2 "$warp_dir/rigid.lta"                                     \
            -iv2 "$warp_dir/svf.nii.gz"                                    \
            -t "$warp_dir/svf.nii.gz"                                      \
            -i 3                                                            \
            -o "$warp_dir/$ses.$run.midspace.nii.gz"

        mris_volsmooth --i "$warp_dir/$ses.$run.midspace.nii.gz"            \
            --o "$warp_dir/${run_label}_midspace_smoothed_$ses.nii.gz"      \
            --reg "$warp_dir/midspace_$subjreg.reg.dat"                    \
            --projfrac-avg 0.2 0.8 0.3                                      \
            --fwhm "$smooth_fwhm"

        rm -f "$results_dir/pb02.$ses.$run_label.volreg.nii.gz"             \
            "$warp_dir/pb02.$ses.$run_label.volreg_zpad.nii.gz"
    end
end

3dTcat -prefix "$dir/$subjses1/warp/allruns_midspace_smoothed_$subjses1.nii.gz" \
    "$dir/$subjses1/warp/r01_midspace_smoothed_$subjses1.nii.gz"          \
    "$dir/$subjses1/warp/r02_midspace_smoothed_$subjses1.nii.gz"          \
    "$dir/$subjses1/warp/r03_midspace_smoothed_$subjses1.nii.gz"          \
    "$dir/$subjses1/warp/r04_midspace_smoothed_$subjses1.nii.gz"          \
    "$dir/$subjses1/warp/r05_midspace_smoothed_$subjses1.nii.gz"          \
    "$dir/$subjses1/warp/r06_midspace_smoothed_$subjses1.nii.gz"

foreach ses ($subjses2)
    set warp_dir = "$dir/$ses/warp"
    set results_dir = "$fdir/$ses.results"

    foreach run (01 02 03 04 05 06)
        set run_label = r"$run"

        3dcopy "$results_dir/pb02.$ses.$run_label.volreg+orig" \
            "$results_dir/pb02.$ses.$run_label.volreg.nii.gz"

        3dZeropad -I 6 -S 6                                      \
            -prefix "$warp_dir/pb02.$ses.$run_label.volreg_zpad.nii.gz" \
            "$results_dir/pb02.$ses.$run_label.volreg.nii.gz"

        nitorch reslice "$warp_dir/pb02.$ses.$run_label.volreg_zpad.nii.gz" \
            -l2 "$warp_dir/rigid.lta"                                      \
            -v2 "$warp_dir/svf.nii.gz"                                     \
            -t "$warp_dir/svf.nii.gz"                                      \
            -i 3                                                            \
            -o "$warp_dir/$ses.$run.midspace.nii.gz"

        mris_volsmooth --i "$warp_dir/$ses.$run.midspace.nii.gz"            \
            --o "$warp_dir/${run_label}_midspace_smoothed_$ses.nii.gz"      \
            --reg "$dir/$subjses1/warp/midspace_$subjreg.reg.dat"          \
            --projfrac-avg 0.2 0.8 0.3                                      \
            --fwhm "$smooth_fwhm"

        rm -f "$results_dir/pb02.$ses.$run_label.volreg.nii.gz"             \
            "$warp_dir/pb02.$ses.$run_label.volreg_zpad.nii.gz"
    end
end

3dTcat -prefix "$dir/$subjses2/warp/allruns_midspace_smoothed_$subjses2.nii.gz" \
    "$dir/$subjses2/warp/r01_midspace_smoothed_$subjses2.nii.gz"          \
    "$dir/$subjses2/warp/r02_midspace_smoothed_$subjses2.nii.gz"          \
    "$dir/$subjses2/warp/r03_midspace_smoothed_$subjses2.nii.gz"          \
    "$dir/$subjses2/warp/r04_midspace_smoothed_$subjses2.nii.gz"          \
    "$dir/$subjses2/warp/r05_midspace_smoothed_$subjses2.nii.gz"          \
    "$dir/$subjses2/warp/r06_midspace_smoothed_$subjses2.nii.gz"

3dmaskdump                                                            \
    -o "$dir/$subjses1/warp/${subjses1}_timecourse_ses1_midspace_brain_smooth_hightSNR.txt" \
    -mask "$dir/$subjses1/warp/$subjses1.TSNRavg.zpad.bin_brain_midspace.nii.gz" \
    -nozero "$dir/$subjses1/warp/allruns_midspace_smoothed_$subjses1.nii.gz"

3dmaskdump                                                            \
    -o "$dir/$subjses2/warp/${subjses2}_timecourse_ses2_midspace_brain_smooth_hightSNR.txt" \
    -mask "$dir/$subjses2/warp/$subjses2.TSNRavg.zpad.bin_brain_midspace.nii.gz" \
    -nozero "$dir/$subjses2/warp/allruns_midspace_smoothed_$subjses2.nii.gz"
