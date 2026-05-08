%%%This script is used to take all ROI parameters from original/replication
%%%dataset and store them in a spreadsheet.
%%%Input files are fittedAmpPeakFWHM_ROIs_cutoff1500_allsess.mat files
%%%created by the ROI-average HRF model fitting scripts.
%%%
%%%Last changed May 2026 (LS)

clc; clear;
output_path = '/path/to/auditory_HRF/analyses_2025/ROI_peak_fwhm_amp';

all_data = {};
dataset_paths = {
    '/path/to/external_drive/auditory_HRF/analyses_2025/updated_model6', 'Dataset1';
    '/path/to/external_drive/replication_dataset/updated_model6', 'Dataset2'
};

hemispheres = {'lh', 'rh'};
col_indices = [4, 5, 6];  % peak, fwhm, amp

for d = 1:size(dataset_paths, 1)
    dataset_path = dataset_paths{d, 1};
    dataset_label = dataset_paths{d, 2};

    files = dir(fullfile(dataset_path, '*_fittedAmpPeakFWHM_ROIs_cutoff1500_allsess.mat'));

    for f = 1:length(files)
        file = files(f).name;
        filepath = fullfile(dataset_path, file);
        data = load(filepath);

        % Extract subject and hemisphere from filename
        tokens = regexp(file, '(s\d+)_([lr]h)', 'tokens');
        if isempty(tokens), continue; end
        subj = tokens{1}{1};
        hemi = tokens{1}{2};

        if isfield(data, 'roi_names')
            roi_names = data.roi_names;
        else
            roi_names = arrayfun(@(x) sprintf('ROI %d', x), 1:100, 'UniformOutput', false);
        end
        if ~isfield(data, 'final_peak_fwhm')
            fprintf('Missing final_peak_fwhm in %s, skipping.\n', file);
            continue;
        end

        n_rois = length(data.final_peak_fwhm);
        for roi = 1:n_rois
            roi_name = roi_names{roi};
            values = data.final_peak_fwhm{roi}(1, col_indices);
            values(values == 0) = NaN;  % Replace 0 with NaN

            all_data(end+1, :) = {subj, dataset_label, hemi, roi_name, values(1), values(2), values(3)};
        end
    end
end

% Save and export
save(fullfile(output_path, 'ROI_combined_data.mat'), 'all_data');
T = cell2table(all_data, 'VariableNames', {'Participant', 'Dataset', 'Hemisphere', 'ROI', 'Peak', 'FWHM', 'Amp'});
writetable(T, fullfile(output_path, 'ROI_combined_data.xlsx'));
