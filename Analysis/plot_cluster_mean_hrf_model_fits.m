% Plot selected session 2 cluster-mean ERA fits for the twogamma model figure.
%
% This script fits the same model set as fit_cluster_mean_hrf_models.m, then
% plots selected clusters as figure panels: canonical HRF, informed basis set,
% best GLMsingle HRF, and best custom gamma model.
%
% Last updated March 2026 (LS/IZ).

clear
clc
close all
set(gcf, 'Color', 'w');  % Set figure background to white

script_dir = fileparts(mfilename('fullpath'));
addpath(script_dir);

% ============= input file
cluster_means_file = '/path/to/auditory_HRF/analyses_2025/Clustering/Cluster_means_session2_Sep25.txt';
glmsingle_library_file = '/path/to/user_documents/GLMsingle-main/glmsingle/hrf/getcanonicalhrflibrary.tsv';

clusters = textread(cluster_means_file);
selected_clusters = [1, 16, 21, 28, 35, 39];

num_params_onegamma = 3;
num_params_twogamma = 6;
num_params_threegamma = 9;
num_params_canonical = 1 + 1; % + 1 for intercept (4 parameters for scale and shape in spm_hrf.m)
num_params_glmsingle = 1 + 1; 
num_params_informedbasis = 3 + 1;
model_param_counts = [num_params_onegamma, num_params_twogamma, ...
    num_params_threegamma, num_params_threegamma, ...
    num_params_threegamma, num_params_threegamma];
glmsingle = textread(glmsingle_library_file);
% =============

xx = 0:18; % data/fit timepoints

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


