% This script  removes any low or 0 value voxels. We set a cutoff threshold 
% at 1500. Usually the voxels at the edges (not many after brain mask, but
% some with motion correction).

% Input: .mat file parts of big .txt file from afi pre-processing 
% Output: all data per session combined, voxels with values<1500 discarded

% IZ (2025)

clear
clc
close all
addpath('/path/to/processed_timecourses');

% ==========
inpath = '/path/to/processed_timecourses';
% input file: inpath/s0X_timecourse_sessY_partZ.mat

outpath = inpath; % output directory
outfile = '_cutoff1500.mat'; % s0X_sessY_outfile

nSessions = 1:2;
subjects = 1:5; % 1:n
nParts = 2; % check how many part .mat files were created in pre-proc step i
% =========

for sub = subjects
    disp(['Subject: ' num2str(sub)]);

    for sess = nSessions
        tic
        disp(['Session: ' num2str(sess)]);

        % loading in data
        test = [];
        for part = 1:nParts

            ff = load([inpath '/s0' num2str(sub) '/ses' num2str(sess) '/s0' num2str(sub)  '_timecourse_ses' num2str(sess) '_part' num2str(part) '.mat']);
            test = [test; ff.test];
            clear ff;
        end
        toc

        epi_data = test(:,4:end); % timecourse
        vox_inds = test(:,1:3); % i,j,k values

        clear test;

        remove = [];

        [remove,~] = find(epi_data<1500);
        remove = unique(remove); % ====== these voxels will be removed 

        disp(['Voxels removed: ' num2str(length(remove))]);

        % store the data for remaining voxels
        voxels = setxor(1:size(epi_data,1),remove);
        voxels_XYZ = vox_inds(voxels,1:3); % i,j,k
        voxel_time_course = squeeze(epi_data(voxels, :)); % timecourse

        save([outpath '/s0' num2str(sub) '/ses' num2str(sess) '/s0' num2str(sub) '_ses' num2str(sess) outfile],'voxels_XYZ','voxel_time_course','voxels');

    end
end

disp('Done!')