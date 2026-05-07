% Compute correlation correction cut-offs

% Preferably run for all subjects + sessions together to get 
% estimates of cutoff ACROSS rather per participant (+sessions)

% We correlate ERAs (all repetitons) per voxel in aims of finding
% voxels with most reliable reponses. This is done via arbitraty threshold
% over the correlation distribution across subject

% Input: Timecourse file (+ voxel indices XYZ)
%        Onsets file (stimulus onsets, should correspond to timecourse
%        file)
%        Voxel list after ERA SD correction
% Output: Correlation Cutoffs (A number of percentiles on the final 
%         correlation distribution 70:5:95 are saved). Change as needed.    
%         single output file for all subjects
%  Correlation plots per subject + Figure 1000 for all subjects

clear
clc
close all
addpath('/Volumes/backup_ucl/Letitia/pre-processing scripts/');

% ==============
inpath = '/Volumes/backup_ucl/Letitia/Data_Isma/all_data/all_voxels_smoothed';
infile = '_cutoff1500_common_sessions.mat'; % s0X_sessY_outfile
onset_file = '/Volumes/backup_ucl/Letitia/Data_Isma/concat_Runs1-6StimTimesHRF.1D'; % concatenated for all runs to match voxel time course data
voxel_file = '/vox_cutoff1500_cmnSessions_ERA_SD.mat'; % this is the voxels computed in script v

outpath = inpath;
outfile = '/all_correlation_cutoffs_allSessions_cleanERA_SD.mat';

nSessions = 1:2;
subjects = 1:5; % s0X 1:n

% parameters for timing of event-related averaging
pre_stimulus_duration = 0; % 0 is onset
post_stimulus_duration = 18;
% =============

all_r = []; % i.e., all correlation values will be populated in this variable

% file with ERA SD cutoff voxel list
load([inpath voxel_file]);

for sub = subjects
    disp(['Subject: ' num2str(sub)]);

    tic
    % applying ERA and SD cutoffs
    for sess = nSessions
        % file with time courses
        load([inpath '/s0' num2str(sub) '_ses' num2str(sess) infile]);
 
        % get data from coxels that survive ERA and SD corrections
        voxel_time_course = voxel_time_course(vox_1500_cmnSessions_ERA_SD{sub},:);
        
        voxels = 1:size(voxel_time_course(:,1));

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

            % get baseline
            ii = [find(temp_ind==0)-1 find(temp_ind==0) find(temp_ind==0)+1];
            baseline = mean(voxel_time_course(:,stimulus_onsets(i)+ii),2);

            event_time_courses_norm(i,:,:) = ((temp - baseline)./baseline)*100;

            if any([event_time_courses_norm(:)==Inf;find(event_time_courses_norm(:)==-Inf)])
                event_time_courses_norm(event_time_courses_norm==Inf) = nan;
                event_time_courses_norm(event_time_courses_norm==-Inf) = nan;
            end

        end

        % Computing correlation across repetitions per voxel
        mean_r= [];
        for xx = 1:size(event_time_courses_norm,2)
            R = corrcoef(squeeze(event_time_courses_norm(:,xx,:))');
            r = [];
            for i = 1:length(stimulus_onsets)-1 % all correlations except auto
                r = [r; diag(R,i)];
            end
            mean_r(xx) = mean(r);
        end
        
        figure(sub);
        histogram(mean_r); title('Distribution of cross correlation across trials, all voxels')

        % combining across subjects
        all_r = [all_r,mean_r];

    end

    clear voxel_time_course vox_1500_common_ERA_SD;
    toc
end

figure(1000);
histogram(all_r); title('Distribution of cross correlation across trials, all voxels, all subjects')

% over all correlation computing different cutoffs
lims_corr_95 = prctile(all_r,95);
lims_corr_90 = prctile(all_r,90);
lims_corr_85 = prctile(all_r,85);
lims_corr_80 = prctile(all_r,80);
lims_corr_70 = prctile(all_r,70);

save([outpath outfile], 'all_r',"lims_corr_80",'lims_corr_85','lims_corr_90','lims_corr_95',"lims_corr_70")


