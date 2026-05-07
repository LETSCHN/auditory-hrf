% export_hrf_txt.m
% Writes concatenated_data_* variables from .mat files to text files
% Naming convention: sXX_<hemi>_<metric>_Marty_ROIs_bm.txt
% Folder: /Volumes/Elements/auditory_HRF/analyses_2025/updated_model6

clear; clc;

baseDir = '/Volumes/Elements/auditory_HRF/analyses_2025/updated_model6';
cd(baseDir);

% --- Choose subjects based on baseDir ---
% Replace these with your actual directory strings
dirA = '/Volumes/Elements/auditory_HRF/analyses_2025/updated_model6';  % example A
dirB = '/Volumes/Elements/HiHi/updated_model6'; % example B

if strcmp(baseDir, dirA)
    % subjects 1–5 
    subjects = {'s01','s02','s03','s04','s05'};
elseif strcmp(baseDir, dirB)
    % subjects 1,2,3,5,6,7 (skipping s04)
    subjects = {'s01','s02','s03','s05','s06','s07'};
else
    % Fallback (optional): default set or throw an error
    warning('baseDir "%s" not matched; using default subjects 1,2,3,5.', baseDir);
    subjects = {'s01','s02','s03','s05'};
end

hemis = {'lh','rh'};

% Map from variable -> metric token in output filename
varInfo = {
    'concatenated_data_amp',  'amp';
    'concatenated_data_peak', 'peak';
    'concatenated_data_fwhm', 'fwhm';
};

for iSub = 1:numel(subjects)
    subj = subjects{iSub};
    for iH = 1:numel(hemis)
        hemi = hemis{iH};

        % Construct input .mat filename
        inFile = sprintf('%s_%s_fittedAmpPeakFWHM_ROIs_cutoff1500_allsess.mat', subj, hemi);

        if ~isfile(inFile)
            fprintf(2, 'WARNING: Missing file: %s\n', inFile);
            continue;
        end

        % Load only the expected variables (faster/safer)
        S = load(inFile, varInfo{:,1});

        % For each variable, write a text file with the target naming convention
        for iv = 1:size(varInfo,1)
            varName   = varInfo{iv,1};
            metricTag = varInfo{iv,2};

            if ~isfield(S, varName) || isempty(S.(varName))
                fprintf(2, 'WARNING: %s missing or empty in %s\n', varName, inFile);
                continue;
            end

            data = S.(varName);

            % Ensure numeric output
            if ~isnumeric(data)
                fprintf(2, 'WARNING: %s in %s is not numeric. Skipping.\n', varName, inFile);
                continue;
            end

            % Output filename: sXX_<hemi>_<metric>_Marty_ROIs_bm.txt
            outFile = sprintf('%s_%s_%s_Marty_ROIs_bm.txt', subj, hemi, metricTag);

            try
                % Use tab delimiter if you prefer: 'Delimiter','tab'
                writematrix(data, outFile);
                fprintf('Wrote: %s\n', outFile);
            catch ME
                fprintf(2, 'ERROR writing %s: %s\n', outFile, ME.message);
            end
        end
    end
end

fprintf('Done.\n');