% Create a compact tiled layout
tiledlayout(2, 3, 'TileSpacing', 'compact', 'Padding', 'compact');
for idx = 1:length(selected_clusters)
    i = selected_clusters(idx);

    nexttile;

    disp('===========');
    disp(['Cluster: ' num2str(i)]);

    data = clusters(i,3:end);

    % =========== fitting canonical (default spm_hrf)
    bf = create_basisfunction();
    input = [1, zeros(1,length(xx)-1)]; % stick function
    canonical_bold = conv(input,bf(:,1));
    hrf = canonical_bold(xx+1);

    X = [hrf(:) ones(numel(hrf),1)];
    beta = X \ data(:);
    canonical_bold = (X * beta).';

    rsq_canonical(i) = getAdjustedRsquared(data,canonical_bold,num_params_canonical);
    disp(['Canonical, R-sq: ' num2str(getRsquared(data,canonical_bold))]);
    disp(['Canonical, R-sq (adj): ' num2str(rsq_canonical(i))]);

    % ========== fitting canonical + temporal and dispersion derivative
    bfs_bold = conv(input,bf(:,1)) + conv(input,bf(:,2)) + conv(input,bf(:,3));
    hrf = bfs_bold(xx+1);
  
    X = [hrf(:) ones(numel(hrf),1)];
    beta = X \ data(:);
    bfs_bold = (X * beta).';

    rsq_bfs(i) = getAdjustedRsquared(data,bfs_bold,num_params_informedbasis);
    disp(['Canonical + derivatives: ' num2str(getRsquared(data,bfs_bold))]);
    disp(['Canonical + derivatives, R-sq (adj): ' num2str(rsq_bfs(i))]);

    % =========== fitting glm single HRFs (convolve each of the 20
    % separately)
    bfglm = glmsingle();
    for k = 1:size(bfglm,2)
        temp = conv(input, bfglm(1:10:end,k));
        hrf = temp(xx+1);

        % fit scale + baseline to data
        X = [hrf(:) ones(numel(hrf),1)];
        beta = X \ data(:);

        glm_single(k,:) = (X * beta).';
        rsq_glmsingle(i,k) = getAdjustedRsquared(data,glm_single(k,:),num_params_glmsingle);
        disp(['GLM single (basis ' num2str(k) '), R-sq (adj): ' num2str(rsq_glmsingle(i,k))]);
    end

    [max_rsq(i), best_basis] = max(rsq_glmsingle(i,:));
    disp(['Best GLM single basis: ' num2str(best_basis) ', R-sq (adj): ' num2str(max_rsq)]);

    % ========= fitting our 6 models
    [f1{i},gof1{i}] = fit(xx',data',model1,'StartPoint',start_model1,...
        'Lower',lower_model1,'Upper',upper_model1);
    %
    [f2{i},gof2{i}] = fit(xx',data',model2,'StartPoint',start_model2,...
        'Lower',lower_model2,'Upper',upper_model2);

    [f3{i},gof3{i}] = fit(xx',data',model3,'StartPoint',start_model3,...
        'Lower',lower_model3,'Upper',upper_model3);

    [f4{i},gof4{i}] = fit(xx',data',model3,'StartPoint',start_model4,...
        'Lower',lower_model4,'Upper',upper_model4);

    [f5{i},gof5{i}] = fit(xx',data',model3,'StartPoint',start_model5,...
        'Lower',lower_model5,'Upper',upper_model5);

    [f6{i},gof6{i}] = fit(xx',data',model3,'StartPoint',start_model6,...
        'Lower',lower_model6,'Upper',upper_model6);

    % correcting for fit at bounds
    if ~checkatBoundM1(f1{i},upper_model1,lower_model1),      rsq(1,i) = gof1{i}.adjrsquare; else, rsq(1,i) = nan; end
    if ~checkatBoundM2(f2{i},upper_model2,lower_model2),      rsq(2,i) = gof2{i}.adjrsquare; else, rsq(2,i) = nan; end
    if ~checkatBoundM3_8(f3{i},upper_model3,lower_model3),    rsq(3,i) = gof3{i}.adjrsquare; else, rsq(3,i) = nan; end
    if ~checkatBoundM3_8(f4{i},upper_model4,lower_model4),    rsq(4,i) = gof4{i}.adjrsquare; else, rsq(4,i) = nan; end
    if ~checkatBoundM3_8(f5{i},upper_model5,lower_model5),    rsq(5,i) = gof5{i}.adjrsquare; else, rsq(5,i) = nan; end
    if ~checkatBoundM3_8(f6{i},upper_model6,lower_model6),    rsq(6,i) = gof6{i}.adjrsquare; else, rsq(6,i) = nan; end

    % if all the fits are NaN we skip to next cluster
    if all(isnan(rsq(1:6, i)))
        bm(i) = NaN;
        disp(['Cluster ' num2str(i) ': No valid model fit, skipping...']);
        continue; % skip to next cluster
    else
        [~, bm(i)] = max(rsq(1:6, i)); % compute best model only if not all NaN

    end

    % now convolve the best model, get the curve and convolve it with the stick functions (as for the other
    % models) and then get Rsq for the fit
    if bm(i) == 1
        temp_model = eval(['f' num2str(bm(i)) '{i}']);
        A = temp_model.A;
        fwhm1 = temp_model.fwhm1;
        peak1 = temp_model.peak1;
        hrf_curve = zeros(1, length(xx));
        for x = 0:18
            hrf_curve(x+1) = A*((((x/peak1)^((8*log10(2))*(peak1^2/fwhm1^2))) ...
                * exp(-((x-peak1)/((fwhm1^2)/((8*log10(2))*peak1))))));
        end
    elseif bm(i) == 2
        temp_model = eval(['f' num2str(bm(i)) '{i}']);
        A = temp_model.A;
        fwhm1 = temp_model.fwhm1;
        fwhm2 = temp_model.fwhm2;
        peak1 = temp_model.peak1;
        peak2 = temp_model.peak2;
        ratio = temp_model.ratio;
        hrf_curve = zeros(1, length(xx));
        for x = 0:18
            hrf_curve(x+1) = A * ((((x/peak1)^((8*log10(2)) * (peak1^2/fwhm1^2))) * exp(-((x-peak1)/((fwhm1^2) / ((8*log10(2)) * peak1))))) + (ratio * (((x/peak2)^((8*log10(2)) * (peak2^2/fwhm2^2))) * exp(-((x-peak2)/((fwhm2^2) / ((8*log10(2)) * peak2)))))));
        end
    elseif bm(i) >= 3 % model 3-6
        temp_model = eval(['f' num2str(bm(i)) '{i}']);
        A = temp_model.A;
        fwhm1 = temp_model.fwhm1;
        fwhm2 = temp_model.fwhm2;
        fwhm3 = temp_model.fwhm3;
        peak1 = temp_model.peak1;
        peak2 = temp_model.peak2;
        peak3 = temp_model.peak3;
        ratio1 = temp_model.ratio1;
        ratio2 = temp_model.ratio2;
        hrf_curve = zeros(1, length(xx));
        for x = 0:18
            hrf_curve(x+1) = A*((((x/peak1)^((8*log10(2))*(peak1^2/fwhm1^2)))*exp(-((x-peak1)/((fwhm1^2)/((8*log10(2))*peak1)))))+(ratio1*(((x/peak2)^((8*log10(2))*(peak2^2/fwhm2^2)))*exp(-((x-peak2)/((fwhm2^2)/((8*log10(2))*peak2))))))+(ratio2*(((x/peak3)^((8*log10(2))*(peak3^2/fwhm3^2)))*exp(-((x-peak3)/((fwhm3^2)/((8*log10(2))*peak3)))))));
        end
    end
    % Convolve and get Rsq
    custom_model_bold = [];
    input = [1, zeros(1,length(xx)-1)]; % stick function
    custom_model_bold = conv(input,hrf_curve);
    custom_model_bold = custom_model_bold';
    custom_model_bold = custom_model_bold(xx+1); 
    rsq_custom(i) = getAdjustedRsquared(data, custom_model_bold, model_param_counts(bm(i)));
    disp(['Conv custom model, R-sq (adj): ' num2str(rsq_custom(i))]);
  result_models(i,1) = bm(i);
    result_models(i,2) = rsq_custom(i);
    
    figure(100); clf; %diagnostic plots for custom models
    subplot(4,2,1); plot(xx,data,'o-'); title(['cluster: ' num2str(i) ' nvox: ' num2str(clusters(i,2))]); grid on;
    subplot(4,2,3); plot(f1{i},xx,data); title(['m1: ' num2str(rsq(1,i))]); grid on;
    subplot(4,2,4); plot(f2{i},xx,data); title(['m2: ' num2str(rsq(2,i))]); grid on;
    subplot(4,2,5); plot(f3{i},xx,data); title(['m3: ' num2str(rsq(3,i))]); grid on;
    subplot(4,2,6); plot(f4{i},xx,data); title(['m4: ' num2str(rsq(4,i))]); grid on;
    subplot(4,2,7); plot(f5{i},xx,data); title(['m5: ' num2str(rsq(5,i))]); grid on;
    subplot(4,2,8); plot(f6{i},xx,data); title(['m6: ' num2str(rsq(6,i))]); grid on;

    % Plots
    figure(100+i); clf
    p1 = plot(xx,data,'o');
    set(p1,{'Color','LineWidth'},{'k',2});
    hold on;
    p2 = plot(xx,canonical_bold);
    set(p2,{'Color','Linestyle','LineWidth'},{'b','--',2});
    p3 = plot(xx,bfs_bold);
    set(p3,{'Color','Linestyle','LineWidth'},{'g','--',2});
    p4 = plot(xx,glm_single(best_basis,:));
    set(p4,{'Color','Linestyle','LineWidth'},{'m','--',2});
    hold on;
    p5 = plot(xx, custom_model_bold);
    set(p5,{'Color','Linestyle','LineWidth'},{'r','--',2});

    x = gca; x.YLim = [-0.4 0.75]; x.FontSize = 14;
    xlabel('Time(s)'); ylabel('Signal Change (%)');
    if isnan(bm(i)) || isnan(rsq_custom(i))
        best_model_text = 'Best model fit: None';
    else
        best_model_text = ['Best model fit: ' num2str(bm(i)) ', gof: ' num2str(rsq_custom(i), '%.4f')];
    end
    legend({ ...
        'Data', ...
        ['Canonical HRF, gof: ' num2str(rsq_canonical(i), '%.4f')], ...
        ['Informed basis set, gof: ' num2str(rsq_bfs(i), '%.4f')], ...
        ['GLM single HRF, gof: ' num2str(max_rsq(i), '%.4f')], ...
        best_model_text ...
        });
    grid on;

    disp(['Best model: ' num2str(bm(i)) ' , R-sq (adj, custom model): ' num2str(rsq_custom(i))]);
    %     pause;
end
%To select only the best glm_single to paste into excel
glm_single_best = max(rsq_glmsingle, [], 2);
