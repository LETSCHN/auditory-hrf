% This script
%       a. finds which voxels survive the correlation correction computed
%       in script vi (saves these at different thresholds) (ERA and SD
%       corrections applied already
%
% Preferably run for all subjects + sessions together
%
% Input: Timecourse file (+ voxel indices XYZ)
%        Onsets file (stimulus onsets, should correspond to timecourse
%        file)
%        Voxel list after ERA SD correction
%        Correlation correction cutoff limits
% Output: Voxels (XYZ+indices) at different corr cutoffs, 70, 85, 90, 95th percentiles

% IZ (2025)

clear
clc
close all
addpath('/Volumes/backup_ucl/Letitia/pre-processing scripts/');

% ==================
inpath = '/Volumes/backup_ucl/Letitia/Data_Isma/all_data/all_voxels_smoothed';
infile = '_cutoff1500_common_sessions.mat'; % s0X_sessY_outfile
onset_file = '/Volumes/backup_ucl/Letitia/Data_Isma/concat_Runs1-6StimTimesHRF.1D'; % concatenated for all runs to match voxel time course data
voxel_file = '/vox_cutoff1500_cmnSessions_ERA_SD.mat'; % this is the voxels computed in script v
correlations_file = '/all_correlation_cutoffs_allSessions_cleanERA_SD.mat'; % has differnt limit values

outpath = inpath;
outfile = '/vox_cutoff1500_commonSessions_cleanERA_SD_CORR.mat';

nSessions = 1:2;
subjects = 1:5; % s0X 1:n

% parameters for timing of event-related averaging
pre_stimulus_duration = 0; % 0 is onset
post_stimulus_duration = 18;

% =============
% laoding files

% file with ERA SD cutoff voxel list
load([inpath voxel_file]);
% file with correlation limits
load([inpath correlations_file],...
    'lims_corr_70', 'lims_corr_85','lims_corr_90','lims_corr_95'); % from all subjects, both sess
% =========

for sub = subjects
    disp(['Subject: ' num2str(sub)]);

    for sess = nSessions
        % loading the common session timecourses
        load([inpath '/s0' num2str(sub) '_ses' num2str(sess) infile],'voxel_time_course','voxels_XYZ');

        voxels = 1:size(voxel_time_course,1);

        % Load stimulus onset times from a text file or similar
        stimulus_onsets_file = onset_file;
        stimulus_onsets = load(stimulus_onsets_file);

        temp_ind = pre_stimulus_duration:post_stimulus_duration;

        event_time_courses_norm = [];

        for i = 1:length(stimulus_onsets)
            % Extract time points around each stimulus onset
            window_indices = stimulus_onsets(i)+temp_ind;

            % Extract data for the current event and accumulate it
            temp = voxel_time_course(:,window_indices);

            ii = [find(temp_ind==0)-1 find(temp_ind==0) find(temp_ind==0)+1];
            baseline = mean(voxel_time_course(:,stimulus_onsets(i)+ii),2);

            event_time_courses_norm(i,:,:) = ((temp - baseline)./baseline)*100;

            if any([event_time_courses_norm(:)==Inf;find(event_time_courses_norm(:)==-Inf)])
                event_time_courses_norm(event_time_courses_norm==Inf) = nan;
                event_time_courses_norm(event_time_courses_norm==-Inf) = nan;
            end

        end

        average_eras_norm = squeeze(nanmean(event_time_courses_norm));

        % get individual correlation coefficients across repetitions (these are per subject)
        mean_r= [];
        for xx = 1:size(event_time_courses_norm,2)
            R = corrcoef(squeeze(event_time_courses_norm(:,xx,:))'); %timepoints x voxel x repetitions
            r = [];
            for i = 1:length(stimulus_onsets)-1 % all correlations except auto
                r = [r; diag(R,i)];
            end
            mean_r(xx) = mean(r);
        end

        % find which voxels are "stable" across checks CORR, ERA lims and
        % SD cutoff
        vox_corr_th_70{sub,sess} = intersect(find(mean_r>lims_corr_70),vox_1500_cmnSessions_ERA_SD{sub});
        vox_corr_th_85{sub,sess} = intersect(find(mean_r>lims_corr_85),vox_1500_cmnSessions_ERA_SD{sub});
        vox_corr_th_90{sub,sess} = intersect(find(mean_r>lims_corr_90),vox_1500_cmnSessions_ERA_SD{sub});
        vox_corr_th_95{sub,sess} = intersect(find(mean_r>lims_corr_95),vox_1500_cmnSessions_ERA_SD{sub});

        % get IJK coordinates
        vox_corr_th_70_XYZ{sub,sess} = voxels_XYZ(vox_corr_th_70{sub,sess},:);
        vox_corr_th_85_XYZ{sub,sess} = voxels_XYZ(vox_corr_th_85{sub,sess},:);
        vox_corr_th_90_XYZ{sub,sess} = voxels_XYZ(vox_corr_th_90{sub,sess},:);
        vox_corr_th_95_XYZ{sub,sess} = voxels_XYZ(vox_corr_th_95{sub,sess},:);
    end

end

save([outpath outfile],"vox_corr_th_70","vox_corr_th_85","vox_corr_th_90","vox_corr_th_95",...
    'vox_corr_th_70_XYZ',"vox_corr_th_85_XYZ",'vox_corr_th_90_XYZ','vox_corr_th_95_XYZ');

disp("Done!")