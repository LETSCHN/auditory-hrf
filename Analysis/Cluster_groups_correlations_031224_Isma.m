%%%%%03-12-24 (updated 28-04-25)
%%%%%Using this script to prepare two files which contain per participant 
% %%% 1) i,j,k and 2) pearson correlation between ERA_ses1 ERA_ses2 3) cluster
%%%%% group
%%%%It is opening vox_corr_th_85_XYZ and r_pearson from "smoothed_data_cutoff..." 

clear; clc; clf;
%%%%%%%%%%%%%%%%%%
corrpath = '/Volumes/Elements/auditory_HRF/analyses_2025';
load('smoothed_data_cutoff1500_ERA_SD_CORR85.mat');
clustpath = '/Users/letitia/Dropbox/auditory_HRF/analyses_2025/Clustering/';
cluster_groups = readmatrix([clustpath, '/cluster_data_280425.txt']); %Get cluster file from R with group assignment per cluster
subject = unique(cluster_groups(:, 4));
%%%%%%%%%%%%%%%%%

%%Get correlations
s1_corr = vox_corr_th_85_XYZ{1,1};
s1_corr(:,4) = r_pearson{1,2}';
s2_corr = vox_corr_th_85_XYZ{1,2};
s2_corr = vox_corr_th_85_XYZ{2,1};
s2_corr(:,4) = r_pearson{2,2}';
s3_corr = vox_corr_th_85_XYZ{3,1};
s3_corr(:,4) = r_pearson{3,2}';
s4_corr = vox_corr_th_85_XYZ{4,1};
s4_corr(:,4) = r_pearson{4,2}';
s5_corr = vox_corr_th_85_XYZ{5,1};
s5_corr(:,4) = r_pearson{5,2}';


%%Get cluster groups
for i = 1:length(subject)
    value = subject(i);
    subset = cluster_groups(cluster_groups(:, 4) == value, :);
    varName = sprintf('subset_%d', value);
    assignin('base', varName, subset);
    filename = sprintf('groups_subject_%d.mat', value);
end

%%%%%Create two files with both i,j,k and correlations / group
s1_ERA_corr  = s1_corr;
s1_ERA_clustgroup = (subset_1(:,[1:3,end]));

s2_ERA_corr  = s2_corr;
s2_ERA_clustgroup = (subset_2(:,[1:3,end]));

s3_ERA_corr  = s3_corr;
s3_ERA_clustgroup = (subset_3(:,[1:3,end]));

s4_ERA_corr  = s4_corr;
s4_ERA_clustgroup = (subset_4(:,[1:3,end]));

s5_ERA_corr  = s5_corr;
s5_ERA_clustgroup = (subset_5(:,[1:3,end]));
  
%Here I recommend cd to clustpath so it will save there
writematrix(s1_ERA_corr);
writematrix(s2_ERA_corr);
writematrix(s3_ERA_corr);
writematrix(s4_ERA_corr);
writematrix(s5_ERA_corr);
writematrix(s1_ERA_clustgroup);
writematrix(s2_ERA_clustgroup);
writematrix(s3_ERA_clustgroup);
writematrix(s4_ERA_clustgroup);
writematrix(s5_ERA_clustgroup);
