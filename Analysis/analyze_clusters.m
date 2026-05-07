%%This script was last updated January 20, 2025. It takes input from the
%%JMP printed "cluster means file" and follows the cluster grouping
%%determined in the R script: "Cluster_groups_updated291124.R" 

clear; 

%%BELOW IS FOR GETTING THE MEAN OF EACH GROUP
% Read the file, skipping the first header line
all = readmatrix('Cluster_means_ses1_160924.txt', 'NumHeaderLines', 1);

% Define the groups (%%this is new but needs to be updated in textfile, was updated 17/10/24)
% grp{1} = [6, 10, 11, 12];
grp{1} = [1, 2, 3, 4];
grp{2} = [5, 7, 8, 9, 16];
grp{3} = [13, 14, 15, 17, 19, 20];
grp{4} = [18, 21, 22, 23, 24, 29];
grp{5} = [25, 26, 27, 28];
grp{6} = [30, 31, 32, 34, 35];
grp{7} = [33, 36, 37, 38, 39, 40];

figure(1003); clf;
for i = 1:length(grp)
    % Calculate the mean of the rows for the current group
    mean_values = mean(all(grp{i}, 3:end), 1);
    sem_values = std(all(grp{i}, 3:end), 0, 1) / sqrt(length(grp{i}));

    % Plot the mean values
    subplot(2,5,i); 
    errorbar(mean_values, sem_values, 'LineWidth', 2);    
    x = gca; 
    x.YLim = [-0.5 0.8]; 
    x.XTick = 1:2:21;
    x.XTickLabel = 0:2:20;
    grid on;

    % Set the legend and title
%     legend(['Mean of Group ' num2str(i)]); 
    title(['Group ' num2str(i)]);
end