% This script takes the output of trial-effects training to find stable
% voxels. These are characterized by tracking final r-sq, which does not
% vary substantially (pcnt% of final value) as runs are added.
%
% Input:
% - smoothed_data_cutoff1500_ERA_SD_CORR85.mat, containing voxel coordinates
%   vox_corr_th_85_XYZ.
% - training_s0X_trialeffect.mat files from fit_trial_effect_models_all_sessions.m,
%   containing rsq.
% Output:
% - stability_allsubs_20pcnt.mat, containing output_stability.
% - stability_textfiles_20pcnt.mat, containing output_stability_run and
%   output_stability_rsq.
% - Subject-specific s0X_run.txt and s0X_rsq.txt files for surface projection.
%
% Last changed May 2026 (LS)

clear
clc
close all

% inpath = ['/path/to/external_drive/auditory_HRF/analyses_2025'];
inpath = ['/path/to/auditory_HRF/analyses_2025/trial_effects'];

load([inpath '/smoothed_data_cutoff1500_ERA_SD_CORR85.mat'],'vox_corr_th_85_XYZ', 'all_reps_eras_norm');

sess = 1; %TRAIN

pcnt = 20; % percent of final rsq is achieved = stable

outfile = ['stability_allsubs_' num2str(pcnt) 'pcnt.mat'];

for s = 1:5

    rsq = [];

    all_combs = load([pwd '/training_s0' num2str(s) '_trialeffect'],'rsq');

    itrs = 1:7; % we dont need combination of two sessions for this (that is 7th index) 
    % we use the model fit for data combined from session 1 as best model
    % estimate

    for model = 1:6
        rsq(model,itrs,:) = all_combs.rsq(model,itrs,:);
    end

    bm = []; rsquare = []; stability = [];

    % for all combinations of data get the best model and rsq for bm
    for itr = itrs
        [rsquare(itr,:),bm(itr,:)] = max(squeeze(rsq(:,itr,:)));

    end

    % ==== get winning model from all 6 runs, track stability of that model
    for vox = 1:size(rsquare,2)
        stability(vox,:) = rsq(bm(6,vox),:,vox);
    end

    % track when the asymptote in fit is achieved

    stable_rep = [];
    for vox = 1:size(stability,1)
        stability(vox,:);
        bm_fit = stability(vox,6);
        th = (pcnt/100) * bm_fit; % pcnt of final fit

        % find where the fit was with th range
        a = find(stability(vox,1:5)<= bm_fit + th);
        b = find(stability(vox,1:5)>= bm_fit - th);

        index = intersect(a,b);

        temp = zeros(1,6); temp(index) = 1; temp(6) = 1;

        if length(find(temp==0)>0)
            stable_rep(vox) = max(find(temp==0))+1;
        elseif sum(temp)==6
            stable_rep(vox) = 1;
        end
        disp(['Vox ' num2str(vox) ' stable at: ' num2str(stable_rep(vox))]);
        %pause
    end

    output_stability{s} = [vox_corr_th_85_XYZ{s,1}, bm(6,:)', stability(:,6), stable_rep']; % add voxel XYZ, average last column for each voxel and see which run you get
    % rsq value, what run(s) rsq hits 10% of that value and stays

end

save(outfile,'output_stability')

%%%LS added this to get mat files with i,j,k and run and i,j,k and rsq per
%%%subject

% Preallocate cell arrays to store results
output_stability_run = cell(1, 5);
output_stability_rsq = cell(1, 5);

for subj = 1:5
    % Extract the relevant columns
    temp_data = output_stability{1, subj};
    temp_run = temp_data(:, [1:3, end]);
    temp_rsq = temp_data(:, [1:3, 5]);

    % Find rows with NaNs in either temp_run or temp_rsq
    nan_rows = any(isnan(temp_run), 2) | any(isnan(temp_rsq), 2);

    % Remove those rows from both
    temp_run_clean = temp_run(~nan_rows, :);
    temp_rsq_clean = temp_rsq(~nan_rows, :);

    % Store the cleaned data
    output_stability_run{subj} = temp_run_clean;
    output_stability_rsq{subj} = temp_rsq_clean;

    writematrix(temp_run_clean, ['s0' num2str(subj) '_run.txt'], 'Delimiter', 'tab');
    writematrix(temp_rsq_clean, ['s0' num2str(subj) '_rsq.txt'], 'Delimiter', 'tab');
end

save(['stability_textfiles_' num2str(pcnt) 'pcnt.mat'], 'output_stability_run', 'output_stability_rsq');
