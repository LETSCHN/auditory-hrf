% This script computes ERAs across subjects for voxels with all corrections
% including correlation correction, ERA and SD cutoffs

% default at CORR correction at 85th percentile... change accordingly

% Preferably run for all sessions together
% Input: Timecourse file (+ voxel indices XYZ)
%        Onsets file (stimulus onsets, should correspond to timecourse
%        file)
%        Voxel list after ERA SD and Correlation cutoffs
% Output: 
%       1) ERA for stable voxels in session 1, SESSION 1 stable voxels responses 
%       in session 2
%       2) Also computes cross-session correlations or responses (1 vs 2, 1 vs 3 ...)
%       Both pearson and spearman

% Additional output: mat file for clustering by combining data across particpants
% in following format:
%           i, j, k, ERA (subjects concatenated in rows, only session 1, can be modified)

% IZ (2025)

clear; clc; close all
addpath('/Volumes/backup_ucl/Letitia/pre-processing scripts/');

% ==================
inpath = '/Volumes/backup_ucl/Letitia/Data_Isma/all_data/all_voxels_smoothed';
infile = '_cutoff1500_common_sessions.mat'; % s0X_sessY_outfile
onset_file = '/Volumes/backup_ucl/Letitia/Data_Isma/concat_Runs1-6StimTimesHRF.1D'; % concatenated for all runs to match voxel time course data
voxel_file = '/vox_cutoff1500_commonSessions_cleanERA_SD_CORR.mat';

outpath = inpath;
outfile = 'smoothed_data_cutoff1500_ERA_SD_CORR85.mat'; 
clustering_outfile = 'smoothed_for_clustering_sess1_ERA_SD_CORR85.mat'; % combined all subjects

nSessions = 1:2;
subjects = 1:5; % s0X 1:n

% parameters for timing of event-related averaging
pre_stimulus_duration = 0; % 0 is onset
post_stimulus_duration = 18;
%=================

% file with ERA SD + CORR cutoff voxel list
load([inpath voxel_file], 'vox_corr_th_85','vox_corr_th_85_XYZ');

average_eras_norm = [];

disp('Computing event related averages...')
for sub = subjects
    disp(['Subject: ' num2str(sub)]);

    for sess = nSessions

        %time course from common sessions file
        load([inpath '/s0' num2str(sub) '_ses' num2str(sess) infile]);

        voxel_time_course = voxel_time_course(vox_corr_th_85{sub,1},:);

        % Load stimulus onset times from a text file or similar
        stimulus_onsets_file = onset_file;
        stimulus_onsets = load(stimulus_onsets_file);

        temp_ind = pre_stimulus_duration:post_stimulus_duration;

        event_time_courses_norm = [];

        for i = 1:length(stimulus_onsets)
            % Extract time points around each stimulus onset
            window_indices = stimulus_onsets(i)+temp_ind;

            % Extract data for the current event and accumulate it
            temp = voxel_time_course(:,window_indices);

            ii = [find(temp_ind==0)-1 find(temp_ind==0) find(temp_ind==0)+1];
            baseline = mean(voxel_time_course(:,stimulus_onsets(i)+ii),2);

            event_time_courses_norm(i,:,:) = ((temp - baseline)./baseline)*100;

            if any([event_time_courses_norm(:)==Inf;find(event_time_courses_norm(:)==-Inf)])
                event_time_courses_norm(event_time_courses_norm==Inf) = nan;
                event_time_courses_norm(event_time_courses_norm==-Inf) = nan;
            end

        end

        all_reps_eras_norm{sub,sess} = event_time_courses_norm;
        average_eras_norm{sub,sess} = squeeze(nanmean(event_time_courses_norm));

        figure(1002); subplot(2,3,sub);
        errorbar(1:post_stimulus_duration+1,nanmean(average_eras_norm{sub,sess}),nanstd(average_eras_norm{sub,sess})./sqrt(size(average_eras_norm{sub,sess},1)), 'LineWidth',2); hold on;
        x = gca; x.YLim = [-0.15 0.5];  ylabel('signal change (%)'); xlabel('TR');
        hold on; grid on; title(['Subject: ' num2str(sub)]);
        x = gca; x.FontSize = 14;

        lgnd{sess} = ['Session: ' num2str(sess)];

    end
end
legend(lgnd);

% computing cross session correlations for each subject
% session 1 against 1, 1 against 2, 1 against 3 ... 

disp('Computing cross session correlations...')
for sub = subjects

    for sess = nSessions(2:end)
        for vox = 1:size(average_eras_norm{sub,1},1)
            r_pearson{sub,sess}(vox) = corr(average_eras_norm{sub,1}(vox,:)', average_eras_norm{sub,sess}(vox,:)','type','Pearson');
            r_spearman{sub,sess}(vox) = corr(average_eras_norm{sub,1}(vox,:)', average_eras_norm{sub,sess}(vox,:)','type','Spearman');
        end

        figure(sub); subplot(1,nSessions(end),sess-1)
        histogram(r_spearman{sub,sess},100)
        if sub == subjects(end), legend('Spearman'); end
        x = gca; x.XLim = [-1 1];  x.YLim = [0 1000]; xlabel('corr');
        title(['Mean corr: ' mean(r_spearman{sub,sess}), 'sess1vs' num2str(sess)]);

        figure(sub+100); subplot(1,nSessions(end),sess-1)
        histogram(r_pearson{sub,sess},100)
        if sub == subjects(end), legend('Pearson'); end
        x = gca; x.XLim = [-1.1 1.1];  x.YLim = [0 1000]; xlabel('corr');
        title(['Mean corr: ' mean(r_pearson{sub,sess}), 'sess1vs' num2str(sess)]);
    end
end

save([outpath '/' outfile], 'average_eras_norm',"r_spearman","r_pearson",'vox_corr_th_85_XYZ','all_reps_eras_norm','-v7.3');

% ===========================================

%% Following file created for clustering in JMP

disp('Making clustering file for JMP...')

% cluster only one session
for_clustering = zeros(1,1);
next = 0;

for sub = subjects

    for_clustering(next+1:next+length(average_eras_norm{sub,1}),1:3) = vox_corr_th_85_XYZ{sub,1};
    for_clustering(next+1:next+length(average_eras_norm{sub,1}),4) = repmat(sub,length(average_eras_norm{sub,1}),1);

    for_clustering(next+1:next+length(average_eras_norm{sub,1}),5:23) = average_eras_norm{sub,1};

    next = next + length(average_eras_norm{sub,1});

end

save([outpath clustering_outfile],'for_clustering')

disp("Done!");
