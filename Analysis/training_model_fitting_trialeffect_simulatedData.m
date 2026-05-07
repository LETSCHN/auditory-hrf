% This script averages SIMULATED data over n-trials (customizable) and stores model fits (best model
% and rsq). Used to test trial effect on hrf detection.
%
% best models and r-sq vlaues are saved.
%
% IZ (2025)

clear
clc
close all
rng('default')

% ===================
inpath = [pwd '/'];
infile = 'simulated_data_nVox1000_144reps.mat';

outfile = 'fitted_simulted_data_trialeffect.mat';

nRunsPerSession = 6;
nSessions = 2;

xx = 0:18; % time axes of data & fits

% ================== data combinations, check carefully to match data model fitting, add more combinations as needed

% combinations in session 1
for i = 1:nRunsPerSession
    train{i} = 1:i; % data only from run 1
end

% combinations in all other sessions
for i = 2:nSessions
    train{nRunsPerSession+i-1} = 1:nSessions*nRunsPerSession; % all trials till that session
end

nSounds = 12; % per run
sounds = 1:nSounds:nSounds*nRunsPerSession*nSessions; % all sessions

xx = 0:18; % time axes of data & fits

% =================
load([inpath '/' infile],'simulated_data_all_reps');

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



%%  ============================ Model fitting =================== %

nvox = 1000;

all_sess= simulated_data_all_reps;

for i = 1:nvox
    disp('--------');

    rsq = [];
    for itr = 1:length(train)

        temp = sounds(train{itr});
        curr_reps = [];

        for yy = 1:size(temp,2)
            curr_reps = [curr_reps, temp(yy):temp(yy)+nSounds-1];
        end

        data = squeeze(mean(all_sess(curr_reps,i,:),1))';


        [f1,gof1] = fit(xx',data',model1,'StartPoint',start_model1,...
            'Lower',lower_model1,'Upper',upper_model1);

        [f2,gof2] = fit(xx',data',model2,'StartPoint',start_model2,...
            'Lower',lower_model2,'Upper',upper_model2);

        [f3,gof3] = fit(xx',data',model3,'StartPoint',start_model3,...
            'Lower',lower_model3,'Upper',upper_model3);

        [f4,gof4] = fit(xx',data',model3,'StartPoint',start_model4,...
            'Lower',lower_model4,'Upper',upper_model4);

        [f5,gof5] = fit(xx',data',model3,'StartPoint',start_model5,...
            'Lower',lower_model5,'Upper',upper_model5);

        [f6,gof6] = fit(xx',data',model3,'StartPoint',start_model6,...
            'Lower',lower_model6,'Upper',upper_model6);



        if ~checkatBoundM1(f1,upper_model1,lower_model1),      rsq(1) = gof1.adjrsquare; else, rsq(1) = nan; end
        if ~checkatBoundM2(f2,upper_model2,lower_model2),      rsq(2) = gof2.adjrsquare; else, rsq(2) = nan; end
        if ~checkatBoundM3_8(f3,upper_model3,lower_model3),    rsq(3) = gof3.adjrsquare; else, rsq(3) = nan; end
        if ~checkatBoundM3_8(f4,upper_model4,lower_model4),    rsq(4) = gof4.adjrsquare; else, rsq(4) = nan; end
        if ~checkatBoundM3_8(f5,upper_model5,lower_model5),    rsq(5) = gof5.adjrsquare; else, rsq(5) = nan; end
        if ~checkatBoundM3_8(f6,upper_model6,lower_model6),    rsq(6) = gof6.adjrsquare; else, rsq(6) = nan; end


        [rsq_overall(itr,i),bm_overall(itr,i)] = max(rsq(:));
        disp(['voxel: ' num2str(i) ', runs ' num2str(train{itr}) ', bm: ' num2str(bm_overall(itr,i)) ', rsq-adj: ' num2str(rsq_overall(itr,i))]);


        % subplot(4,2,1); plot(xx,data,'ko:'); title(['data']); grid on;
        % hold on; %plot(xx,smooth(data,0.3,'loess')'); plot(xx,smooth(data,0.3,'rloess')'); grid on;
        % subplot(4,2,3); plot(f1,xx,data); title(['m1: ' num2str(rsq(1))]); grid on; hold on; legend('off')
        % subplot(4,2,4); plot(f2,xx,data); title(['m2: ' num2str(rsq(2))]); grid on; hold on; legend('off')
        % subplot(4,2,5); plot(f3,xx,data); title(['m3: ' num2str(rsq(3))]); grid on; hold on; legend('off')
        % subplot(4,2,6); plot(f4,xx,data); title(['m4: ' num2str(rsq(4))]); grid on; hold on; legend('off')
        % subplot(4,2,7); plot(f5,xx,data); title(['m5: ' num2str(rsq(5))]); grid on; hold on; legend('off')
        % subplot(4,2,8); plot(f6,xx,data); title(['m6: ' num2str(rsq(6))]); grid on; hold on; legend('off')

        %pause(0.5); clf
    end

end

save(outfile, "bm_overall",'rsq_overall','train');

