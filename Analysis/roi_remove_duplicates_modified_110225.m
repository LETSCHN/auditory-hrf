%%This script is used to remove duplicate voxels between ROIs
%%Go to /Users/letitia/Documents/Isma_auditoryHRF_scripts/Marty_ROIs_090125
clear
clc

inpath = pwd;
rois = {'rh_RTL', 'rh_TA2'};

% this extension is added to filename at the end at the output
updated_file_ext = '_new';

for subj = 1:5
    disp(['Processing subject: s', num2str(subj)]);

    % ===== read in rois
    for r = 1:length(rois)
        original_file = ['s', num2str(subj), '_', rois{r}, '.txt'];
        new_file = ['s', num2str(subj), '_', rois{r}, updated_file_ext, '.txt'];
        
        if exist(new_file, 'file')
            temp = textread(new_file);
        else
            temp = textread(original_file);
        end
        
        if r == 1
            roi1 = temp(:,1:3);
        else
            roi2 = temp(:,1:3);
        end
    end

    % ===== look for duplicates
    next = 1; common_vox_ind = [];
    for i = 1:size(roi1,1)
        for j = 1:size(roi2,1)
            if roi1(i,1) == roi2(j,1) && roi1(i,2) == roi2(j,2) && roi1(i,3) == roi2(j,3)
                common_vox(next,:) = roi1(i,:); %actual coordinate taken from roi1
                common_vox_ind(next,:) = [i j]; %column 1 is index in roi1 column 2 is index in roi2
                next = next+1;
            end
        end
    end

    % ===== find which roi is bigger and remove from that
    if ~isempty(common_vox_ind)
        if size(roi1,1) > size(roi2,1) %1 here means I want the size of the first dimension
            final_roi1 = roi1(setxor(1:size(roi1,1),common_vox_ind(:,1)),:); %returns unique voxels of roi1
            final_roi2 = roi2;
        else
            final_roi1 = roi1;
            final_roi2 = roi2(setxor(1:size(roi2,1),common_vox_ind(:,2)),:);
        end

        % ==== write updated files only if they were modified
        if exist('final_roi1', 'var') && ~isequal(roi1, final_roi1)
            outfile1 = ['s', num2str(subj), '_', rois{1}, updated_file_ext, '.txt'];
            fileID = fopen(outfile1,'w');
            fprintf(fileID,'%d %d %d\n',final_roi1');
            fclose(fileID);
        end

        if exist('final_roi2', 'var') && ~isequal(roi2, final_roi2)
            outfile2 = ['s', num2str(subj), '_', rois{2}, updated_file_ext, '.txt'];
            fileID = fopen(outfile2,'w');
            fprintf(fileID,'%d %d %d\n',final_roi2');
            fclose(fileID);
        end
    else
        disp('No common voxels.');
    end
end