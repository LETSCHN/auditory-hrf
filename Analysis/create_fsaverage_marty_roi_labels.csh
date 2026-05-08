#! /bin/csh
## To visualise z-score colours for the fast-slow maps, we use the
## fsaverage Marty ROI labels.
##
## Input:
## - CsurfMaps1 annotation files for fsaverage.
## Output:
## - Left- and right-hemisphere Marty ROI labels in fsaverage label folders.
##
## Last changed May 2026 (LS)

foreach hemi (lh rh)
	mri_annotation2label \
	  --subject fsaverage \
	  --hemi $hemi \
	  --annotation /path/to/csurf/subjects/fsaverage-ADDITIONS/label/$hemi-CsurfMaps1.annot \
	  --outdir $FREESURFER_HOME/subjects/fsaverage/label/labels_$hemi
end
