%% ERAs for ERA and SD thresholded voxels in ROIs
%
% some assumptions: ROI txt files in X Y Z format in first 3 columns
% plots ERAs per session, and average of all sessions for all ROIs
%
% Plot responses in all sessions + average over all sessions for all rois,
% all subjects, can save plots if needed
%
% Can run for multiple subjects
%
% IZ (2025)s

clear; clc; close all

% ==================
inpath = '/Volumes/Elements/auditory_HRF/analyses_2025';
% infile_vox = 'vox_cutoff1500_cmnSessions_ERA_SD.mat';
infile_data = '_cutoff1500_common_sessions.mat'; % s0X_sessY_infile_data

hemi = 'lh';

outpath = inpath; % figures and mat saved here
outfile = ['/eras_rois_AudHrf_average_sessions_' hemi '.mat'];

stimulus_onsets_file = '/Volumes/Elements/auditory_HRF/analyses_2025/concat_Runs1-6StimTimesHRF.1D'; %change this if you want to look for low/high salience

roidir = '/Users/letitia/Dropbox/auditory_HRF/analyses_2025/ROIs';
roi_names = {'CL', 'CM', 'CP', 'C_A4', 'C_A5', 'M_A4', 'M_A5', 'MPr', ...
    'MPc', 'AL', 'ML', 'MM', 'A1', 'R_A4', 'R_A5', 'RT', 'RTL', 'R', 'RM', ...
    'RP', 'TA2', 'TA3'};
roi_name_ext = '_new.txt'; % roi_filename is roidir/s0X/sX_hemi_roiname_roiNameExt
nvox = 5; % plot if at least this many voxels

subjects = 1:4;% for hihi = [7,5,3,2];
sessions = 1:2;% for hihi = 1:4

subjects = [1, 2, 3, 4];

% Define a color for each subject (RGB values between 0 and 1)
subject_colors = containers.Map([1, 2, 3, 4], {
    [1.0, 0.5, 0],% Subject 1 - orange
    [0, 0.8, 0],% Subject 2 - green
    [1.0, 0, 0],% Subject 3 - red
    [0, 0.4, 0.8]% Subject 4 - blue
    });
% 
% ==================

% load([inpath infile_vox]); % load voxel indices

nROI = length(roi_names);
colors = lines(nROI); % assign each subject different color
counter = 1;

for sub = subjects
     figure;
    disp('--------------');
    disp(['Subject: ' num2str(sub)]);

    all_data = [];

    for sess = sessions
        disp(['Session: ' num2str(sess)]);

        load([inpath '/ERAs_no_tSNR_corr/s0' num2str(sub) '_ses' num2str(sess) infile_data]);

        all_voxels = voxels_XYZ;

        for roi = 1:nROI

            %% get ROI indices

            new_file = [roidir '/s' num2str(sub) '_' hemi '_' roi_names{roi} roi_name_ext];

            getall = textread(new_file);

            temp = getall(:,1:3);
            roi_inds = temp; %(getall(:,4)==1,:); % use for somato ROIs: temp(:, 1:3); %%use this for Glasser files: temp(getall(:,4)==1,:);

            out = [];

            for i = 1:length(all_voxels)
                for j = 1:length(roi_inds)

                    if all_voxels(i,3) == roi_inds(j,3)
                        if all_voxels(i,2) == roi_inds(j,2)
                            if all_voxels(i,1) == roi_inds(j,1)
                                out(j) = i;
                            end
                        end
                    end
                end
            end

            final_roi = out(out>0);
            final_roi_XYZ = all_voxels(final_roi,:);

            disp(['Total voxels in ' roi_names{roi} ': ' num2str(length(roi_inds))]);
            disp(['Total voxels common+1500 cutoff correction: ' roi_names{roi} ': ' num2str(length(final_roi))]);

            average_eras_norm = [];

            if length(final_roi) > nvox-1 % atleast 5 voxels
                % =========================
                %% getting ERAs


                voxel_time_course_temp = voxel_time_course(final_roi,:);

                % Load stimulus onset times from a text file or similar
                stimulus_onsets = load(stimulus_onsets_file);

                % Define parameters for event-related averaging
                pre_stimulus_duration = 0;
                post_stimulus_duration = 18;
                temp_ind = pre_stimulus_duration:post_stimulus_duration;

                event_time_courses_norm = [];

                for i = 1:length(stimulus_onsets)
                    % Extract time points around each stimulus onset
                    window_indices = stimulus_onsets(i) + temp_ind;

                    % Extract data for the current event and accumulate it
                    temp = voxel_time_course_temp(:, window_indices);

                    ii = [find(temp_ind==0)-1 find(temp_ind==0) find(temp_ind==0)+1];
                    baseline = mean(voxel_time_course_temp(:,stimulus_onsets(i)+ii),2);

                    event_time_courses_norm(i, :, :) = ((temp - baseline) ./ baseline) * 100;

                    if any([event_time_courses_norm(:) == Inf; find(event_time_courses_norm(:) == -Inf)])
                        event_time_courses_norm(event_time_courses_norm == Inf) = nan;
                        event_time_courses_norm(event_time_courses_norm == -Inf) = nan;
                    end
                end

                all_reps_eras_norm = event_time_courses_norm;

                average_eras_norm = squeeze(nanmean(event_time_courses_norm)); % this averages over 1 session

                % figure(sess);
                % subplot(3, ceil(nROI/3), roi); % Create subplots in a single row for each ROI
                % errorbar(0:post_stimulus_duration, nanmean(average_eras_norm), nanstd(average_eras_norm) ./ sqrt(size(average_eras_norm, 1)), 'LineWidth', 2, 'Color', colors(counter, :));
                % hold on;
                % x = gca;            %x.YLim = [-0.3 1];
                % ylabel('signal change (%)'); xlabel('TR');
                % grid on; x.FontSize= 14;
                % title([roi_names{roi} '-' hemi ', Ses' num2str(sess)]);
                % saveas(x,[outpath 's0' num2str(sub) '_ses' num2str(sess) '_' hemi '.fig']);

                all_data{sess,roi} = average_eras_norm; % for averaging over all sessions


            end
           
            % Plotting per session
