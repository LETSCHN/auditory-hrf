% This script is used to assess the relationship between proxies of
% myelination and HRF temporal characteristics
%
% This is only done for participants from dset1 that are also in dset2 (n=4)
%
% Important: When values are loaded from different files, be mindful of
% different labeling of subjects
% LS (2025)

clear
clc
close all

% ==============
fmridir = '/Users/letitia/Dropbox/auditory_HRF/analyses_2025/ROI_peak_fwhm_amp/';
% Setup
mpmdir = '/Users/letitia/Dropbox/auditory_HRF/analyses_2025/MPM/Tables-251025';
hemisphere = {'lh', 'rh'};
param = {'R1'};
subject = {'LS', 'RR', 'MG', 'FD','IM'};
target_rois = {'CL', 'CM', 'CP', 'C_A4', 'M_A4', 'MPr', 'MPc', ...
               'AL', 'ML', 'MM', 'A1', 'R_A4', 'RT', 'RTL', 'R', 'RM', ...
               'RP', 'TA2', 'TA3'};

% Subject mapping (different here because dset1!!)
subject_map = containers.Map( ...
    {'LS', 'RR', 'MG', 'FD','IM'}, ...
    {'s01', 's02', 's03', 's04','s05'} ...
);

% Initialize storage
results = [];

% Loop through all combinations
for s = subject
    for p = param
        for h = hemisphere
            filename = fullfile(mpmdir, [s{1} '-' p{1} '-' h{1} '.table.txt']);
            if ~exist(filename, 'file')
                fprintf('File not found: %s\n', filename);
                continue;
            end

            % Read and filter lines
            fid = fopen(filename, 'r');
            raw_lines = {};
            while ~feof(fid)
                line = strtrim(fgetl(fid));
                if ischar(line) && ~startsWith(line, '#') && ~isempty(line)
                    raw_lines{end+1} = line; %#ok<AGROW>
                end
            end
            fclose(fid);

            % Parse lines directly
            for line = raw_lines
                tokens = strsplit(line{1});
                if numel(tokens) >= 5
                    roi = tokens{1};
                    if any(strcmp(roi, target_rois))
                        thick = str2double(tokens{5});
                        results = [results; {s{1}, p{1}, h{1}, roi, thick}]; %#ok<AGROW>
                    end
                end
            end
        end
    end
end
% Convert to table
ThickAvgTable = cell2table(results, 'VariableNames', {'Subject', 'Param', 'Hemisphere', 'ROI', 'ThickAvg'});

% Add recoded participant column
ThickAvgTable.Participant = cellfun(@(x) subject_map(x), ThickAvgTable.Subject, 'UniformOutput', false);

% Reshape to wide format
ThickAvgWide = unstack(ThickAvgTable, 'ThickAvg', 'Param');

% Read ROI params table
peak_file = [fmridir '/ROI_combined_data.xlsx'];
peak_data = readtable(peak_file);

% Filter to keep only rows where Dataset is 'Dataset1' 
peak_data_HRF = peak_data(strcmp(peak_data.Dataset, 'Dataset1'), :);

%%Merge tables
merged_table = innerjoin(ThickAvgWide, peak_data_HRF, ...
    'Keys', {'Participant', 'Hemisphere', 'ROI'});

writetable(merged_table,fullfile(fmridir,'dset1_ROI_params_MPM_combined_data.csv'));
