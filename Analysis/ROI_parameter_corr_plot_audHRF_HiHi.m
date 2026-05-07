%%This script was originally used to plot correlation of ROI-wise HRF parameters
%%between dataset1 and dataset2 (now plotting in Python because it deals
%%better with overlapping labels in Figures)

clear all; clc; close all;

%%%Run it per participant common to both datasets
clear all; clc; close all;

% Load the Excel file
filename = '/Users/letitia/Dropbox/auditory_HRF/analyses_2025/ROI_peak_fwhm_amp/ROIs_parameters_audHRF_HiHi_Nov25.xlsx';
data = readtable(filename);

% Clean up labels
data.Dataset = lower(strtrim(string(data.Dataset)));
data.ROI = strtrim(string(data.ROI));
data.Participant = strtrim(string(data.Participant));

% Parameters to loop over
parameters = {'Peak', 'Fwhm', 'Amp'};

% Participant pairs: HiHi vs Original
pairs = {
    's07', 's01';
    's05', 's02';
    's03', 's03';
    's02', 's04'
    };

% Output path
outpath = '/Users/letitia/Dropbox/auditory_HRF/analyses_2025/dataset_comparison';

for p = 1:length(parameters)
    param = parameters{p};

    for k = 1:size(pairs, 1)
        hihi_id = pairs{k, 1};
        orig_id = pairs{k, 2};

        % Filter data for each participant and parameter
        hihiData = data(data.Participant == hihi_id & data.Dataset == "hihi" & ~isnan(data.(param)), :);
        origData = data(data.Participant == orig_id & data.Dataset == "original" & ~isnan(data.(param)), :);

        % Get common ROIs
        commonROIs = intersect(hihiData.ROI, origData.ROI);
        commonROIs = setdiff(commonROIs, ["RA5", "CA5"]); % exclude if needed

        % Initialize arrays
        origVals = zeros(numel(commonROIs), 1);
        hihiVals = zeros(numel(commonROIs), 1);

        for i = 1:numel(commonROIs)
            roi = commonROIs(i);

            % Average across hemispheres
            orig_roi_vals = origData.(param)(origData.ROI == roi);
            hihi_roi_vals = hihiData.(param)(hihiData.ROI == roi);

            origVals(i) = median(orig_roi_vals, 'omitnan');
            hihiVals(i) = median(hihi_roi_vals, 'omitnan');
        end

        % Scatter plot
        figure;
        % Define colors: default green
        colors = repmat([0 0.5 0], numel(commonROIs), 1);  % default green

        % Highlight R, A1, and RT in blue
        highlight_idx = ismember(upper(commonROIs), {'R', 'A1', 'RT'});
        colors(highlight_idx, :) = repmat([0 0 1], sum(highlight_idx), 1);  % blue

        % Scatter plot with custom colors
        scatter(origVals, hihiVals, 100, colors, 'filled');
        hold on;

        % Add ROI labels with alternating offsets
        xRange = range(origVals);
        yRange = range(hihiVals);

        for i = 1:numel(commonROIs)
            xOffset = 0.02 * xRange * (-1)^i;
            yOffset = 0.02 * yRange * (-1)^(i+1);

            text(origVals(i) + xOffset, hihiVals(i) + yOffset, commonROIs(i), ...
                'FontSize', 14, ...
                'VerticalAlignment', 'middle', ...
                'HorizontalAlignment', 'center');
        end

        % Axis labels and title
        xlabel('Dataset1', 'FontSize', 18);
        ylabel('Dataset2', 'FontSize', 18);

        % Add units to title based on parameter
        if strcmpi(param, 'Amp')
            unitStr = ' (% signal change)';
        elseif strcmpi(param, 'Peak') || strcmpi(param, 'Fwhm')
            unitStr = ' (s)';
        else
            unitStr = '';
        end

        % Increase tick font size
        ax = gca;
        ax.FontSize = 18;

        grid off;

        % Correlation line
        pfit = polyfit(origVals, hihiVals, 1);
        xfit = linspace(min(origVals), max(origVals), 100);
        yfit = polyval(pfit, xfit);
        plot(xfit, yfit, 'k--', 'LineWidth', 2);

        % Pearson correlation coefficient
        [r, pval] = corr(origVals, hihiVals, 'Type', 'Pearson');
        legend(sprintf('r = %.2f, p = %.3f', r, pval), 'Location', 'best', 'FontSize', 14);

        % Save figure
%         filename_out = fullfile(outpath, [orig_id '_' param '.png']);
%         saveas(gcf, filename_out);
%         close;
    end
end

% % Load the Excel file
% filename = '/Users/letitia/Dropbox/auditory_HRF/analyses_2025/ROI_peak_fwhm_amp/ROIs_parameters_audHRF_HiHi_Nov25.xlsx';
% data = readtable(filename);
% 
% % Clean up Dataset and ROI labels
% data.Dataset = lower(strtrim(string(data.Dataset)));
% data.ROI = strtrim(string(data.ROI));
% 
% % Parameters to loop over
% parameters = {'Peak', 'Fwhm', 'Amp'};
% 
% for p = 1:length(parameters)
%     param = parameters{p};
% 
%     % Remove rows with missing values for this parameter
%     validData = data(~isnan(data.(param)), :);
% 
%     % Get unique ROIs
%     uniqueROIs = setdiff(unique(validData.ROI), ["RA5","MA5" ,"CA5"]); %bracket in case I want to exclude some ROIs
%     % Initialize result table
%     results = table('Size', [numel(uniqueROIs), 3], ...
%         'VariableTypes', {'string', 'double', 'double'}, ...
%         'VariableNames', {'ROI', 'Original', 'HiHi'});
%     results.ROI = uniqueROIs;
% 
%     % Compute average per ROI per Dataset
%     for i = 1:numel(uniqueROIs)
%         roi = uniqueROIs(i);
% 
%         origVals = validData.(param)(validData.ROI == roi & validData.Dataset == "original");
%         hihiVals = validData.(param)(validData.ROI == roi & validData.Dataset == "hihi");
% 
%         results.Original(i) = median(origVals, 'omitnan'); %can also use mean but more noisy
%         results.HiHi(i) = median(hihiVals, 'omitnan');
%     end
% 
%     % Remove rows with missing values in either column
%     validResults = results(~isnan(results.Original) & ~isnan(results.HiHi), :);
% 
%     % Scatter plot
%     figure;
%     scatter(validResults.Original, validResults.HiHi, 60, [0 0.5 0], 'filled'); % dark green, larger dots
%     text(validResults.Original, validResults.HiHi, validResults.ROI, ...
%         'FontSize', 12, 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
%     xlabel(['Average ' param ' - Original'], 'FontSize', 14);
%     ylabel(['Average ' param ' - HiHi'], 'FontSize', 14);
%     title(['ROI-wise Average ' param ': Original vs HiHi'], 'FontSize', 16);
%     grid off;
%     hold on;
% 
%     % Correlation line
%     pfit = polyfit(validResults.Original, validResults.HiHi, 1);
%     xfit = linspace(min(validResults.Original), max(validResults.Original), 100);
%     yfit = polyval(pfit, xfit);
%     plot(xfit, yfit, 'k--', 'LineWidth', 2); % black dashed line
% 
%     % Pearson correlation coefficient
%     [r, pval] = corr(validResults.Original, validResults.HiHi, 'Type', 'Pearson');
%     legend(sprintf('r = %.2f, p = %.3f', r, pval), 'Location', 'best', 'FontSize', 12);
% end