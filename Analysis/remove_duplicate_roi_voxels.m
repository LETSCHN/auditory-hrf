%%This script is used to remove duplicate voxels between ROIs
%%Go to /path/to/auditory_HRF/analyses_2025/Marty_ROIs_090125
%%WARNING: does not overwrite "new" files in the case of them existing
%%already

% It will copy roi file as roi_filename_updated_file_ext and final roi will
% be stored there.
% works will multiple ROIs
%
% IZ (2025)

clear
clc

inpath = '/path/to/auditory_HRF/analyses_2025/Marty_ROIs_090125';
all_rois = {'rh_CL', 'rh_CM', 'rh_CP','rh_C_A4','rh_C_A5', 'rh_M_A4', 'rh_M_A5', 'rh_MPr', 'rh_MPc', 'rh_AL', 'rh_ML', 'rh_MM', 'rh_A1', 'rh_R_A4', 'rh_R_A5','rh_RT', 'rh_RTL', 'rh_R', 'rh_RM', 'rh_RP', 'rh_TA2', 'rh_TA3'}; % filename sX_roiName.txt

% this extension is added to filename at the end at the output
updated_file_ext = '_new';

for subj = 1:5
    disp(['Processing subject: s', num2str(subj)]);

    for rmain = 1:length(all_rois) % take one roi to compare against others

        disp('==========');

        roi1 = [];
        rois{1} = all_rois{rmain};
        %
        original_file = [inpath '/s', num2str(subj), '_', rois{1}, '.txt'];
        new_file = [inpath '/s', num2str(subj), '_', rois{1}, updated_file_ext, '.txt'];

        if ~exist(new_file, 'file')
            copyfile(original_file,new_file);
        end

        temp = textread(new_file);
        roi1 = temp(:,1:3);

        for r = setxor(rmain,1:length(all_rois)) % rois to compare against

            roi2 = [];

            rois{2} = all_rois{r};

            original_file = [inpath '/s', num2str(subj), '_', rois{2}, '.txt'];
            new_file = [inpath '/s', num2str(subj), '_', rois{2}, updated_file_ext, '.txt'];

            if ~exist(new_file, 'file')
                copyfile(original_file,new_file);
            end

            temp = textread(new_file);
            roi2 = temp(:,1:3);

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
                disp(['Voxels common between ' rois{1} ' & ' rois{2} ': ' num2str(length(common_vox_ind))]);
                if size(roi1,1) > size(roi2,1) %1 here means I want the size of the first dimension
                    final_roi1 = roi1(setxor(1:size(roi1,1),common_vox_ind(:,1)),:); %returns unique voxels of roi1
                    final_roi2 = roi2;
                    disp(['Removing from ' rois{1}]);
                else % roi2 is bigger
                    final_roi1 = roi1;
                    final_roi2 = roi2(setxor(1:size(roi2,1),common_vox_ind(:,2)),:);
                    disp(['Removing from ' rois{2}]);
                end

                % ==== write updated files only if they were modified
                if exist('final_roi1', 'var') && ~isequal(roi1, final_roi1)
                    outfile1 = [inpath '/s', num2str(subj), '_', rois{1}, updated_file_ext, '.txt'];
                    fileID = fopen(outfile1,'w');
                    fprintf(fileID,'%d %d %d\n',final_roi1');
                    fclose(fileID);
                end

                if exist('final_roi2', 'var') && ~isequal(roi2, final_roi2)
                    outfile2 = [inpath '/s', num2str(subj), '_', rois{2}, updated_file_ext, '.txt'];
                    fileID = fopen(outfile2,'w');
                    fprintf(fileID,'%d %d %d\n',final_roi2');
                    fclose(fileID);
                end
                disp('.....');
            else
                disp(['No common voxels between ' rois{1} ' & ' rois{2}]);
                disp('.....');
            end
        end
    end
end
