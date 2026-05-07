clc;clear;
all_data = {};  % Cell array to hold mixed typesinpath = '/Users/letitia/Dropbox/auditory_HRF/analyses_2025/ROI_peak_fwhm_amp';
% Define explicit subject ID pairs between datasets
subject_pairs = {
    's01', 's07';
    's02', 's05';
    's03', 's03';
    's04', 's02'
    's05', 's01'
    's06', 's06'
    };

hemispheres = {'lh', 'rh'};
dataset1_path = '/Users/letitia/Dropbox/auditory_HRF/analyses_2025/ROI_peak_fwhm_amp'; %'/Users/letitia/Dropbox/auditory_HRF/analyses_2025/ROI_peak_fwhm_amp';
dataset2_path = '/Users/letitia/Dropbox/HiHi/ROI_peak_fwhm_amp';

% Define ROI RGB mapping (uppercase keys)
roi_rgb_map = containers.Map( ...
    upper({'CL','CM','CP','CA4','CA5','MA4','MA5','MPr','MPc','AL','ML','MM','A1','RA4','RA5','RT','RTL','R','RM','RP','TA2','TA3'}), ...
    {[254,87,24],[254,114,26],[204,75,71],[143,68,119],[63,31,183],[85,87,164],[94,52,158],[79,134,170],[136,105,125], ...
    [152,132,111],[226,102,54],[232,149,47],[211,130,65],[50,118,195],[34,82,205],[139,177,122],[65,188,180], ...
    [174,152,93],[189,187,82],[79,157,171],[115,202,140],[54,249,189]});

% Define column indices and corresponding labels
col_indices = [4, 5, 6];
col_labels = {'peak', 'fwhm', 'amp'};

for p = 1:size(subject_pairs, 1)
    subj1 = subject_pairs{p, 1};
    subj2 = subject_pairs{p, 2};

    for h = 1:length(hemispheres)
        hemi = hemispheres{h};
        subj1_hemi = [subj1 '_' hemi];
        subj2_hemi = [subj2 '_' hemi];

        file1 = fullfile(dataset1_path, [subj1_hemi '_fittedAmpPeakFWHM_ROIs_cutoff1500_allsess.mat']);
        file2 = fullfile(dataset2_path, [subj2_hemi '_fittedAmpPeakFWHM_ROIs_cutoff1500_allsess.mat']);

        if ~isfile(file1) || ~isfile(file2)
            fprintf('Missing files for %s or %s, skipping.\n', subj1_hemi, subj2_hemi);
            continue;
        end

        data1 = load(file1);
        data2 = load(file2);

        if isfield(data1, 'roi_names')
            roi_names = data1.roi_names;
        else
            roi_names = arrayfun(@(x) sprintf('ROI %d', x), 1:100, 'UniformOutput', false);
        end

        for v = 1:length(col_indices)
            col_idx = col_indices(v);
            var_label = col_labels{v};

            if ~isfield(data1, 'final_peak_fwhm') || ~isfield(data2, 'final_peak_fwhm')
                fprintf('final_peak_fwhm not found in %s or %s, skipping.\n', subj1_hemi, subj2_hemi);
                continue;
            end

            n_rois = length(data1.final_peak_fwhm);
            unique1 = nan(n_rois, 1);
            unique2 = nan(n_rois, 1);

            for roi = 1:n_rois
                roi_name = roi_names{roi};
                roi_clean = upper(regexprep(roi_name, '^(lh_|rh_)', ''));
                roi_clean = strrep(roi_clean, '_', '');

                val1 = data1.final_peak_fwhm{roi}(1, col_idx);
                val2 = data2.final_peak_fwhm{roi}(1, col_idx);

                if val1 == 0, val1 = NaN; end
                if val2 == 0, val2 = NaN; end

                % Append both dataset values as separate rows
                all_data(end+1, :) = {subj1, 'Dataset1', hemi, roi_name, val1, col_labels{v}};
                all_data(end+1, :) = {subj2, 'Dataset2', hemi, roi_name, val2, col_labels{v}};
            end

            labels = roi_names(1:n_rois);

            %             keyboard; % Pause for inspection

            % Assign colors based on cleaned ROI names
            colors = zeros(n_rois, 3);
            for i = 1:n_rois
                roi = labels{i};
                roi_clean = upper(regexprep(roi, '^(lh_|rh_)', ''));
                roi_clean = strrep(roi_clean, '_', '');

                if isKey(roi_rgb_map, roi_clean)
                    colors(i, :) = roi_rgb_map(roi_clean) / 255;
                else
                    colors(i, :) = [0.5, 0.5, 0.5];
                    fprintf('ROI "%s" (cleaned: "%s") not found in color map. Using grey.\n', roi, roi_clean);
                end
            end

            %             Optional: plotting
            %             figure;
            %             scatter(unique1, unique2, 100, colors, 'filled');
            %             xlabel([' auditory HRF '], 'Interpreter', 'none');
            %             ylabel([' HiHi '], 'Interpreter', 'none');
            %             title([subj1_hemi, ' ' var_label], 'Interpreter', 'none');
            %             grid on;
        end
    end
end
save([inpath '/ROI_comparison_data.mat', 'all_data']);
load([inpath '/ROI_comparison_data.mat']);
T = cell2table(all_data, 'VariableNames', {'Participant', 'Dataset', 'Hemisphere', 'ROI', 'Value', 'Measure'});
writetable(T, fullfile(inpath, 'ROI_comparison.xlsx'));