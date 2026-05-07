% This script performs model fitting for all voxels based on the model that
% best fits using the data from different combinations of runs (stable best
% model estimates using leave one run out combination). 
%
% Models are 1 gamma (1), 2 gamma (1) and sum of 3 gammas (4) based on the
% clusterization of across subject ERAs
% 
% Some sanity checks: 
%   Bound checks are performed to see if the fitted curve has 
%       a) very small amplitude for one of the gammas
%       b) parameters at the upper/lower bounds
%
%   If a model fails the bound checks for more than 2 leave-one-out
%   iterations, we consider it not a good model.
% 
% Input: ERAs (event realted responses NOT averaged over trials)
% Output: Best model, Rsq and model fits (All params) across leave-one-run-out
% iterations, per voxel
%
% Run per subject
%
% IZ (2025)

clear; clc; close all
rng('default');

% ====================
inpath = ['/Volumes/Elements/auditory_HRF/analyses_2025/'];
infile = 'smoothed_data_cutoff1500_ERA_SD_CORR85.mat'; % data file with individual reps
% data is assumed to be organized as:
% all_reps_eras_norm subject x session cell array
%           each cell is: repetitions x voxels x timepoints

outpath = inpath;
outfile = 'training_s0'; % outfile_s0(subject)_sess(sess).mat

subject = 1;
sess = 1; % Fit responses in this session

xx = 0:18; % The data is sampled along this axis (so will be the fit)

% leave one out combinations based on 6 runs
train = [1,2,3,4,5;
    1,2,3,4,6;
    1,2,3,5,6;
    1,2,4,5,6;
    1,3,4,5,6;
    2,3,4,5,6];

nSounds = 12; % per run
sounds = 1:nSounds:72; % index of trials indicating next run
%=============

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

                %  A   fw1  fw2 fw3  p1  p2   p3    r1      r2
start_model6 = [-0.1,   1,  2,  4, 1.5,  6,   9,  -0.1,    0.1];
lower_model6 = [  -3,   1,  2,  3,   1,  4,   8,    -3,     -3];
upper_model6 = [   0,   2,  4,  7,   3,  7,  18,     0,      3];


%%  ================= Model fitting =================== %%
% load data
load([inpath infile],'all_reps_eras_norm');

for s = subject
    nvox = size(all_reps_eras_norm{s,sess},2);

    for i = 1:nvox   % 1:nvox %voxels
        disp('--------');
        %if rem(i,200)==0, disp(i); end

        for itr = 1:size(train,1)

            temp = sounds(train(itr,:));
            curr_reps = [];

            for yy = 1:size(temp,2)
                curr_reps = [curr_reps, temp(yy):temp(yy)+nSounds-1];
            end


            data = squeeze(mean(all_reps_eras_norm{s,sess}(curr_reps,i,:),1))';


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



            if ~checkatBoundM1(f1{itr},upper_model1,lower_model1),      rsq(1,itr,i) = gof1{itr}.adjrsquare; else, rsq(1,itr,i) = nan; end
            if ~checkatBoundM2(f2{itr},upper_model2,lower_model2),      rsq(2,itr,i) = gof2{itr}.adjrsquare; else, rsq(2,itr,i) = nan; end
            if ~checkatBoundM3_8(f3{itr},upper_model3,lower_model3),    rsq(3,itr,i) = gof3{itr}.adjrsquare; else, rsq(3,itr,i) = nan; end
            if ~checkatBoundM3_8(f4{itr},upper_model4,lower_model4),    rsq(4,itr,i) = gof4{itr}.adjrsquare; else, rsq(4,itr,i) = nan; end
            if ~checkatBoundM3_8(f5{itr},upper_model5,lower_model5),    rsq(5,itr,i) = gof5{itr}.adjrsquare; else, rsq(5,itr,i) = nan; end
            if ~checkatBoundM3_8(f6{itr},upper_model6,lower_model6),    rsq(6,itr,i) = gof6{itr}.adjrsquare; else, rsq(6,itr,i) = nan; end


            [val,bm] = max(rsq(:,itr,i));
            disp(['voxel: ' num2str(i) ', itr: ' num2str(itr) ', bm: ' num2str(bm) ', rsq-adj: ' num2str(val)]);


            % uncomment to see individual fits
%             figure(1);
%             subplot(4,2,1); plot(xx,data,'ko:'); title(['data']); hold on; grid on; 
%             subplot(4,2,3); plot(f1{itr},xx,data); title(['m1: ' num2str(rsq(1,itr,i))]); grid on; hold on; legend('off')
%             subplot(4,2,4); plot(f2{itr},xx,data); title(['m2: ' num2str(rsq(2,itr,i))]); grid on; hold on; legend('off')
%             subplot(4,2,5); plot(f3{itr},xx,data); title(['m3: ' num2str(rsq(3,itr,i))]); grid on; hold on; legend('off')
%             subplot(4,2,6); plot(f4{itr},xx,data); title(['m4: ' num2str(rsq(4,itr,i))]); grid on; hold on; legend('off')
%             subplot(4,2,7); plot(f5{itr},xx,data); title(['m5: ' num2str(rsq(5,itr,i))]); grid on; hold on; legend('off')
%             subplot(4,2,8); plot(f6{itr},xx,data); title(['m6: ' num2str(rsq(6,itr,i))]); grid on; hold on; legend('off')


        end

%         legend({'data','fitted curve'});

        % if a model performs 'bad' (based on bound checks) more than 2 times,
        % exclude it befor averaging rsq-adj
        for m = 1:6
            if length(find(isnan(rsq(m,:,i)))) > 2
                rsq(m,:,i) = nan(1,6);
            end
        end

        % saving bm as model with highest rsq + the max rsq value
        [rsq_overall(i),bm_overall(i)] = max(squeeze(nanmean(rsq(:,:,i),2)));
        disp(['bm_avg: ' num2str(bm_overall(i)) ', rsq-adj: ' num2str(rsq_overall(i))]);

        % axes_label_train;
%         pause;
%         clf;


        % storing model estimates from iterations
        for itr = 1:size(train,1)
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

        % bm_bounds_Low =

    end

    save([outpath outfile num2str(s) '_sess' num2str(sess)],'m1','m2','m3','m4','m5','m6',...
        "bm_overall",'rsq_overall','rsq',"s",'sess','train');

end


