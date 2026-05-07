% Just in case you need ERAs without CORR correction
%
%
% Input: Timecourse file (+ voxel indices XYZ)
%        Onsets file (stimulus onsets, should correspond to timecourse
%        file)
%        Voxel list after ERA SD correction
% Output:
%       1) ERAs for all sessions (only ER curoff and SD cutoof applied)
%
% Needed for ROI analyses (without corr correction has more voxels)
%
% IZ (2025)

clear
clc
close all
addpath('/Volumes/Elements/HiHi');

% ==================
inpath = '/Volumes/Elements/HiHi';
infile = '_cutoff1500_common_sessions.mat'; % s0X_sessY_outfile
onset_file = '/Volumes/Elements/HiHi/concat_Runs1-6StimTimesHiHi.1D'; % concatenated for all runs to match voxel time course data
voxel_file = '/vox_cutoff1500_cmnSessions_ERA_SD.mat';

outpath = inpath;
outfile = '_smoothed_data_cutoff1500_ERA_SD.mat'; % s0X_outfile, large file, per subject

nSessions = 1:4;
subjects = 1:7; % s0X 1:n

% parameters for timing of event-related averaging
pre_stimulus_duration = 0; % 0 is onset
post_stimulus_duration = 18;
% =================

% file with ERA SD cutoff voxel list
load([inpath voxel_file]);

disp('Getting ERAs...');

for sub = subjects
    average_eras_norm = []; all_reps_eras_norm = [];

    disp(['Subject: ' num2str(sub)]);

    for sess = nSessions
        load([inpath '/s0' num2str(sub) '/ses' num2str(sess) '/s0' num2str(sub) '_ses' num2str(sess) infile]);

        voxel_time_course = voxel_time_course(vox_1500_cmnSessions_ERA_SD{sub},:);

        % Load stimulus onset times from a text file or similar
        stimulus_onsets_file = onset_file;
        stimulus_onsets = load(stimulus_onsets_file);

        % Define parameters for event-related averaging
        temp_ind = pre_stimulus_duration:post_stimulus_duration;

        event_time_courses_norm = [];

        for i = 1:length(stimulus_onsets)
            % Extract time points around each stimulus onset
            window_indices = stimulus_onsets(i)+temp_ind;

            % Extract data for the current event and accumulate it
            temp = voxel_time_course(:,window_indices);

            ii = [find(temp_ind==0)-1 find(temp_ind==0) find(temp_ind==0)+1];
            baseline = mean(voxel_time_course(:,stimulus_onsets(i)+ii),2);

            %baseline = temp(:,temp_ind==0);

            event_time_courses_norm(i,:,:) = ((temp - baseline)./baseline)*100;

            if any([event_time_courses_norm(:)==Inf;find(event_time_courses_norm(:)==-Inf)])
                event_time_courses_norm(event_time_courses_norm==Inf) = nan;
                event_time_courses_norm(event_time_courses_norm==-Inf) = nan;
            end

        end

        all_reps_eras_norm{sess} = event_time_courses_norm;
        average_eras_norm{sess} = squeeze(nanmean(event_time_courses_norm));

        figure(1002); subplot(2,4,sub);
        errorbar(1:post_stimulus_duration+1,nanmean(average_eras_norm{sess}),nanstd(average_eras_norm{sess})./sqrt(size(average_eras_norm{sess},1)), 'LineWidth',2); hold on;
        x = gca; x.YLim = [-0.1 0.2];  ylabel('signal change (%)'); xlabel('TR');
        hold on; grid on; title(['Subject: ' num2str(sub)]);
        x = gca; x.FontSize = 14;

        lgnd{sess} = ['Session: ' num2str(sess)];

    end

    save([inpath '/s0' num2str(sub) '/s0' num2str(sub) outfile], 'average_eras_norm','vox_1500_cmnSessions_ERA_SD_XYZ','all_reps_eras_norm', '-v7.3');

end

legend(lgnd);

disp("Done!");
