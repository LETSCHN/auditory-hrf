% COMPUTE CUTOFFS using ERA and SDs
% get ER responses (per vox, all trials) and SD (across trials, per voxel) cutoffs 
% per subject for voxels with 1500 cutoff + common voxels between sessions

% This helps us in cleaning up the data and remove voxels with very noisy data

% baseline for ER responses = average of responses at times onset-1, onset, onset+1
% ER responses in % signal change computed as:
%           (response - baseline) / baseline
%
% Input: Timecourse file 
% Output: We save following limits for event related average data: 
%               0.01st & 99.99th percentile and
%               1st & 99th percentile of the event related responses
%         For std dev we save 95th and 98th percentile
%   Plots per subject
%
% IZ (2025)

clear
clc
close all
addpath('/path/to/processed_timecourses');

% ============ 
inpath = '/path/to/processed_timecourses';
infile = '_cutoff1500_common_sessions.mat'; % s0X_sessY_infile
onset_file = '/path/to/stimulus_onsets.1D'; % concatenated for all runs to match voxel time course data

outpath = inpath;
outfile_cutoff = '_cutoff1500_common_sessions_stats.mat'; % s0X_outfile
outfile_sd = '_all_sd_cutoff1500_commonsesssions.mat'; % s0X_outfile, all sd saved in case needed

nSessions = 1:4;
subjects = 1:7; % s0X

% parameters for timing of event-related averaging
pre_stimulus_duration = 0; % 0 is onset
post_stimulus_duration = 18;
% ============ 

for sub = subjects
    disp(['Subject: ' num2str(sub)]);
    tic

    all_sd = []; % sd per voxel, per timepoint
    all_data = []; % for era, all vox, all timepoints

    for sess = nSessions
        load([inpath '/s0' num2str(sub) '/ses' num2str(sess) '/s0' num2str(sub) '_ses' num2str(sess) infile]);

        voxels = 1:size(voxel_time_course(:,1));

        % Load stimulus onset times from a text file or similar
        stimulus_onsets_file = onset_file;
        stimulus_onsets = load(stimulus_onsets_file);

        temp_ind = pre_stimulus_duration:post_stimulus_duration;

        %voxel_time_course = squeeze(epi_data(voxels{sub,sess}, :));

        event_time_courses_norm = [];

        for i = 1:length(stimulus_onsets)
            % Extract time points around each stimulus onset
            window_indices = stimulus_onsets(i)+temp_ind;

            temp = voxel_time_course(:,window_indices);

            ii = [find(temp_ind==0)-1 find(temp_ind==0) find(temp_ind==0)+1];
            baseline = mean(voxel_time_course(:,stimulus_onsets(i)+ii),2);

            event_time_courses_norm(i,:,:) = ((temp - baseline)./baseline)*100;

            if any([event_time_courses_norm(:)==Inf;find(event_time_courses_norm(:)==-Inf)])
                event_time_courses_norm(event_time_courses_norm==Inf) = nan;
                event_time_courses_norm(event_time_courses_norm==-Inf) = nan;
            end
        end

        all_data = [all_data; event_time_courses_norm(~isnan(event_time_courses_norm))];
        all_sd = [all_sd; squeeze(nanstd(event_time_courses_norm(:,:,1:end),[],1))];

    end

    limspt01 = prctile(all_data(:),[0.01 99.99]); 
    lims1 = prctile(all_data(:),[1 99]); 
    disp('0.01st and 99.99th percentile: '); disp(limspt01);
    disp('1st and 99th percentile: '); disp(lims1);

    sd_95 = prctile(all_sd(:),95);
    sd_98 = prctile(all_sd(:),98); 
    disp('95th percentile of std dev: '); disp(sd_95);
    disp('98th percentile of std dev: '); disp(sd_98);


    save([outpath '/s0' num2str(sub) '/s0' num2str(sub) outfile_cutoff],'limspt01','lims1','sd_95', 'sd_98');

    figure(sub); subplot(1,2,1); 
    histogram(all_data); title('All Event-Related-Averages')
    xlabel('Signal Change (%)');

    figure(sub); subplot(1,2,2); 
    histogram(all_sd); title('Std dev across trials, all voxels')
    xlabel('Std dev');

    save([outpath '/s0' num2str(sub) outfile_sd], 'all_sd')

    toc
end

disp('Done!')
