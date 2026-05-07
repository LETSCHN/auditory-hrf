% This script computes model fits (6) for average of the ROI (no
% correlation cutoff to increase power for small ROIs).
% Training models are initialized based on the pre-identified cluster
% shapes.
%
% One fit per roi, average over all voxels in roi + all repetitions in
% given session
%
% ROIs with fits below rsq-thresh are removed from analysis.
%
% Infile: Per subject ERAs without ERA and SD correction (otherwise voxel
% numbers are too small for ROIs that are already small)
% Outfile: .mat file with concatenated xyz indices, amplitude, peak1 and fwhm1 for
% all rois in roi_names
% (change script to get info on other peaks)
%        Saves following: concatenated_data_amp, roi_names, final_roi_XYZ

% keep order of rois the same if comparing across datasets

clear
clc
close all

% ================
inpath = ['/Volumes/Elements/auditory_HRF/analyses_2025/'];
infile = '_cutoff1500_common_sessions.mat'; % s0X_infile, per subject all data no corr correction

outpath = [inpath 'updated_model6/'];
hemi = {'rh'};% {'rh'}
outfile = 'fittedAmpPeakFWHM_ROIs_cutoff1500_allsess.mat';

roidir = ['/Users/letitia/Dropbox/auditory_HRF/analyses_2025/ROIs'];
roi_names = { 'CL', 'CM', 'CP','C_A4', 'M_A4', 'MPr', 'MPc', 'AL', 'ML', 'MM', 'A1', 'R_A4', 'RT', 'RTL', 'R', 'RM','RP', 'TA2', 'TA3'};
stimulus_onsets_file = [inpath 'concat_Runs1-6StimTimesHRF.1D']; %change this if you want change dataset
nROI = length(roi_names);

subject = 3;
sess = 1:2;
session_list = 1:2;
nvox = 5; % plot if atleast this many voxels

rsq_thresh = 0.2; % if r-sq value of ROI is below this, we remove it from analysis
vox_thresh = 5;
% ==================

load([inpath '/s0' num2str(subject) '/ses1'  '/s0' num2str(subject) '_ses1' infile],'voxels_XYZ', 'voxel_time_course');

all_voxels = voxels_XYZ;

%% process ROIs :  to match roi indices to data files

for roi = 1:nROI
    original_file = [roidir '/s', num2str(subject), '_', hemi{1}, '_', roi_names{roi}, '.txt'];
    new_file = [roidir '/s', num2str(subject), '_', hemi{1}, '_', roi_names{roi}, '_new.txt'];

    if exist(new_file, 'file')
        getall = textread(new_file);
    else
        getall = textread(original_file);
    end

    roi_inds{roi} = getall(:,1:3);

    out = [];

    for i = 1:size(all_voxels) %no of columns
        for j = 1:size(roi_inds{roi})

            if all_voxels(i,3) == roi_inds{roi}(j,3) %check if coordinates match for voxels and rois
                if all_voxels(i,2) == roi_inds{roi}(j,2)
                    if all_voxels(i,1) == roi_inds{roi}(j,1)
                        out(j) = i;
                    end
                end
            end
        end
    end

    final_roi{roi} = out(out>0);
    final_roi_XYZ{roi} = all_voxels(final_roi{roi},:);

    disp(roi_names{roi});
    disp(length(roi_inds{roi})) %how many voxels originally
    disp(length(final_roi{roi})) %how many were there in final ROI

end


xx = 0:18;

%% set equations for models

% single gamma; mid peak
model1 = fittype('A*((((x/peak1)^((8*log10(2))*(peak1^2/fwhm1^2)))*exp(-((x-peak1)/((fwhm1^2)/((8*log10(2))*peak1))))))',...
    'dependent',{'y'},'independent',{'x'},...
    'coefficients',{'A','fwhm1','peak1'});

% two gamma
model2 = fittype('A * ((((x/peak1)^((8*log10(2)) * (peak1^2/fwhm1^2))) * exp(-((x-peak1)/((fwhm1^2) / ((8*log10(2)) * peak1))))) + (ratio * (((x/peak2)^((8*log10(2)) * (peak2^2/fwhm2^2))) * exp(-((x-peak2)/((fwhm2^2) / ((8*log10(2)) * peak2)))))))',...
    'dependent',{'y'},'independent',{'x'},...
    'coefficients',{'A','fwhm1','fwhm2','peak1','peak2','ratio'});

% three gamma
model3 = fittype('A*((((x/peak1)^((8*log10(2))*(peak1^2/fwhm1^2)))*exp(-((x-peak1)/((fwhm1^2)/((8*log10(2))*peak1)))))+(ratio1*(((x/peak2)^((8*log10(2))*(peak2^2/fwhm2^2)))*exp(-((x-peak2)/((fwhm2^2)/((8*log10(2))*peak2))))))+(ratio2*(((x/peak3)^((8*log10(2))*(peak3^2/fwhm3^2)))*exp(-((x-peak3)/((fwhm3^2)/((8*log10(2))*peak3)))))))',...
    'dependent',{'y'},'independent',{'x'},...
    'coefficients',{'A','fwhm1','fwhm2','fwhm3','peak1','peak2','peak3','ratio1','ratio2'});


