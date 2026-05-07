% This script averages data over n-trials (customizable) and stores model fits (best model
% and rsq). Used to test trial effect on hrf detection.
%
% Can be run for all subjects together
% Modified in Nov25 by IZ and LS with updated model 6, correction of run
% combinations to accomodate more sessions, and correction of length vs
% size of itr loop! Modified in Dec by LS to avoid overwriting of "rsq"
% variable which is needed for "analyse_stability.m" script
% IZ (2025)

clear
clc
close all
rng('default')

% ===================
inpath = [pwd];
infile = 'smoothed_data_cutoff1500_ERA_SD_CORR85.mat'; % output ERAs from pre-processing scripts, all subject file

outfile = '_trialeffect.mat'; % training_s0X_outfile

subjects = 2:4;

nRunsPerSession = 6;
nSessions = 2;

xx = 0:18; % time axes of data & fits

% ================== data combinations, check carefully, add more combinations as needed

%%% Per session
% combinations in session 1
for i = 1:nRunsPerSession
    train{i} = 1:i; % data only from run 1
end

% combinations in all other sessions
for i = 2:nSessions
    train{nRunsPerSession+i-1} = 1:i*nRunsPerSession; % all trials till that session
end

%%% Sounds are concatenated per run
nSounds = 12; % per run
sounds = 1:nSounds:nSounds*nRunsPerSession*nSessions; % all sessions

% ===================
load([inpath '/' infile],'all_reps_eras_norm');


%% set equations

% single gamma; mid peak
model1 = fittype('A*((((x/peak1)^((8*log10(2))*(peak1^2/fwhm1^2)))*exp(-((x-peak1)/((fwhm1^2)/((8*log10(2))*peak1))))))',...
    'dependent',{'y'},'independent',{'x'},...
    'coefficients',{'A','fwhm1','peak1'});

% two gamma
model2 = fittype('A * ((((x/peak1)^((8*log10(2)) * (peak1^2/fwhm1^2))) * exp(-((x-peak1)/((fwhm1^2) / ((8*log10(2)) * peak1))))) + (ratio * (((x/peak2)^((8*log10(2)) * (peak2^2/fwhm2^2))) * exp(-((x-peak2)/((fwhm2^2) / ((8*log10(2)) * peak2)))))))',...
    'dependent',{'y'},'independent',{'x'},...
    'coefficients',{'A','fwhm1','fwhm2','peak1','peak2','ratio'});

% three gamma
model3 = fittype('A*((((x/peak1)^((8*log10(2))*(peak1^2/fwhm1^2)))*exp(-((x-peak1)/((fwhm1^2)/((8*log10(2))*peak1)))))+(ratio1*(((x/peak2)^((8*log10(2))*(peak2^2/fwhm2^2)))*exp(-((x-peak2)/((fwhm2^2)/((8*log10(2))*peak2))))))+(ratio2*(((x/peak3)^((8*log10(2))*(peak3^2/fwhm3^2)))*exp(-((x-peak3)/((fwhm3^2)/((8*log10(2))*peak3)))))))',...
    'dependent',{'y'},'independent',{'x'},...
    'coefficients',{'A','fwhm1','fwhm2','fwhm3','peak1','peak2','peak3','ratio1','ratio2'});


%% initialize

% ======  M1 Single peak, both +ve & -ve
% A       fw1     peak1
start_model1 = [0.4,     6,      6];
lower_model1 = [ -3,     2,      2];
upper_model1 = [  3,    16,     18];

%  M2: Two peaks all combinations
%  A      fw1     fw2     p1      p2      r1
start_model2 = [ 1,     4,      6,      4,      12,     0.1];
lower_model2 = [-3,     2,      3,      2,       9,     -3];
upper_model2 = [ 3,     8,     12,      8,      18,       3];


% ======  M3: Three peaks + - +

%  A   fw1  fw2 fw3  p1  p2   p3    r1      r2
start_model3 = [0.4,   4,  3,  3,  6,  11,  15,  -0.1,    0.1];
lower_model3 = [  0,   3,  1,  2,  2,  7,   14,    -3,      0];
upper_model3 = [  3,   6,  5,  4,  6,  13,  18,     0,      3];

% ======  M4: Three peaks + - + (shifted later)

%  A   fw1  fw2 fw3  p1  p2   p3    r1      r2
start_model4 = [0.4,   4,  3,  3,  6,  11,  16,  -0.1,    0.1];
lower_model4 = [  0,   3,  1,  2,  3,  10,  15,    -3,      0];
upper_model4 = [  3,   6,  5,  4,  9,  14,  18,     0,      3];

% ======  M5: Three peaks - + +(-)

%  A   fw1  fw2 fw3   p1  p2   p3    r1      r2
start_model5 = [-0.1, 2.5,  4,  6,    4,  9,  16,  -0.1,      0.1];
lower_model5 = [  -3,   2,  1,  2,    3,  6,  12,    -3,       -3];
upper_model5 = [   0,   4,  6, 10,    5, 10,  18,     0,        3];

% ======  M6: Initial dip - + -(+)

