%%This series of scripts is used for the Cluster Figure. 1) Create the heatmap Cluster Fig. (20/01/25 - updated 30/04/25)
%%First copy the Cluster means here from the file
%%'Cluster_means_110425'  
%%2) Create transparency bar that shows correlation strength
%%between ERA ses1 and ses2
%%3) Create bar plot that a) scales to voxel number per
%%cluster b) is stacked to reflect number of voxels per participant per cluster

clear; clc;

%% 1) Create heatmap
cluster_means = []; %%now copy into here 'Cluster_means_110425'

%%Delete clusters (rows) that didn't go into a group = 1, 2, 8, 15, 17
cluster_means([1, 2, 8, 15, 17], :) = [];
heatmap(cluster_means(:,3:end)); colormap(jet);

%% 2) Transparency bar
% Selected correlation values
selected_corr = [0, 0.3, 0.5, 0.7, 1];

% Transparency mapping
MIN_ALPHA = 0.3;
MAX_ALPHA = 1.0;
alpha_values = MIN_ALPHA + abs(selected_corr) * (MAX_ALPHA - MIN_ALPHA);

% Purple color
purple = [128, 0, 128] / 255;

% Create figure
figure;
hold on;
axis equal;
axis off;
title('Transparency Mapping: Correlation → Alpha');

% Semi-circle parameters
r = 1;  % radius
theta = linspace(0, pi, 50);  % semi-circle angles
x = r * cos(theta);
y = r * sin(theta);

% Plot each semi-circle with corresponding alpha and label
for i = 1:length(alpha_values)
    x_offset = i * 2;  % spacing between shapes
    h = fill(x + x_offset, y, purple, 'EdgeColor', 'none');
    set(h, 'FaceAlpha', alpha_values(i));
    
    % Add correlation value label below each shape
    text(x_offset, -0.5, sprintf('%.1f', selected_corr(i)), ...
         'HorizontalAlignment', 'center', 'FontSize', 10);
end

%% 3) Stacked barplot
data = readmatrix('/Users/letitia/Dropbox/auditory_HRF/analyses_2025/Clustering/cluster_data_280425.txt'); % space-delimited, no headers

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

%%Now in plot editor, change colors manually to suit your needs