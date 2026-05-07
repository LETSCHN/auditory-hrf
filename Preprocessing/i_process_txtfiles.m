% Converts the big txt file into smaller mat files (easier and quicker to
% load) for later processing. the txt file is afni pre-processed (hopefully
% brain masked)

% We assume text file is i,j,k followed by timecourse for each voxel
% remove any headers from txt file before running the script

% Input: Big afni .txt file
% Output: smaller chunks of that .txt file saved as .mat files

% IZ (2025)

clear
clc
close all
addpath('/Users/letitia/Dropbox/auditory_HRF/Experiment1/Sep_2023/session_comparison_March');

% =================
inpath = '/Users/letitia/Dropbox/auditory_HRF/Experiment1/Sep_2023/session_comparison_March/';
infile = '_meanspace_brain_smooth.txt'; % s0X_timecourse_ses0Y_infile

outpath = inpath; % change here for output location
% outfile will be outpath/s0X_timecourse_sessY_partZ.mat

nSessions = 1:4;
nTimePoints = 1452; % length of whole timecourse
subjects = 1:7; % can put miltiple indices 1:n
% =================

for sub = subjects
    disp(['Subject: ' num2str(sub)]);

    for sess = nSessions
        disp(['  Session: ' num2str(sess)]);

        tic
        % loading voxel indices + timecourse from afni
        % can use textread, but its much slower (at least on my mac)
        ff = fopen([inpath '/s0' num2str(sub) '/s0' num2str(sub) '_timecourse_ses' num2str(sess) infile]);

        % formating input data into 3 integers for i, j ,k, and nTimePoints
        % float
        formatSpec = ['%d %d %d' repmat(' %f',1,nTimePoints)];
        A = fscanf(ff,formatSpec); % ===== Check here to see if the data got sorted, each row should start with i,j,k values

        % divide the data into chunks
        count = 1; test = []; part = 1;
        for xx = 0:nTimePoints+3:length(A)-(nTimePoints+3)
            test(count,:) = A(xx+1:xx+(nTimePoints+3));

            if count == 50000 % create new mat file after 50000 voxels
                disp('   ...');
                save([outpath '/s0' num2str(sub) '/ses' num2str(sess) '/s0' num2str(sub) '_timecourse_ses' num2str(sess) '_part' num2str(part)], 'test');
                count = 1; part = part+1;
                test = [];
            else
                count = count+1;
            end
        end
        save([outpath '/s0' num2str(sub) '/ses' num2str(sess) '/s0' num2str(sub) '_timecourse_ses' num2str(sess) '_part' num2str(part) ,'.mat'], 'test');

        toc
        clear A;
    end
end

disp('Done!')