%             figure(1000);
%             subplot(3, ceil(nROI/3), roi); % Create subplots in a single row for each ROI
%             errorbar(0:post_stimulus_duration, nanmean(average_eras_norm), nanstd(average_eras_norm) ./ sqrt(size(average_eras_norm , 1)), 'LineWidth', 2, 'Color', subject_colors(sub));
%             hold on;
%             x = gca;  ylabel('signal change (%)');  xlabel('TR');
%             grid on; x.FontSize= 14;
%             title([roi_names{roi} '-' hemi]);
%             lgnd{sub} = ['s0' num2str(sub)];

            % individual subject figure
            % figure(100+sub);
            % subplot(3, ceil(nROI/3), roi); % Create subplots in a single row for each ROI
            % errorbar(0:post_stimulus_duration, nanmean(all_avg{sub,roi}), nanstd(all_avg{sub,roi}) ./ sqrt(size(all_avg{sub,roi} , 1)), 'LineWidth', 2, 'Color', colors(counter, :));
            % x = gca;  ylabel('signal change (%)');  xlabel('TR');
            % grid on; x.FontSize= 14;
            % title([roi_names{roi} '-' hemi]);
            % if roi == nROI, legend(['s0' num2str(sub)]); end
            % saveas(x,[outpath 's0' num2str(sub) '_avg_sessions_' hemi '.fig']);
            
        end
    end

    % averaging over sessions
    for roi = 1:nROI
        all_avg{sub, roi} = (all_data{1, roi} + all_data{2, roi}) ; % before from IZ: all_avg{sub,roi} = mean([nanmean(all_data{1,roi}) ; nanmean(all_data{2,roi})]);
    end
    
    %Plotting n sessions per subject
    test = all_data
    data = test
    for roi = 1:nROI
        subplot(3, ceil(nROI/3), roi);
        hold on;
        for sess = 1:length(sessions)
            data = test{sess, roi};% ✅ Correct indexing: (session, ROI)
            mean_data = nanmean(data);
            std_error = nanstd(data) ./ sqrt(size(data, 1));

            errorbar(0:post_stimulus_duration, mean_data, std_error, ...
                'LineWidth', 2, 'Color', subject_colors(sub));% Same color for all sessions
        end
        ylabel('signal change (%)');
        xlabel('TR');
        ylim([-0.5 1]);
        grid on;
        set(gca, 'FontSize', 14);
        title([roi_names{roi} '-' hemi]);
    end

    counter = counter+1;
end


%figure(1000);
%x = gca; %legend(lgnd);
%saveas(x,[outpath 'all_sub_avg_sessions_' hemi '.fig']);

save([outpath outfile],'all_avg',"roi_names",'subjects','hemi');