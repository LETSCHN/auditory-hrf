#! /bin/csh
##21-11-25: To visualise the colours according to zscore for the fast slow maps we use the fsaverage map
## But first, we need to get Marty's labels for the fsaverage

foreach hemi (lh rh)
	mri_annotation2label \
	  --subject fsaverage \
	  --hemi $hemi \
	  --annotation /Users/letitia/csurf/subjects/fsaverage-ADDITIONS/label/$hemi-CsurfMaps1.annot \
	  --outdir $FREESURFER_HOME/subjects/fsaverage/label/labels_$hemi
end