%% This script loads z-scores saved by compute_fast_slow_roi_zscores.m and
%% maps ROI names to colours. The loaded z-scores are reordered to match
%% roi_names before plotting.
%% Dataset1 is the original dataset; Dataset2 is the replication dataset.
%%
%% Input:
%% - dataset1_zscores.mat and dataset2_zscores.mat from
%%   compute_fast_slow_roi_zscores.m.
%% Output:
%% - Figure showing ROI colour assignments for both datasets with a shared
%%   colour scale.
%%
%% Last changed May 2026 (LS)

clear all; clc;
% ROI names
roi_names = {'A1','AL','CL', 'CM', 'CP', 'C_A4', 'ML', 'MM', 'MPc', 'MPr', 'M_A4', 'R', 'RM', 'RP', 'RT', 'RTL', 'R_A4', 'TA2', 'TA3'};

% Choose which z-score to plot: 'Peak' or 'Amp'
zscore_metric = 'Peak';

scriptDir = fileparts(mfilename('fullpath'));
dataset1 = load(fullfile(scriptDir, 'dataset1_zscores.mat'));
dataset2 = load(fullfile(scriptDir, 'dataset2_zscores.mat'));

[roiFound1, roiOrder1] = ismember(string(roi_names), string(dataset1.roi_names));
[roiFound2, roiOrder2] = ismember(string(roi_names), string(dataset2.roi_names));
if any(~roiFound1)
    error('Missing ROI(s) in dataset1_zscores.mat: %s', strjoin(roi_names(~roiFound1), ', '));
end
if any(~roiFound2)
    error('Missing ROI(s) in dataset2_zscores.mat: %s', strjoin(roi_names(~roiFound2), ', '));
end

switch lower(zscore_metric)
    case 'peak'
        z1 = dataset1.peak_zscores(roiOrder1);
        z2 = dataset2.peak_zscores(roiOrder2);
    case 'amp'
        z1 = dataset1.amp_zscores(roiOrder1);
        z2 = dataset2.amp_zscores(roiOrder2);
    otherwise
        error('zscore_metric must be ''Peak'' or ''Amp''.');
end

% Symmetric range for both datasets
max_abs = round(max(abs([z1(:); z2(:)])), 1);% 2.3 for peak based on combined data, 2.1 for all data peak, 1.0 for all data amp
min_val = -max_abs;
max_val = max_abs;

% Blue-white-red colormap
n = 256;
halfN = n / 2;
blue = [0.230, 0.299, 0.754];
white = [1, 1, 1];
red = [0.706, 0.016, 0.150];
cmap = [
    interp1([1 halfN], [blue; white], 1:halfN)
    interp1([1 halfN], [white; red], 1:halfN)
];

% Normalize and map colors for Dataset 1
norm_z1 = (z1 - min_val) / (max_val - min_val);
norm_z1(norm_z1 < 0) = 0; norm_z1(norm_z1 > 1) = 1; %values below 0 are 0 and values above 1 are 1
colors1 = cmap(round(norm_z1 * 255) + 1, :); %colors will have three columns corresponding to R G B

% Normalize and map colors for Dataset 2
norm_z2 = (z2 - min_val) / (max_val - min_val);
norm_z2(norm_z2 < 0) = 0; norm_z2(norm_z2 > 1) = 1;
colors2 = cmap(round(norm_z2 * 255) + 1, :);

% Plot both datasets side by side
figure('Position',[100 100 800 600]);

subplot(1,2,1);
for i = 1:length(roi_names)
    text(0.1, 1 - i*0.05, roi_names{i}, 'Color', colors1(i,:), 'FontSize', 14, 'FontWeight','bold');
end
axis off;
title(sprintf('Dataset 1 %s Colors', zscore_metric));

subplot(1,2,2);
for i = 1:length(roi_names)
    text(0.1, 1 - i*0.05, roi_names{i}, 'Color', colors2(i,:), 'FontSize', 14, 'FontWeight','bold');
end
axis off;
title(sprintf('Dataset 2 %s Colors', zscore_metric));

% Add colorbar for reference
colormap(cmap);
clim([min_val max_val]);
ticks = [min_val 0 max_val];
cb = colorbar('Position',[0.92 0.1 0.02 0.8], 'Ticks', ticks);
cb.TickLabels = compose('%.1f', ticks); % or '%.2f' for more precision
cb.Label.String = 'Z-score';
cb.Label.FontSize = 12;
