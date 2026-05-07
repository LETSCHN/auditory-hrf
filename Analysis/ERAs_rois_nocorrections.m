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
% IZ (2025)

clear; clc; close all

% ==================
inpath = ['/Volumes/Elements/HiHi/']; %dataset1:/Volumes/Elements/auditory_HRF/analyses_2025/
infile_vox = 'vox_cutoff1500_cmnSessions_ERA_SD.mat';
infile_data = '_cutoff1500_common_sessions.mat'; % s0X_sessY_infile_data

hemi = 'l6ceh';

outpath = [inpath]; % figures and mat saved here
outfile = ['eras_rois_sessions_' hemi '.mat'];

stimulus_onsets_file = [inpath 'concat_Runs1-6StimTimesHiHi.1D']; %change this if you want change dataset

roidir = ['/Users/letitia/Dropbox/HiHi/ROIs/ROIs'];
roi_names = {'CL', 'CM', 'CP', 'C_A4', 'C_A5', 'M_A4', 'M_A5', 'MPr', ...
    'MPc', 'AL', 'ML', 'MM', 'A1', 'R_A4', 'R_A5', 'RT', 'RTL', 'R', 'RM', ...
    'RP', 'TA2', 'TA3'};
roi_name_ext = '_new.txt'; % roi_filename is roidir/s0X/sX_hemi_roiname_roiNameExt
nvox = 5; % plot if atleast this many voxels

subjects = 1:7;% for hihi = [7,5,3,2];
sessions = 1:4;% for hihi = 1:4

% ==================


nROI = length(roi_names);
colors = lines(nROI); % assign each subject different color
counter = 1;

for sub = subjects
    disp('--------------');
    disp(['Subject: ' num2str(sub)]);

    load([inpath 's0' num2str(sub) '/ses1' '/s0' num2str(sub) '_ses1' infile_data],'voxels_XYZ');
    all_voxels = voxels_XYZ;

    for roi = 1:nROI

        all_data = [];

        %% get ROI indices

        new_file = [roidir '/s' num2str(sub) '_' hemi '_' roi_names{roi} roi_name_ext];

        getall = textread(new_file);

        temp = getall(:,1:3);
        roi_inds = temp; %(getall(:,4)==1,:); % use for somato ROIs: temp(:, 1:3); %%use this for Glasser files: temp(getall(:,4)==1,:);

        out = [];

        for i = 1:size(all_voxels,1) %no of columns
            for j = 1:size(roi_inds,1)

                if all_voxels(i,3) == roi_inds(j,3) %check if coordinates match for voxels and rois
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
        disp(['Total voxels in ROI common between sessions: ' roi_names{roi} ': ' num2str(length(final_roi))]);

        if length(final_roi) > nvox-1 % atleast 5 voxels
            % =========================
            %% getting ERAs
            for sess = sessions
                disp(['Session: ' num2str(sess)]);

                avg = [];
                load([inpath 's0' num2str(sub) '/ses' num2str(sess) '/s0' num2str(sub) '_ses' num2str(sess) infile_data]);
                voxel_time_course = voxel_time_course(final_roi,:);
                %                 voxel_time_course = voxel_time_course(vox_cutoff1500_cmnSessions_ERA_SD{1,sub}(final_roi),:);

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
                    temp = voxel_time_course(:, window_indices);

                    ii = [find(temp_ind==0)-1 find(temp_ind==0) find(temp_ind==0)+1];
                    baseline = mean(voxel_time_course(:,stimulus_onsets(i)+ii),2);

                    event_time_courses_norm(i, :, :) = ((temp - baseline) ./ baseline) * 100;

                    if any([event_time_courses_norm(:) == Inf; find(event_time_courses_norm(:) == -Inf)])
                        event_time_courses_norm(event_time_courses_norm == Inf) = nan;
                        event_time_courses_norm(event_time_courses_norm == -Inf) = nan;
                    end
                end

                all_reps_eras_norm = event_time_courses_norm;

                average_eras_norm = squeeze(nanmean(event_time_courses_norm)); % this averages over all trials (=session)
                %If you want to save all voxels within ROI, take out
                all_data{sess} = average_eras_norm; %this keeps all voxels per ROI

                %                 all_data(sess,:,:) = average_eras_norm; % for averaging
                %                 over all voxels


            end
            all_data_sessions{sub,roi} = all_data; % cell array: {session}{voxels × timepoints}

            % all_data_sessions{sub,roi} = squeeze(mean(all_data,2)); %
            % stores ERA per session averaged across voxels per ROI

            % Plotting per session
            figure(sub); clf; % Clear figure for current subject

            for roi = 1:nROI
                subplot(3, ceil(nROI/3), roi); % Create subplot for each ROI

                % Check if data exists for this subject and ROI
                if sub <= size(all_data_sessions, 1) && roi <= size(all_data_sessions, 2)
                    roi_data = all_data_sessions{sub, roi}; % cell array of 4 sessions

                    if ~isempty(roi_data)
                        for sess = 1:length(roi_data)
                            session_data = roi_data{sess}; % [voxels × timepoints]

                            if ~isempty(session_data)
                                mean_data = mean(session_data, 1); % mean across voxels
                                plot(0:post_stimulus_duration, mean_data, 'LineWidth', 2);
                                hold on;
                            end
                        end
                    end
                end

                ylabel('signal change (%)');
                xlabel('TR');
                ylim([-0.5 1.5]);
                grid on;
                set(gca, 'FontSize', 14);
                title([roi_names{roi} ' - ' hemi]);

                if roi == nROI
                    legend({'Session 1', 'Session 2', 'Session 3', 'Session 4'}, 'Location', 'best');
                end
            end

        end
    end
    counter = counter+1;
end
save([outpath outfile],'all_data_sessions',"roi_names",'subjects','sessions','hemi');