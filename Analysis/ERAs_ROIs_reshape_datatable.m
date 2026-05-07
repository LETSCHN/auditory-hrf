%%%This script is used to put the ERAs from each ROI each session in a data
%%%table to use in other programs (e.g. JMP)

% inpath = ['/Volumes/Elements/HiHi/']; %dataset1:/Volumes/Elements/auditory_HRF/analyses_2025/
% infile_data = 'eras_rois_sessions_'; % s0X_sessY_infile_data
% outpath = [inpath];
% 
% hemi = 'lh'; % or 'rh'
% nSessions = 4; % Assuming fixed
% nTimePoints = 19; % Assuming fixed
% load([inpath infile_data hemi '.mat'],'all_data_sessions',"roi_names",'subjects','sessions','hemi');
% nSubjects = size(all_data_sessions, 1);
% nROI = size(all_data_sessions, 2);
% output = [];
% %=====================================
% 
% for sub = 1:nSubjects
%     for roi = 1:nROI
%         roi_name = roi_names{roi}; % Use actual ROI name
%         cell_content = all_data_sessions{sub, roi};
%         cell_sd = all_data_sessions_sd{sub, roi}; % Standard deviation data
% 
%         if isempty(cell_content)
%             for sess = 1:nSessions
%                 hemi_code = double(strcmp(hemi, 'lh'));
%                 row = [{sub}, {sess}, {hemi_code}, {roi_name}, num2cell(nan(1, nTimePoints)), num2cell(nan(1, nTimePoints))];
%                 output = [output; row];
%             end
%         else
%             for sess = 1:nSessions
%                 time_series = cell_content(sess, :);
%                 sd_series = cell_sd(sess, :);
%                 hemi_code = double(strcmp(hemi, 'lh'));
%                 row = [{sub}, {sess}, {hemi_code}, {roi_name}, num2cell(time_series), num2cell(sd_series)];
%                 output = [output; row];
%             end
%         end
%     end
% end
% % Create column names
% time_labels = arrayfun(@(x) sprintf('TR_%02d', x), 1:nTimePoints, 'UniformOutput', false);
% sd_labels = arrayfun(@(x) sprintf('SD_TR_%02d', x), 1:nTimePoints, 'UniformOutput', false);
% col_names = [{'Subject', 'Session', 'Hemi', 'ROI'}, time_labels, sd_labels];
% 
% % Convert to table
% output_table = cell2table(output, 'VariableNames', col_names);
% save([outpath 'output_table_' hemi '.mat'], 'output_table');


%%Below includes both hemispheres
%%% This script is used to put the ERAs from each ROI each session in a data
%%% table to use in other programs (e.g. JMP)

inpath = '/Volumes/Elements/HiHi/';
infile_data = 'eras_rois_sessions_';
outpath = inpath;

hemispheres = {'lh', 'rh'}; % Loop over both hemispheres
nTimePoints = 19;
output = [];


for h = 1:length(hemispheres)
    hemi = hemispheres{h};

    % Load data for current hemisphere
    load([inpath infile_data hemi '.mat'], 'all_data_sessions', 'roi_names', 'subjects', 'sessions');

    nSubjects = size(all_data_sessions, 1);
    nROI = size(all_data_sessions, 2);

    for sub = 1:nSubjects
        if sub == 4
            continue; % Skip subject 4
        end

        for roi = 1:nROI
            roi_name = roi_names{roi};

            % Safely check if the cell contains a 1x4 cell array
            if ~iscell(all_data_sessions{sub, roi})
                continue;
            end

            session_cells = all_data_sessions{sub, roi};

            for sess = 1:min(length(session_cells), length(sessions))
                voxel_matrix = session_cells{sess}; % [nVox × 19]

                if isempty(voxel_matrix)
                    mean_tc = nan(1, nTimePoints);
                    sd_tc = nan(1, nTimePoints);
                else
                    mean_tc = mean(voxel_matrix, 1, 'omitnan');
                    sd_tc = std(voxel_matrix, 0, 1, 'omitnan');
                end

                hemi_code = double(strcmp(hemi, 'lh')); % 1 for 'lh', 0 for 'rh'
                row = [{sub}, {sess}, {hemi_code}, {roi_name}, num2cell(mean_tc), num2cell(sd_tc)];
                output = [output; row];
            end
        end
    end
end

% Create column names
time_labels = arrayfun(@(x) sprintf('TR_%02d', x), 1:nTimePoints, 'UniformOutput', false);
sd_labels = arrayfun(@(x) sprintf('SD_TR_%02d', x), 1:nTimePoints, 'UniformOutput', false);
col_names = [{'Subject', 'Session', 'Hemi', 'ROI'}, time_labels, sd_labels];

% Convert to table
output_table = cell2table(output, 'VariableNames', col_names);

% Save
save([outpath 'output_table_both_hemis.mat'], 'output_table');
