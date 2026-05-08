% get common voxels with activation across sessions
% uses the 1500 cutoff files and makes sure they are present in ALL
% sessions

% preferrably run with ALL sessions

% Input: Timecourse with 1500 cutoff, across sessions, voxel XYZ indices
% Output: timecourses for common voxels between sessions, + common voxel indices

% IZ (2025)

clear
clc

addpath('/Volumes/Elements/HiHi');

% ==============
inpath = '/Volumes/Elements/HiHi';
infile = '_cutoff1500.mat'; % s0X_sessY_outfile

outpath = inpath;
outfile = '_cutoff1500_common_sessions.mat';

nSessions = 1:4;
subjects = 1:7; % s0X, 1:5

% ==============

for sub = subjects

    disp(['Subject: ' num2str(sub)]);
    tic
    new_vox_Arr = [];
    for sess = nSessions
        temp = load([inpath '/s0' num2str(sub) '/ses' num2str(sess) '/s0' num2str(sub) '_ses' num2str(sess) infile],'voxels_XYZ','voxel_time_course');
        voxel_curr{sess} = temp.voxels_XYZ;
        data{sess} = temp.voxel_time_course;
        clear temp;

        % making voxels easy to search by saving indices as XXYYZZ
        for i = 1:size(voxel_curr{1,sess},1)
            a = num2str(voxel_curr{1,sess}(i,1));

            if voxel_curr{1,sess}(2) < 10, b = ['0' num2str(voxel_curr{1,sess}(i,2))];
            else b = num2str(voxel_curr{1,sess}(i,2)); end

            if voxel_curr{1,sess}(i,3) < 10, c = ['0' num2str(voxel_curr{1,sess}(i,3))];
            else c = num2str(voxel_curr{1,sess}(i,3)); end

            new_vox_Arr(sess,i) = str2num([a,b,c]);
        end

    end

    if nSessions(end) > 1 % align if more than 1 sessions
        new_vox_Arr(new_vox_Arr==0) = nan;

        % aligning
        inds_final = []; vox_count = 1;

        for sess = 1
            for i = 1:size(voxel_curr{sess},1)
                curr = new_vox_Arr(sess,i);
                if ~isnan(curr)
                    count = 1;
                    for rr = nSessions(2:end)
                        if find(new_vox_Arr(rr,:) == curr)
                            count = count+1;
                        end
                    end
                    % if in all sess
                    if count == nSessions(end)
                        for rr = nSessions
                            inds_final(vox_count,rr) = find(new_vox_Arr(rr,:) == curr);
                        end
                        vox_count = vox_count+1;
                    end
                end
            end
        end

        % finally, saving data for common voxels

        for sess = nSessions
            voxel_time_course = [];
            voxel_time_course = data{sess}(inds_final(:,sess),:);

            voxels_XYZ = voxel_curr{sess}(inds_final(:,sess),:);

            save([outpath '/s0' num2str(sub) '/ses' num2str(sess) '/s0' num2str(sub) '_ses' num2str(sess) outfile],"voxels_XYZ",'voxel_time_course');
        end

    else % in case of only one session data
        sess = 1;
        voxel_time_course = data{sess};
        voxels_XYZ = voxel_curr{sess};

        save([outpath '/s0' num2str(sub) '/ses' num2str(sess) '/s0' num2str(sub) '_ses' num2str(sess) outfile],"voxels_XYZ",'voxel_time_course');
    end

    disp(['Number of voxels common between sessions: ' num2str(length(voxels_XYZ))]);
    toc
end

disp('Done!')
