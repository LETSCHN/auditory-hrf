#! /bin/csh

##This pre-processing script uses afni proc-py to remove initial TRs, motion- and distortion correct EPI data
# min_outlier is used because external volreg base won't get distortion corrected.
#
##Letitia Schneider, July 2024

#E.g. run tcsh Pre-processing_aud_HRF.csh sub-02 /path/to/func /path/to/proc fmap_AP fmap_PA run1 run2 run3 run4 run5 run6

if ( $#argv < 11 ) then
    echo "Usage:"
    echo "  tcsh $0 <subj> <func_dir> <proc_dir> <forward_fmap> <reverse_fmap> <run1> <run2> <run3> <run4> <run5> <run6> [init_discard_TR] [session] [fs_subject] [subjects_dir] [bbregister_mov] [bbregister_reg_file]"
    exit 1
endif

set subj = "$argv[1]"
set func_dir = "$argv[2]"
set proc_dir = "$argv[3]"
set forward = "$argv[4]"
set reverse = "$argv[5]"
set run_1 = "$argv[6]"
set run_2 = "$argv[7]"
set run_3 = "$argv[8]"
set run_4 = "$argv[9]"
set run_5 = "$argv[10]"
set run_6 = "$argv[11]"

set init_discard_TR = 8
if ( $#argv >= 12 ) then
    set init_discard_TR = "$argv[12]"
endif

set session = 1
if ( $#argv >= 13 ) then
    set session = "$argv[13]"
endif

set fs_subject = ""
if ( $#argv >= 14 ) then
    set fs_subject = "$argv[14]"
endif

set subjects_dir = "$SUBJECTS_DIR"
if ( $#argv >= 15 ) then
    set subjects_dir = "$argv[15]"
endif

set bbreg_mov = "min_outlier_session${session}.nii.gz"
if ( $#argv >= 16 ) then
    set bbreg_mov = "$argv[16]"
endif

set bbreg_file = "midspace_${subj}_ses-${session}.reg.dat"
if ( $#argv >= 17 ) then
    set bbreg_file = "$argv[17]"
endif

set results_dir = "${proc_dir}/${subj}.results"

set dset_1 = "${func_dir}/${subj}/${run_1}.nii"
set dset_2 = "${func_dir}/${subj}/${run_2}.nii"
set dset_3 = "${func_dir}/${subj}/${run_3}.nii"
set dset_4 = "${func_dir}/${subj}/${run_4}.nii"
set dset_5 = "${func_dir}/${subj}/${run_5}.nii"
set dset_6 = "${func_dir}/${subj}/${run_6}.nii"
set forward_dset = "${func_dir}/${subj}/${forward}.nii"
set reverse_dset = "${func_dir}/${subj}/${reverse}.nii"

echo "afni_proc.py -subj_id ${subj} -dsets ${dset_1} ${dset_2} ${dset_3} ${dset_4} ${dset_5} ${dset_6} -blocks volreg regress -volreg_align_to MIN_OUTLIER -blip_forward_dset ${forward_dset} -blip_reverse_dset ${reverse_dset} -tcat_remove_first_trs ${init_discard_TR}"

if ( ! -d "$proc_dir" ) then
    echo "ERROR: proc_dir does not exist: $proc_dir"
    exit 1
endif

cd "$proc_dir"

afni_proc.py -subj_id "$subj" -dsets                                      \
    "$dset_1" "$dset_2" "$dset_3" "$dset_4" "$dset_5" "$dset_6"           \
    -blocks volreg regress                                                \
    -volreg_align_to MIN_OUTLIER                                          \
    -blip_forward_dset "$forward_dset"                                    \
    -blip_reverse_dset "$reverse_dset"                                    \
    -tcat_remove_first_trs "$init_discard_TR"

echo "Generated proc script should be: ${proc_dir}/proc.${subj}"

cat >> "${proc_dir}/proc.${subj}" << EOF

# Save the AFNI min-outlier volume as a NIfTI file for later registration/QC.
3dZeropad -I 6 -S 6 -prefix "\$output_dir/min_outlier_session${session}.nii.gz" "\$output_dir/vr_base_min_outlier+orig"
rm -f "\$output_dir"/vr_base_min_outlier+orig.*
EOF

echo "Added min-outlier NIfTI export to: ${proc_dir}/proc.${subj}"

if ( "$fs_subject" != "" ) then
    if ( "$subjects_dir" == "" ) then
        echo "ERROR: SUBJECTS_DIR is not set. Provide it as argument 15 or export SUBJECTS_DIR before running this script."
        exit 1
    endif

    cat >> "${proc_dir}/proc.${subj}" << EOF

# Register the min-outlier EPI image to the FreeSurfer anatomical surface.
# This block requires FreeSurfer and should be run after the min-outlier image exists.
bbregister --s "${fs_subject}" --mov "\$output_dir/${bbreg_mov}" --reg "\$output_dir/${bbreg_file}" --T2
tkregisterfv --mov "\$output_dir/${bbreg_mov}" --reg "\$output_dir/${bbreg_file}" --surfs --sd "${subjects_dir}"
EOF

    echo "Added FreeSurfer registration/QC block to: ${proc_dir}/proc.${subj}"
    echo "Registration file will be: ${results_dir}/${bbreg_file}"
else
    echo "Optional FreeSurfer registration can be added by passing:"
    echo "  <session> <fs_subject> [subjects_dir] [bbregister_mov] [bbregister_reg_file]"
endif

cat >> "${proc_dir}/proc.${subj}" << EOF

# Remove large intermediate files after preprocessing and registration/QC setup.
rm -f "\$output_dir"/pb00.*
rm -f "\$output_dir"/pb01.*
rm -f "\$output_dir"/pb03.*
rm -f "\$output_dir"/blip_warp_Rev_WARP*
rm -f "\$output_dir"/errts.*
rm -f "\$output_dir"/all_runs.*
EOF

echo "Added cleanup commands to: ${proc_dir}/proc.${subj}"

echo "Run it manually with:"
echo "  tcsh -xef proc.${subj} |& tee output.proc.${subj}"
