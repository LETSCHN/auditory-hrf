%% Inspect cluster groups used for the cluster Figure.
%
% This script takes the JMP cluster means file, applies the April 2025
% cluster grouping, and plots group-average and within-group cluster
% timecourses. The group definitions must match assign_cluster_groups.R.
%
% Last updated: April 25, 2025 (LS)

clear; clc; close all;
set(gcf, 'Color', 'w');
%%BELOW IS FOR GETTING THE MEAN OF EACH GROUP
% Read the file, skipping the first header line
inpath = '/path/to/auditory_HRF/analyses_2025/Clustering';
all = readmatrix([inpath '/Cluster_means_110425.txt']); %use this if you want first row removed: 'NumHeaderLines', 1);

%%Grouping for Clusters from April 2025 - (updated clusters with changed
%%baseline ERAs and fixed stimulus timings)

colors = {
    [128, 0, 128]/255; % Purple
    [0, 0, 139]/255; % Dark intense blue
    [0, 206, 209]/255; % Strong turquoise
    [50, 205, 50]/255; % Strong lime green
    [220, 220, 0]/255; % Strong yellow
    [255, 165, 0]/255; % Strong orange
    [139, 0, 0]/255 % Dark red
    };
%%this needs to match with what is defined in assign_cluster_groups.R
%%Feb26: Watch out, the colors in the Figure were switched around so group1
%%= blue, group2 = green etc.
grp{1} = [18, 19, 20, 21, 22];
grp{2} = [9, 10, 11, 12];
grp{3} = [3, 5, 6];
grp{4} = [4, 13, 14, 16];
grp{5} = [7, 23, 24, 27, 28, 32];
grp{6} = [25, 26, 29, 31, 34];
grp{7} = [30, 33, 35, 36, 37, 38, 39, 40];

%%Plot mean
figure(1003); clf;
set(gcf, 'Color', 'w');
for i = 1:length(grp)
    % Calculate the mean of the rows for the current group
    mean_values = mean(all(grp{i}, 3:end), 1);
    sem_values = std(all(grp{i}, 3:end), 0, 1) / sqrt(length(grp{i}));

    % Plot the mean values
    subplot(2,5,i); 
    errorbar(mean_values, sem_values, 'LineWidth', 4, 'Color', colors{i});    
    grid on;
    x = gca; 
    x.YLim = [-0.5 0.8]; 
    x.XTick = [1, 6, 11, 16, 21];
    x.XTickLabel = {'0', '5', '10', '15', '20'};
    grid on;

    % Add axis labels only to the first subplot
    if i == 1
        xlabel('Time (s)', 'FontSize', 16);
        ylabel('Mean Value', 'FontSize', 16);
    end

    % Add large axis labels
    set(gca, 'FontSize', 28); % Tick label size

    % Set the legend and title
    %legend(['Mean of Group ' num2str(i)]); 
    title(['Group ' num2str(i)]);
end


%%Plot each cluster within group
figure(1004); clf;
for i = 1:length(grp)
    subplot(2,5,i); 
    
    cluster_ids = grp{i};                 % e.g. [1, 18, 19, 20]
    data = all(cluster_ids, 3:end);      % get the rows corresponding to these clusters
    
    h = plot(data', 'LineWidth', 2);     % plot each cluster (rows) across time (columns)
    
    % Set plot limits and ticks
    x = gca; 
    x.YLim = [-0.5 0.8]; 
    x.XTick = 1:2:19;
    x.XTickLabel = 0:2:18;
    grid on;
    
    % Generate legend labels from cluster IDs
    legendLabels = arrayfun(@(x) ['Cluster ' num2str(x)], cluster_ids, 'UniformOutput', false);
    
    % Add legend
    legend(h, legendLabels);
    
    % Add title
    title(['Group ' num2str(i)]);
end
