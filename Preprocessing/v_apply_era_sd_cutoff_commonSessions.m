% Applies the std dev and ER response corrections computed in script iv
% Saves final voxel list with 1500 cutoff + Common b/w sessions + ER response 
% and SD corrections
%
% Note this script should preferably run over all subjects to get estimates of cutoff
%
% Input: 
%       Timecourse file (+ voxel indices) 
%       Onset files (stimulus onsets) corresponding to timecourse file
% Output: Voxel list (XYZ) which survives the ERA and SD correction

% IZ (2025)

clear
clc
close all
addpath('/path/to/preprocessing_scripts');

% ============
inpath = '/path/to/processed_timecourses';
infile = '_cutoff1500_common_sessions.mat'; % s0X_sessY_outfile
onset_file = '/path/to/stimulus_onsets.1D'; % concatenated for all runs to match voxel time course data

outpath = inpath;
outfile = '/vox_cutoff1500_common_sessions_ERA_SD.mat'; % s0X_outfile, ONLY voxel indices

lims = [-13 12]; % ERA limits... note these as min and max for all subjects from s0X_cutoff1500_common_sessions_stats.mat
lim_sd = 2.7; % std dev limits... avg/max

nSessions = 1:2; 
subjects = 1:5; % s0X 1:n

% parameters for timing of event-related averaging
pre_stimulus_duration = 0; % 0 is onset
post_stimulus_duration = 18;
% ===========

for sub = subjects
    disp(['Subject: ' num2str(sub)]);

    tic
    final = {};
    for sess = nSessions
        load([inpath '/s0' num2str(sub) '_ses' num2str(sess) infile]);

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

        clear voxel_time_course;

        % find voxels outside ERA ranges mentioned in lims
        inds = [];
        
        for i = 1:length(stimulus_onsets)
            curr = squeeze(event_time_courses_norm(i,:,:));

            [x1,y] = find(curr<lims(1));
            [x2,y] = find(curr>lims(2));

            inds = [inds;x1;x2];
        end

        % find voxels with larger std deviation than lim_sd
        for i = 1:length(pre_stimulus_duration:post_stimulus_duration)
            curr = squeeze(nanstd(event_time_courses_norm(:,:,i),[],1));

            [x1,y] = find(curr'>lim_sd);

            inds = [inds;x1];
        end

        sort(inds);

        % remove the two sets of voxels computed above
        ii = unique(inds); 
        voxels_temp{sess} = setxor(voxels,ii);
    end

    temp = [];
    temp = voxels_temp{1}; % sess 1

    % find common voxels across sessions after corrections
    if nSessions(end) > 1
        for sess = nSessions(2:end)
            temp = intersect(temp,voxels_temp{sess});
        end
    end

    disp(['Final nvox: ' num2str(length(temp))]);

    vox_1500_common_sessions_ERA_SD{sub} = temp;
    vox_1500_common_sessions_ERA_SD_XYZ{sub} = voxels_XYZ(vox_1500_common_sessions_ERA_SD{sub},:);

    toc
end

save([outpath outfile],"vox_1500_common_sessions_ERA_SD_XYZ",'vox_1500_common_sessions_ERA_SD');

