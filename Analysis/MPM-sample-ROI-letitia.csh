#! /bin/csh

## spitting out MPM values into Marty ROIs for
## aud HRF project

## Subjects are letsch, fredic, ismzul, matgar, rahraz, ullsat (all -MPM)

## Data are on fred rancate computer
## rearranged some of the internal file structure of directories
## so that recon'd mpms are on top level

## Commented out commands have been run already as had to revise

set mpmdir = /Users/fred/data/RAW/2024-Letitia-HRF-MPMs

cd $mpmdir

# mv 20250529_103007-US 250529US
# mv ismzul-MPMs 241125IZ
#
# foreach dir (231128LS 231214MG 250529US 231206RR 240710FD 241125IZ)
#
# 	ls $mpmdir/$dir/*R1.nii
# 	ls $mpmdir/$dir/*R2s_OLS.nii
# 	ls $mpmdir/$dir/*MTsat.nii
#
# end

## all data are there now

## create symbolic links to ease match
## of subject and MPM

# cd $SUBJECTS_DIR

# ln -s letsch-MPM ./LS-MPM
# ln -s fredic-MPM ./FD-MPM
# ln -s rahraz-MPM ./RR-MPM
# ln -s ismzul-MPM ./IZ-MPM
# ln -s ullsat-MPM ./US-MPM
# ln -s matgar-MPM ./MG-MPM

## Had to remake fred surface as had disappeared
## now there as FD-MPM

## make directory for output crv viles

mkdir /tmp/letitia-MPM-crv
set outdir = /tmp/letitia-MPM-crv

## Tested on FD first, then rerunning with all

## source new freesurfer 7 using alias

fs7

foreach sub (FD IZ LS MG RR US)
	foreach param (R1 R2s_OLS MTsat)
		tkregister2 --regheader --reg $outdir/$sub-$param-reg.dat --s $sub-MPM \
		--mov $mpmdir/*$sub/*$param.nii
	end
end

## switch to fs5

fs5

cd $outdir

foreach sub (FD IZ LS MG RR US)
	foreach hemi (lh rh)
		foreach param (R1 R2s_OLS MTsat)
			mri_vol2surf --mov $mpmdir/*$sub/*$param.nii --reg $outdir/$sub-$param-reg.dat \
			--hemi $hemi --projfrac-avg 0.4 0.6 0.1 --interp trilinear \
			--o $outdir/$sub-$param-$hemi.w --out_type w

			mris_w_to_curv $sub-MPM $hemi $outdir/$sub-$param-$hemi.w \
			$outdir/$sub-$param-$hemi.crv
		end
	end
end

## switch to freesurfer 7

fs7

###
cd $outdir

foreach sub (FD IZ LS MG RR US)
	foreach hemi (lh rh)
		foreach param (R1 R2s_OLS MTsat)
			mris_anatomical_stats -a $SUBJECTS_DIR/$sub-MPM/label/$hemi-CsurfMaps1.annot \
			-f $outdir/$sub-$param-$hemi.table.txt -t $outdir/$hemi.$sub-$param-$hemi.crv \
			-noglobal $sub-MPM $hemi
		end
	end
end