%% initialize: model initializtion (upper and lower limits + start)

% ======  M1 Single peak, both +ve & -ve
% A       fw1     peak1
start_model1 = [0.4,     6,      6];
lower_model1 = [ -3,     2,      2];
upper_model1 = [  3,    16,     18];

%  M2: Two peaks all combinations
             %  A      fw1     fw2     p1      p2      r1
start_model2 = [ 1,     4,      6,      4,      12,     0.1];
lower_model2 = [-3,     2,      3,      2,       9,     -3];
upper_model2 = [ 3,     8,     12,      8,      18,       3];


% ======  M3: Three peaks + - +
               %  A   fw1  fw2 fw3  p1  p2   p3    r1      r2
start_model3 = [0.4,   4,  3,  3,  6,  11,  15,  -0.1,    0.1];
lower_model3 = [  0,   3,  1,  2,  2,  7,   14,    -3,      0];
upper_model3 = [  3,   6,  5,  4,  6,  13,  18,     0,      3];

% ======  M4: Three peaks + - + (shifted later)
               %  A   fw1  fw2 fw3  p1  p2   p3    r1      r2
start_model4 = [0.4,   4,  3,  3,  6,  11,  16,  -0.1,    0.1];
lower_model4 = [  0,   3,  1,  2,  3,  10,  15,    -3,      0];
upper_model4 = [  3,   6,  5,  4,  9,  14,  18,     0,      3];

% ======  M5: Three peaks - + +(-)
               %  A   fw1  fw2 fw3   p1  p2   p3    r1      r2
start_model5 = [-0.1, 2.5,  4,  6,    4,  9,  16,  -0.1,      0.1];
lower_model5 = [  -3,   2,  1,  2,    3,  6,  12,    -3,       -3];
upper_model5 = [   0,   4,  6, 10,    5, 10,  18,     0,        3];

% ======  M6: Initial dip - + -(+)
                %  A   fw1  fw2 fw3  p1    p2   p3    r1      r2
start_model6 = [-0.01,   1,  2,  4, 1.5,    6,    9,  -10,    10];
lower_model6 = [ -0.5,   1,  2,  3,   1,  3.5,    8,  -80,   -40];
upper_model6 = [    0,   2,  4,  7,   3,    7,   18,    0,    40];


data_allSess_allROIs = cell(nROI, 1);
final_peak_fwhm = cell(nROI, 1);
all_reps_eras_norm = cell(nROI, max(session_list));

