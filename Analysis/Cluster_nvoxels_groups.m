%% This script is used for the cluster plot.
% 1) Create the cluster heatmap from `Cluster_means_110425.txt`.
% 2) Create the stacked voxel-count bar plot from `cluster_data_280425.txt`,
%    split by cluster and participant.
%
% Last updated: 30-04-25 (LS)

clear; clc;

clustpath = '/path/to/auditory_HRF/analyses_2025/Clustering';
cluster_means_file = fullfile(clustpath, 'Cluster_means_110425.txt');
cluster_data_file = fullfile(clustpath, 'cluster_data_280425.txt');

%% 1) Create heatmap
cluster_means = readmatrix(cluster_means_file);

%%Delete clusters (rows) that didn't go into a group = 1, 2, 8, 15, 17
cluster_means([1, 2, 8, 15, 17], :) = [];
heatmap(cluster_means(:,3:end)); colormap(jet);

%% 2) Stacked barplot
data = readmatrix(cluster_data_file); % space-delimited, no headers

% Extract relevant columns
subject_ids = data(:, 4);       % Subject ID
cluster_ids = data(:, 24);      % Cluster ID

% Define clusters to exclude
excluded_clusters = [1, 2, 8, 15, 17];

% Filter out excluded clusters
valid_rows = ~ismember(cluster_ids, excluded_clusters);
subject_ids = subject_ids(valid_rows);
cluster_ids = cluster_ids(valid_rows);

% Get unique clusters and subjects
clusters = unique(cluster_ids);
subjects = unique(subject_ids);

% Initialize voxel count matrix
voxel_counts = zeros(length(clusters), length(subjects));

% Count voxels per subject per cluster
for c = 1:length(clusters)
    for s = 1:length(subjects)
        voxel_counts(c, s) = sum(cluster_ids == clusters(c) & subject_ids == subjects(s));
    end
end

% Total voxels per cluster
total_voxels = sum(voxel_counts, 2);

% Convert to percentages
voxel_percentages = voxel_counts ./ total_voxels * 100;

% Scale percentages back to voxel counts for stacking
scaled_voxels = voxel_percentages .* total_voxels / 100;

% Plot stacked bar chart
figure;
bar(scaled_voxels, 'stacked');

% Apply parula colormap
colormap(parula(length(subjects)));

% Labels and formatting
xlabel('Cluster');
ylabel('Number of Voxels');
title('Number of Voxels per Cluster with Subject Composition');
legend(arrayfun(@(x) ['Subject ' num2str(x)], subjects, 'UniformOutput', false), 'Location', 'eastoutside');
xticks(1:length(clusters));
xticklabels(arrayfun(@num2str, clusters, 'UniformOutput', false));

%%Colors can be changed manually in editor if necessary
