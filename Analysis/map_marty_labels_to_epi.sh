#! /bin/csh
##22-11-24: This script is used to get Marty's auditory labels in native subject space.
##Because the labels are in fsaverage space they need to be put in native space using surf2surf
##NOTE: Labels outside auditory cortex (>80) don't seem to map to cortex accurately
##Last changed May 2026 (LS)

set dir = /path/to/external_drive/replication_dataset
set subjreg = S07s1
set subj = dataset2_sub07_session_dir
set subject = dataset2_sub07
set subjectname = s07
set sub = s7

# cd $dir/$subjectname
# mkdir ROIs
set roi_dir = $dir/$subjectname/ROIs

# foreach hemi (lh rh)
# 	mri_surf2surf --srcsubject fsaverage \
#               --trgsubject $subject \
#               --hemi $hemi \
#               --sval-annot $SUBJECTS_DIR/$hemi-CsurfMaps1.annot \
#               --tval /path/to/user_documents/subjects/$subject/label/$hemi.fsaverage.aparc.annot
# end

# foreach hemi (lh rh)
# 	foreach label (58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79)
# 		mri_annotation2label --subject $subject --hemi $hemi --annotation fsaverage.aparc --label $label --outdir $SUBJECTS_DIR/$subject/label
# 	end
# end

#Now put labels into EPI space
#LH
# foreach roi (RP	R_A4	M_A4	MPr	C_A4	MPc	CP	TA3	TA2	RTL	AL	ML	RM	MM	CL	CM	A1	RT	R)
# 		mri_label2vol --o $roi_dir/"$subjectname"_lh_"$roi".nii.gz --label $SUBJECTS_DIR/$subject/label/lh."$roi".label \
# 		--temp $dir/$subjectname/norm/opt/min_outlier_zpad_session1.norm.nii.gz --hemi lh --proj frac 0 0.8 0.2 --fillthresh 0.5 --subject $subject --reg $dir/$subjectname/meanspace_"$subjreg".reg.dat
# end

#RH
# foreach roi (RP	R_A4	M_A4	MPr	C_A4	MPc	CP	TA3	TA2	RTL	AL	ML	RM	MM	CL	CM	A1	RT	R)
# 		mri_label2vol --o $roi_dir/"$subjectname"_rh_"$roi".nii.gz --label $SUBJECTS_DIR/$subject/label/rh."$roi".label \
# 		--temp $dir/$subjectname/norm/opt/min_outlier_zpad_session1.norm.nii.gz --hemi rh --proj frac 0 0.8 0.2 --fillthresh 0.5 --subject $subject --reg $dir/$subjectname/meanspace_"$subjreg".reg.dat
# end	

#Get ROIs in text format
foreach hemi (lh rh)
	foreach roi (RP	R_A4	M_A4	MPr	C_A4	MPc	CP	TA3	TA2	RTL	AL	ML	RM	MM	CL	CM	A1	RT	R)
		3dmaskdump -o $roi_dir/"$sub"_"$hemi"_"$roi".txt -mask $roi_dir/"$subjectname"_"$hemi"_"$roi".nii.gz $dir/$subjectname/norm/opt/min_outlier_zpad_session1.norm.nii.gz
	end
end	