%  A   fw1  fw2 fw3  p1    p2   p3    r1      r2
start_model6 = [-0.01,   1,  2,  4, 1.5,    6,    9,  -10,    10];
lower_model6 = [ -0.5,   1,  2,  3,   1,  3.5,    8,  -80,   -40];
upper_model6 = [    0,   2,  4,  7,   3,    7,   18,    0,    40];

%%  ======================== Model fitting =================== %%

for s = subjects

    nvox = size(all_reps_eras_norm{s,1},2); % Assuming data is from same voxels across all sessions
    nModels = 6; %these were added to pre-allocate rsq
    nItr    = length(train);

    all_data = []; % concatenating all sessions (nReps x nVox x nTimePoints)
    for sess = 1:nSessions
        all_data = [all_data; all_reps_eras_norm{s,sess}];
    end
 
    rsq_overall = nan(nItr, nvox); %this was also added to avoid overwriting
    bm_overall  = nan(nItr, nvox);
    rsq         = nan(nModels, nItr, nvox);   % <-- key line

    % loop over all voxels
    for i = 1:nvox
        disp('--------');

        for itr = 1:length(train) % all possible combinations of data defined above
            % ======= organizing data based on number of trials to combine
            data = [];

            temp = sounds(train{itr});
            curr_reps = [];
            for yy = 1:size(temp,2)
                curr_reps = [curr_reps, temp(yy):temp(yy)+nSounds-1];
            end

            data = squeeze(mean(all_data(curr_reps,i,:),1))'; % averaging over Repetitions

            % ===== model fitting
            [f1{itr},gof1{itr}] = fit(xx',data',model1,'StartPoint',start_model1,...
                'Lower',lower_model1,'Upper',upper_model1);

            [f2{itr},gof2{itr}] = fit(xx',data',model2,'StartPoint',start_model2,...
                'Lower',lower_model2,'Upper',upper_model2);

            [f3{itr},gof3{itr}] = fit(xx',data',model3,'StartPoint',start_model3,...
                'Lower',lower_model3,'Upper',upper_model3);

            [f4{itr},gof4{itr}] = fit(xx',data',model3,'StartPoint',start_model4,...
                'Lower',lower_model4,'Upper',upper_model4);

            [f5{itr},gof5{itr}] = fit(xx',data',model3,'StartPoint',start_model5,...
                'Lower',lower_model5,'Upper',upper_model5);

            [f6{itr},gof6{itr}] = fit(xx',data',model3,'StartPoint',start_model6,...
                'Lower',lower_model6,'Upper',upper_model6);

            % ====== bound checks
            if ~checkatBoundM1(f1{itr},upper_model1,lower_model1),      rsq(1,itr,i) = gof1{itr}.adjrsquare; else, rsq(1,itr,i) = nan; end
            if ~checkatBoundM2(f2{itr},upper_model2,lower_model2),      rsq(2,itr,i) = gof2{itr}.adjrsquare; else, rsq(2,itr,i) = nan; end
            if ~checkatBoundM3_8(f3{itr},upper_model3,lower_model3),    rsq(3,itr,i) = gof3{itr}.adjrsquare; else, rsq(3,itr,i) = nan; end
            if ~checkatBoundM3_8(f4{itr},upper_model4,lower_model4),    rsq(4,itr,i) = gof4{itr}.adjrsquare; else, rsq(4,itr,i) = nan; end
            if ~checkatBoundM3_8(f5{itr},upper_model5,lower_model5),    rsq(5,itr,i) = gof5{itr}.adjrsquare; else, rsq(5,itr,i) = nan; end
            if ~checkatBoundM3_8(f6{itr},upper_model6,lower_model6),    rsq(6,itr,i) = gof6{itr}.adjrsquare; else, rsq(6,itr,i) = nan; end

            [rsq_overall(itr,i),bm_overall(itr,i)] = max(rsq(:,itr,i));
            disp(['voxel: ' num2str(i) ', runs: ' num2str(train{itr}) ', bm: ' num2str(bm_overall(itr,i)) ', rsq-adj: ' num2str(rsq_overall(itr,i))]);

            % ===== uncomment if individual fits need to be plotted
            %                 figure(1); clf;
            %                 subplot(4,2,1); plot(xx,data,'ko:'); title(['data']); grid on; hold on;
            %                 subplot(4,2,3); plot(f1{itr},xx,data); title(['m1: ' num2str(rsq(1,itr,i))]); grid on; hold on; legend('off')
            %                 subplot(4,2,4); plot(f2{itr},xx,data); title(['m2: ' num2str(rsq(2,itr,i))]); grid on; hold on; legend('off')
            %                 subplot(4,2,5); plot(f3{itr},xx,data); title(['m3: ' num2str(rsq(3,itr,i))]); grid on; hold on; legend('off')
            %                 subplot(4,2,6); plot(f4{itr},xx,data); title(['m4: ' num2str(rsq(4,itr,i))]); grid on; hold on; legend('off')
            %                 subplot(4,2,7); plot(f5{itr},xx,data); title(['m5: ' num2str(rsq(5,itr,i))]); grid on; hold on; legend('off')
            %                 subplot(4,2,8); plot(f6{itr},xx,data); title(['m6: ' num2str(rsq(6,itr,i))]); grid on; hold on; legend('off')
        end

        % legend({'data','fitted curve'});

        % storing model estimates from iterations
        for itr = 1:length(train)
            % model 1
            if ~isnan(rsq(1,itr,i)), m1.A{i}(itr,:)     = f1{itr}.A;        else m1.A{i}(itr,:)     = nan; end
            if ~isnan(rsq(1,itr,i)), m1.fwhm1{i}(itr,:) = f1{itr}.fwhm1;    else m1.fwhm1{i}(itr,:) = nan; end
            if ~isnan(rsq(1,itr,i)), m1.peak1{i}(itr,:) = f1{itr}.peak1;    else m1.peak1{i}(itr,:) = nan; end
            m1.gof{i}(itr,:)   = gof1{itr};

            % model 2
            if ~isnan(rsq(2,itr,i)), m2.A{i}(itr,:)     = f2{itr}.A;        else m2.A{i}(itr,:)     = nan; end
            if ~isnan(rsq(2,itr,i)), m2.fwhm1{i}(itr,:) = f2{itr}.fwhm1;    else m2.fwhm1{i}(itr,:) = nan; end
            if ~isnan(rsq(2,itr,i)), m2.peak1{i}(itr,:) = f2{itr}.peak1;    else m2.peak1{i}(itr,:) = nan; end
            if ~isnan(rsq(2,itr,i)), m2.fwhm2{i}(itr,:) = f2{itr}.fwhm2;    else m2.fwhm2{i}(itr,:) = nan; end
            if ~isnan(rsq(2,itr,i)), m2.peak2{i}(itr,:) = f2{itr}.peak2;    else m2.peak2{i}(itr,:) = nan; end
            if ~isnan(rsq(2,itr,i)), m2.ratio{i}(itr,:) = f2{itr}.ratio;    else m2.ratio{i}(itr,:) = nan; end
            m2.gof{i}(itr,:)   = gof2{itr};

            % model 3:6
            for cur_m = 3:6
                model_temp = eval(['f' num2str(cur_m) ';']);

                if ~isnan(eval(['rsq(' num2str(cur_m) ',itr,i)']))

                    eval(['m' num2str(cur_m) '.A{i}(itr,:)      = f' num2str(cur_m) '{itr}.A;']);
                    eval(['m' num2str(cur_m) '.fwhm1{i}(itr,:)  = f' num2str(cur_m) '{itr}.fwhm1;']);
                    eval(['m' num2str(cur_m) '.fwhm2{i}(itr,:)  = f' num2str(cur_m) '{itr}.fwhm2;']);
                    eval(['m' num2str(cur_m) '.fwhm3{i}(itr,:)  = f' num2str(cur_m) '{itr}.fwhm3;']);
                    eval(['m' num2str(cur_m) '.peak1{i}(itr,:)  = f' num2str(cur_m) '{itr}.peak1;']);
                    eval(['m' num2str(cur_m) '.peak2{i}(itr,:)  = f' num2str(cur_m) '{itr}.peak2;']);
                    eval(['m' num2str(cur_m) '.peak3{i}(itr,:)  = f' num2str(cur_m) '{itr}.peak3;']);
                    eval(['m' num2str(cur_m) '.ratio1{i}(itr,:) = f' num2str(cur_m) '{itr}.ratio1;']);
                    eval(['m' num2str(cur_m) '.ratio2{i}(itr,:) = f' num2str(cur_m) '{itr}.ratio2;']);
                    eval(['m' num2str(cur_m) '.gof{i}(itr,:)    = gof' num2str(cur_m) '{itr};']);

                else

                    eval(['m' num2str(cur_m) '.A{i}(itr,:)      = nan;']);
                    eval(['m' num2str(cur_m) '.fwhm1{i}(itr,:)  = nan;']);
                    eval(['m' num2str(cur_m) '.fwhm2{i}(itr,:)  = nan;']);
                    eval(['m' num2str(cur_m) '.fwhm3{i}(itr,:)  = nan;']);
                    eval(['m' num2str(cur_m) '.peak1{i}(itr,:)  = nan;']);
                    eval(['m' num2str(cur_m) '.peak2{i}(itr,:)  = nan;']);
                    eval(['m' num2str(cur_m) '.peak3{i}(itr,:)  = nan;']);
                    eval(['m' num2str(cur_m) '.ratio1{i}(itr,:) = nan;']);
                    eval(['m' num2str(cur_m) '.ratio2{i}(itr,:) = nan;']);
                    eval(['m' num2str(cur_m) '.gof{i}(itr,:)    = gof' num2str(cur_m) '{itr};']);

                end
            end
        end
    end

    save([inpath '/training_s0' num2str(s) outfile],'m1','m2','m3','m4','m5','m6',...
        "bm_overall",'rsq_overall',"s",'nSessions','train','rsq');

end