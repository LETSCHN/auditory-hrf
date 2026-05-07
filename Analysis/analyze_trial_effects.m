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
% IZ (2025)

clear
clc
close all

% ==============
inpath = [pwd];
infile = '_sess2_trialeffect.mat'; % training_s0X_outfile Model fits per subject
infile_sim = 'fitted_simulted_data_trialeffect.mat'; % simulated data model fitting output

subjects = [1:5];
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

errorbar(mean_sim, sem_sim, '-ok', 'LineWidth', 5); hold on;

% Axis settings
ax = gca;
ax.XTick = 1:7;
ax.XLim = [0 length(train)+1];
ax.YLim = [0.2 0.9];
ax.XTickLabel = runs;
ax.FontSize = 18;  % Tick label font size

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


%%%Old script which gives me stable voxels used for Figure3, needs to be
%%%amended

% out = [];
% for s = [1,2,3,4,5]
% 
%     rsq = [];
% 
%     runs1to6 = load([inpath '/training_s0' num2str(s) '_trialeffect'],'rsq');
%     runs1to12 = load([inpath 'training_s0' num2str(s) '_averageBOTHsess' '_trialeffect'],'rsq'); %Single voxel, average over data from either run1 only or run1 and 2, run 1,2,3 ...run 1,2,3,4,5...12. Fit model per voxel, this gives us best model per voxel - Rsq
% 
%     for model = 1:6
%         rsq(model,1:6,:) = runs1to6.rsq_overall(model,:,:);
%         %         rsq(model,7,:)   = runs1to12.rsq(model,:,:);
%     end
% 
%     bm = []; rsquare = [];
% 
%     for runs = 1:size(rsq,2)
%         [rsquare(runs,:),bm(runs,:)] = max(squeeze(rsq(:,runs,:)));
% 
%         %temp(temp<0.1) = nan;
%         %out(s,runs) = nanmean(rsquare(:));
%         %histogram(rsq(:,runs,:)); hold on;
%         %plot(runs,nanmean(temp(:)),'x','LineWidth',3); hold on;
%     end
% 
%     % ==== winning model rsqs
% 
%     figure(1); errorbar(nanmean(rsquare,2),nanstd(rsquare,[],2)./sqrt(length(bm)),'-x','LineWidth',2); hold on;
%     plot(nanmean(rsquare,2),'-x','LineWidth',2); hold on;
%     legend('s01','s02','s03','s04','s05')
%     x = gca; x.XTick = 1:7; x.XLim= [0 8]; x.XTickLabel = {'first run only','Avg 2 runs','Avg 3 runs','Avg 4 runs', 'Avg 5 runs','Avg 6 runs', 'Avg 12 runs'}
%     ylabel('Rsq'); x.FontSize = 14; grid on;
% 
%     % figure(2);
%     % slope = gradient(out(s,:))./gradient(1:7);
%     % plot(slope,'LineWidth',2); hold on
% 
%     % ===
% 
%     stable_vox = [];
%     for vox = 1%:length(rsq_overall)
% 
%         lm = bm_overall(end,vox);
% 
%         if ~isnan(lm)
%             temp = bm(1:end-1,vox);
% 
%             % finding if the model was consistently same
%             if temp(end) == lm && temp(end-1) == lm %&& temp (3) == lm % last 3 models are same
%                 stable_vox(end+1) = vox;
%             end
%         end
%     end
% 
%     stable_vox_subs{s}(:,1:3) = vox_corr_th_85_XYZ{s,1}(stable_vox,:);
%     stable_vox_subs{s}(:,4)   = bm(6,stable_vox);
% 
% 
% end


%  save('voxels_stablemodelfit_runs1to6.mat','stable_vox_subs')