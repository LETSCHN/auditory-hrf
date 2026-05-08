% This script plots the results for model fitting performed for trial
% effects (i.e., fit for data average obtained from run 1, 1& 2, 1 2 & 2...
% 1 to 12 runs and so on...
%
% Model fit is characterized by average of r-sq (adjusted) for best model
% across all voxels
%
% Additionally also plots, simulated model fit (average r-sq for 1000
% simulated voxels)
% Run for all subject together
%
% Input:
% - training_s0X_sess2_trialeffect.mat files from fit_trial_effect_models_single_session.m,
%   containing rsq_overall and train.
% - fitted_simulted_data_trialeffect.mat from fit_trial_effect_models_simulated_data.m,
%   containing rsq_overall.
% Output:
% - Trial-effect trajectory figure comparing observed subject curves with
%   simulated data.
% - Printed summary values for the largest run-to-run increase, run 1 to 6
%   change, and run 6 to 12 change.
%
% IZ (2025)

clear
clc
close all

% ==============
inpath = [pwd];
infile = '_sess2_trialeffect.mat'; % training_s0X_outfile Model fits per subject
infile_sim = 'fitted_simulted_data_trialeffect.mat'; % simulated data model fitting output

subjects = 1:5;
% =============

out = [];
figure(1); hold on;

for s = subjects
    all_runs = load([inpath '/training_s0' num2str(s) infile],'rsq_overall','train');
    rsquare = all_runs.rsq_overall;
    train = all_runs.train;

    % ==== winning model rsq
    mean_rsq = nanmean(rsquare, 2);
    sem_rsq = nanstd(rsquare, 0, 2) / sqrt(size(rsquare, 2));  % Standard Error of the Mean

    errorbar(mean_rsq, sem_rsq, '-x', 'LineWidth', 5); hold on;

    % Store model labels
    for i = 1:length(train)
        runs{i} = train{i}(end);
    end
end

% ==== plot simulation results
load(infile_sim)

mean_sim = nanmean(rsq_overall, 2);
sem_sim = nanstd(rsq_overall, 0, 2) / sqrt(size(rsq_overall, 2));

if contains(infile, 'sess2')
    mean_sim = mean_sim(1:6);  % Keep only first 6 runs
    sem_sim = sem_sim(1:6);
end

errorbar(mean_sim, sem_sim, '-ok', 'LineWidth', 5); hold on;

% Axis settings
ax = gca;
if contains(infile, 'sess2')
    ax.XTick = 1:6;
    ax.XLim = [0 7];
    runs = runs(1:6);
else
    ax.XTick = 1:7;
    ax.XLim = [0 length(train)+1];
end

ax.YLim = [0.2 0.9];
ax.XTickLabel = runs;
ax.FontSize = 18;

xlabel('Average over runs', 'FontSize', 18, 'FontWeight', 'bold');
ylabel('R-sq (adjusted)', 'FontSize', 18, 'FontWeight', 'bold');
grid off;

% Legend
for s = subjects
    lgnd{s} = ['s0' num2str(s)];
end
lgnd{s+1} = 'Simulated Data';

legend(lgnd, 'FontSize', 18, 'Location', 'best');

%% Script to calculate numbers
% Initialize matrix to store mean R-sq per run per subject
rsq_subjects = [];

for s = subjects
    all_runs = load([inpath '/training_s0' num2str(s) infile],'rsq_overall','train');
    rsquare = all_runs.rsq_overall;

    mean_rsq = nanmean(rsquare, 2);  % mean across voxels per run
    rsq_subjects = [rsq_subjects; mean_rsq'];  % store as row: [1 x runs]
end

% === Analysis ===
mean_across_subjects = mean(rsq_subjects, 1);  % average R-sq per run across subjects
diffs = diff(mean_across_subjects);  % differences between consecutive runs

% 1) Biggest increase happens when?
[max_increase, run_idx] = max(diffs); %run_idx stores the idx of where biggest increase occurs
fprintf('1) Biggest increase happens between run %d and %d: %.4f\n', run_idx, run_idx+1, max_increase);

% 2) Change between run 1 and run 6
change_1_6 = mean_across_subjects(6) - mean_across_subjects(1);
fprintf('2) Change between run 1 and 6: %.4f\n', change_1_6);

% 3) Change between run 6 and run 12
change_6_12 = mean_across_subjects(7) - mean_across_subjects(6);
fprintf('3) Change between run 6 and 12: %.4f\n', change_6_12);