for s = subject
    for roi = 1:nROI
        nvox = length(final_roi{roi});
        if nvox > vox_thresh - 1
            stimulus_onsets = load(stimulus_onsets_file);
            pre_stimulus_duration = 0;
            post_stimulus_duration = 18;
            temp_ind = pre_stimulus_duration:post_stimulus_duration;

            for sess = session_list
                %                 disp(['Session: ' num2str(sess)]);
                load([inpath 's0' num2str(s) '/ses' num2str(sess) '/s0' num2str(s) '_ses' num2str(sess) infile], 'voxel_time_course');
                voxel_time_course_roi = voxel_time_course(final_roi{roi}, :);

                for i = 1:length(stimulus_onsets)
                    window_indices = stimulus_onsets(i) + temp_ind;
                    if max(window_indices) > size(voxel_time_course_roi, 2)
                        continue;
                    end

                    temp = voxel_time_course_roi(:, window_indices);
                    ii = [find(temp_ind == 0)-1, find(temp_ind == 0), find(temp_ind == 0)+1];
                    baseline = mean(voxel_time_course_roi(:, stimulus_onsets(i) + ii), 2);
                    normed = ((temp - baseline) ./ baseline) * 100;
                    normed(normed == Inf | normed == -Inf) = nan;

                    all_reps_eras_norm{roi, sess}(i, :, :) = normed;
                end
            end
            % === ERA averaged across all sessions ===
            combined_data = [];
            for sess = session_list
                if ~isempty(all_reps_eras_norm{roi, sess})
                    temp = squeeze(mean(all_reps_eras_norm{roi, sess}, 2));
                    combined_data = cat(3, combined_data, temp);
                end
            end

            if ~isempty(combined_data)
                data_allSess = mean(mean(combined_data, 1), 3);
            else
                data_allSess = nan(1, length(xx));
            end


            % Store both versions
            data_allSess_allROIs{roi} = data_allSess;

            % === Fit models to all-session data ===
            [f1_allsess, gof1_allsess] = fit(xx', data_allSess', model1, 'StartPoint', start_model1, 'Lower', lower_model1, 'Upper', upper_model1);
            [f2_allsess, gof2_allsess] = fit(xx', data_allSess', model2, 'StartPoint', start_model2, 'Lower', lower_model2, 'Upper', upper_model2);
            [f3_allsess, gof3_allsess] = fit(xx', data_allSess', model3, 'StartPoint', start_model3, 'Lower', lower_model3, 'Upper', upper_model3);
            [f4_allsess, gof4_allsess] = fit(xx', data_allSess', model3, 'StartPoint', start_model4, 'Lower', lower_model4, 'Upper', upper_model4);
            [f5_allsess, gof5_allsess] = fit(xx', data_allSess', model3, 'StartPoint', start_model5, 'Lower', lower_model5, 'Upper', upper_model5);
            [f6_allsess, gof6_allsess] = fit(xx', data_allSess', model3, 'StartPoint', start_model6, 'Lower', lower_model6, 'Upper', upper_model6);

            % === R² values for all sessions ===
            rsq_allsess = nan(1,6);
            if ~checkatBoundM1(f1_allsess,upper_model1,lower_model1), rsq_allsess(1) = gof1_allsess.adjrsquare; end
            if ~checkatBoundM2(f2_allsess,upper_model2,lower_model2), rsq_allsess(2) = gof2_allsess.adjrsquare; end
            if ~checkatBoundM3_8(f3_allsess,upper_model3,lower_model3), rsq_allsess(3) = gof3_allsess.adjrsquare; end
            if ~checkatBoundM3_8(f4_allsess,upper_model4,lower_model4), rsq_allsess(4) = gof4_allsess.adjrsquare; end
            if ~checkatBoundM3_8(f5_allsess,upper_model5,lower_model5), rsq_allsess(5) = gof5_allsess.adjrsquare; end
            if ~checkatBoundM6(f6_allsess,upper_model6,lower_model6), rsq_allsess(6) = gof6_allsess.adjrsquare; end

            [rsq_overall,bm_overall] = max(rsq_allsess(:));
            disp(['roi: ' roi_names{roi} ', bm: ' num2str(bm_overall) ', rsq-adj: ' num2str(rsq_overall)]);

            eval(['f' num2str(bm_overall) '_allsess']);

            subplot(4,2,1);
            plot(xx, data_allSess, 'ko:');
            title('All sessions ERA'); grid on; 

            for m = 1:6
                subplot(4,2,m+2);
                plot(eval(['f' num2str(m) '_allsess']), xx, data_allSess);
                title(['m' num2str(m) ': ' num2str(rsq_allsess(m))]); grid on; legend('off');
            end
%             pause

            % === Extract peak/fwhm/amp from best model ===
            if rsq_overall > rsq_thresh
                if bm_overall < 5
                    temp_peak = eval(['f' num2str(bm_overall) '_allsess.peak1']);
                    temp_fwhm = eval(['f' num2str(bm_overall) '_allsess.fwhm1']);
                    temp_amp = eval(['f' num2str(bm_overall) '_allsess.A']);
                else
                    temp_peak = eval(['f' num2str(bm_overall) '_allsess.peak2']);
                    temp_fwhm = eval(['f' num2str(bm_overall) '_allsess.fwhm2']);
                    temp_amp = eval(['f' num2str(bm_overall) '_allsess.A']) * eval(['f' num2str(bm_overall) '_allsess.ratio1']);
                end
            else
                temp_peak = 0; 
                temp_fwhm = 0;
                temp_amp = 0;
            end

            % === Store peak/fwhm/amp for ses1 ERA ===
            final_peak_fwhm{roi}(:,1:3) = roi_inds{roi};
            final_peak_fwhm{roi}(:,4) = repmat(temp_peak, size(roi_inds{roi},1), 1);
            final_peak_fwhm{roi}(:,5) = repmat(temp_fwhm, size(roi_inds{roi},1), 1);
            final_peak_fwhm{roi}(:,6) = repmat(temp_amp, size(roi_inds{roi},1), 1);

        else
            final_peak_fwhm{roi}(:,1:6) = zeros(size(roi_inds{roi},1),6);
            final_peak_fwhm{roi}(:,1:3) = roi_inds{roi};
        end
    end
end
% === Concatenate results across ROIs ===
concatenated_data_peak = [];
concatenated_data_fwhm = [];
concatenated_data_amp = [];

for i = 1:nROI
    concatenated_data_peak = [concatenated_data_peak; final_peak_fwhm{i}(:, [1:3 4])];
    concatenated_data_fwhm = [concatenated_data_fwhm; final_peak_fwhm{i}(:, [1:3 5])];
    concatenated_data_amp  = [concatenated_data_amp;  final_peak_fwhm{i}(:, [1:3 6])];
end

% save([outpath '/s0' num2str(subject)  '_' hemi{1} '_' outfile], 'final_peak_fwhm', 'concatenated_data_peak','concatenated_data_fwhm','concatenated_data_amp', 'roi_names', 'final_roi_XYZ');