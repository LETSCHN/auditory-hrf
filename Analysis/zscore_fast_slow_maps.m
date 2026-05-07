%%This script gets input from the "ROI_combined_data" spreadsheet created
%%in "create datatable ROIs params" script and averages parameters of
%%interest across hemispheres, creates z scores for all ROIs per
%%participant and dataset and saves them for usage in "z score fast slow
%%colourscale" script

%%LS November 25 (updated March 26 to include amplitude and perform analysis on all participants across datasets)
clear;clc;close all
% Load the data
data = readtable('/Users/letitia/Dropbox/auditory_HRF/analyses_2025/ROI_peak_fwhm_amp/ROI_combined_data.xlsx');

% Convert Peak to numeric
data.Peak = str2double(string(data.Peak));
data.Amp = str2double(string(data.Amp));

%% STEP 1: Average across hemispheres for same Participant + Dataset + ROI
% Group by Participant, Dataset, ROI (ignore Hemisphere)
[G, subj, dataset, roi] = findgroups(data.Participant, data.Dataset, data.ROI);

% Compute mean Peak and Amp per group (=hemisphere), ignoring NaNs
avgPeak = splitapply(@(x) mean(x,'omitnan'), data.Peak, G);
avgAmp = splitapply(@(x) mean(x,'omitnan'), data.Amp, G);

% Build new table with averaged values
avgData = table(subj, dataset, roi, avgPeak, avgAmp, ...
    'VariableNames', {'Participant','Dataset','ROI','Peak','Amp'});

%% STEP 2: Compute z-scores per Participant+Dataset
metrics = {'Peak','Amp'};

% Get zscore for a given participant and dataset
groups = unique(avgData(:, {'Participant','Dataset'}), 'rows');

for m = 1:numel(metrics)
    metric = metrics{m};
    zcol = ['Z_' metric];
    avgData.(zcol) = nan(height(avgData),1); %filling zscore rows with NaNs

    for i = 1:height(groups)
        p = groups.Participant{i};
        d = groups.Dataset{i};
        
        idx = strcmp(avgData.Participant, p) & strcmp(avgData.Dataset, d); %get all ROIs for p and d
        vals = avgData.(metric)(idx);
        
        mu = mean(vals,'omitnan');
        sigma = std(vals,'omitnan');
        
        avgData.(zcol)(idx) = (vals - mu) / sigma;
    end
end

%%%Average across participants
% Assume avgData contains Participant, Dataset, ROI, Z_Peak, Z_Amp

% Group by ROI and Dataset
[G, roi, dataset] = findgroups(avgData.ROI, avgData.Dataset);

% Build group-level table
groupData = table(roi, dataset, 'VariableNames', {'ROI','Dataset'});

for m = 1:numel(metrics)
    zcol = ['Z_' metrics{m}];
    meanZ = splitapply(@(x) mean(x,'omitnan'), avgData.(zcol), G);
    groupData.(['Mean' zcol]) = meanZ;
end

% Display first few rows
disp(groupData(1:10,:));

% Save result
% writetable(groupData, 'group_mean_zscores_March26.csv');
%% STEP 3: Save results
% writetable(avgData, 'zscore_peaks_amps_avgHem_March26.csv');

% Display first few rows
disp(avgData(1:10,:));

%% STEP 4: Save per-dataset z-score files for colour mapping
roi_names = {'A1','AL','CL', 'CM', 'CP', 'C_A4', 'ML', 'MM', 'MPc', 'MPr', ...
    'M_A4', 'R', 'RM', 'RP', 'RT', 'RTL', 'R_A4', 'TA2', 'TA3'};

datasetNames = {'Dataset1','Dataset2'};
outputNames = {'dataset1_zscores.mat','dataset2_zscores.mat'};
scriptDir = fileparts(mfilename('fullpath'));

for d = 1:numel(datasetNames)
    dataset_name = datasetNames{d};
    datasetRows = string(groupData.Dataset) == dataset_name;
    datasetData = groupData(datasetRows, :);

    [roiFound, roiOrder] = ismember(string(roi_names), string(datasetData.ROI));
    if any(~roiFound)
        error('Missing ROI(s) for %s: %s', dataset_name, strjoin(roi_names(~roiFound), ', '));
    end

    zscore_table = datasetData(roiOrder, {'ROI','MeanZ_Peak','MeanZ_Amp'});
    peak_zscores = zscore_table.MeanZ_Peak;
    amp_zscores = zscore_table.MeanZ_Amp;

    save(fullfile(scriptDir, outputNames{d}), ...
        'dataset_name', 'roi_names', 'peak_zscores', 'amp_zscores', 'zscore_table');
end
