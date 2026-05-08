%% Prepare cluster-group and ERA-correlation text files for Cluster Figure.
%
% This script uses the output from assign_cluster_groups.R
% (`cluster_data_280425.txt`) plus `vox_corr_th_85_XYZ` and `r_pearson`
% from `smoothed_data_cutoff1500_ERA_SD_CORR85.mat`.
%
% It creates per-subject text files containing:
% 1) i,j,k coordinates plus Pearson correlation between ERA session 1 and session 2
% 2) i,j,k coordinates plus cluster group label
%
% Last updated: 28-04-25 (LS)

clear; clc; clf;
%%%%%%%%%%%%%%%%%%
corrpath = '/path/to/external_drive/auditory_HRF/analyses_2025';
load('smoothed_data_cutoff1500_ERA_SD_CORR85.mat');
clustpath = '/path/to/auditory_HRF/analyses_2025/Clustering/';
cluster_groups = readmatrix([clustpath, '/cluster_data_280425.txt']); %Get cluster file from R with group assignment per cluster
subject = unique(cluster_groups(:, 4));
%%%%%%%%%%%%%%%%%

%%Get correlations
s1_corr = vox_corr_th_85_XYZ{1,1};
s1_corr(:,4) = r_pearson{1,2}';
s2_corr = vox_corr_th_85_XYZ{1,2};
s2_corr = vox_corr_th_85_XYZ{2,1};
s2_corr(:,4) = r_pearson{2,2}';
s3_corr = vox_corr_th_85_XYZ{3,1};
s3_corr(:,4) = r_pearson{3,2}';
s4_corr = vox_corr_th_85_XYZ{4,1};
s4_corr(:,4) = r_pearson{4,2}';
s5_corr = vox_corr_th_85_XYZ{5,1};
s5_corr(:,4) = r_pearson{5,2}';


%%Get cluster groups
for i = 1:length(subject)
    value = subject(i);
    subset = cluster_groups(cluster_groups(:, 4) == value, :);
    varName = sprintf('subset_%d', value);
    assignin('base', varName, subset);
    filename = sprintf('groups_subject_%d.mat', value);
end

%%%%%Create two files with both i,j,k and correlations / group
s1_ERA_corr  = s1_corr;
s1_ERA_clustgroup = (subset_1(:,[1:3,end]));

s2_ERA_corr  = s2_corr;
s2_ERA_clustgroup = (subset_2(:,[1:3,end]));

s3_ERA_corr  = s3_corr;
s3_ERA_clustgroup = (subset_3(:,[1:3,end]));

s4_ERA_corr  = s4_corr;
s4_ERA_clustgroup = (subset_4(:,[1:3,end]));

s5_ERA_corr  = s5_corr;
s5_ERA_clustgroup = (subset_5(:,[1:3,end]));
  
%cd to clustpath so it will save there
writematrix(s1_ERA_corr);
writematrix(s2_ERA_corr);
writematrix(s3_ERA_corr);
writematrix(s4_ERA_corr);
writematrix(s5_ERA_corr);
writematrix(s1_ERA_clustgroup);
writematrix(s2_ERA_clustgroup);
writematrix(s3_ERA_clustgroup);
writematrix(s4_ERA_clustgroup);
writematrix(s5_ERA_clustgroup);

%%This part gets average correlation values and standard deviation

% === Configuration ===
dataDir = '/path/to/auditory_HRF/analyses_2025/Clustering' % folder containing the text files (use pwd or specify a path)
filePattern = fullfile(dataDir, 's*_ERA_corr*.txt');  % adjust if needed
sIDs = 1:5;                    % the 's' numbers you expect (1..5)
saveCSV = true;                % set false if you don't want to save the summary

% === Discover files ===
files = dir(filePattern);
if isempty(files)
    error('No files found matching pattern: %s', filePattern);
end

fprintf('Found %d files.\n', numel(files));

% Containers
perS = struct();               % per-s aggregation
allCorr = [];                  % all correlations across s

% Initialize perS fields
for s = sIDs
    perS(s).sID = s;
    perS(s).corr = [];         % store correlations for that s
    perS(s).n = 0;
end

% === Read each file and accumulate correlations ===
for k = 1:numel(files)
    fpath = fullfile(files(k).folder, files(k).name);

    % Extract sID from filename: look for 's' followed by digits
    tokens = regexp(files(k).name, 's(\d+)_', 'tokens', 'once');
    if isempty(tokens)
         warning('Skipping file (cannot parse sID): %s', files(k).name);
         continue;
    end
    sID = str2double(tokens{1});
    if ~ismember(sID, sIDs)
        % If you only want s=1..5, skip others
        warning('Skipping file with s=%d (outside expected range). File: %s', sID, files(k).name);
        continue;
    end

    % Read numeric data; assumes columns: x y z corr (4 columns)
    % Try readmatrix first; fallback to dlmread if needed
    try
        M = readmatrix(fpath);
    catch
        M = dlmread(fpath);
    end

    % Validate shape: need at least 4 columns (x y z corr)
    if size(M,2) < 4
        warning('File %s has %d columns; expected at least 4. Skipping.', files(k).name, size(M,2));
        continue;
    end

    % Extract correlation column (assumed last column)
    corrVals = M(:, end);

    % Optional: clean NaNs or infs
    corrVals = corrVals(~isnan(corrVals) & isfinite(corrVals));

    % Accumulate
    perS(sID).corr = [perS(sID).corr; corrVals]; %#ok<AGROW>
    perS(sID).n = numel(perS(sID).corr);

    % Global list
    allCorr = [allCorr; corrVals]; %#ok<AGROW>
end

% === Compute per-s stats ===
rows = [];
for s = sIDs
    if perS(s).n > 0
        meanCorr = mean(perS(s).corr);
        medianCorr = median(perS(s).corr);
        sdCorr = std(perS(s).corr);
        nObs = perS(s).n;
    else
        meanCorr = NaN; medianCorr = NaN; sdCorr = NaN; nObs = 0;
    end
    rows = [rows; s, nObs, meanCorr, medianCorr, sdCorr]; %#ok<AGROW>
end

% === Compute overall stats (across all s) ===
overall = [ ...
    sum(rows(:,2)), ...        % total N
    mean(allCorr), ...
    median(allCorr), ...
    std(allCorr) ...
];

% === Print summary ===
fprintf('\n=== Per-s correlation summary ===\n');
fprintf('sID\tN\tMean\t\tMedian\t\tSD\n');
for r = 1:size(rows,1)
    fprintf('%d\t%d\t%.6f\t%.6f\t%.6f\n', rows(r,1), rows(r,2), rows(r,3), rows(r,4), rows(r,5));
end

fprintf('\n=== Overall (all s) ===\n');
fprintf('N_total: %d\n', overall(1));
fprintf('Mean:    %.6f\n', overall(2));
fprintf('Median:  %.6f\n', overall(3));
fprintf('SD:      %.6f\n', overall(4));

% === Save CSVs ===
if saveCSV
    % Per-s table
    T = array2table(rows, 'VariableNames', {'sID','N','Mean','Median','SD'});
    outPath1 = fullfile(dataDir, 'perS_correlation_summary.csv');
    writetable(T, outPath1);
    fprintf('Saved per-s summary to: %s\n', outPath1);

    % Overall table (1 row)
    T2 = table(overall(1), overall(2), overall(3), overall(4), ...
        'VariableNames', {'N_total','Mean','Median','SD'});
    outPath2 = fullfile(dataDir, 'overall_correlation_summary.csv');
    writetable(T2, outPath2);
    fprintf('Saved overall summary to: %s\n', outPath2);
end
