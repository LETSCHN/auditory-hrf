% This script simulates responses for voxels by embedding one of the hrf
% shapes (1 gamma (+, -), 2 gamma (all combos), 3 gamma (+ - + early, + - +
% delayed, - + -(+) delayed, - + -(+) initial dip
%
% Same number of voxels for each shape
%
% noise at 1st two timepoints is low (1 stdev), then 3 stdev for later
% timepoints
%
% Analyst note (2025)

clear
close all
clc

outfile = 'simulated_data_nVox1000_288reps.mat'; % change based on variables below
% ============
nVox = 1000; % total to simulate
nModels = 6;
nReps = 72*4;
ntimePoints = 19; % 0 - 18

% 2 1G, 4 2G models, 4 3G models
nVox_distribution = floor(1:nVox/10    :nVox);
nVox_distribution = nVox_distribution(2:end);

% std dev of noise, based on actual data measurements across subjects
% smaller for 1st 2 data points (part of baseline)
std_noise_t1_2 = 1;
std_noise_t3_end = 3;
% ============

simulated_data_all_reps = nan(nReps,nVox, ntimePoints); % with noise
simulated_data = nan(nVox,ntimePoints);

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 1. 1 gamma + ==== 6 %

for i = 1:nVox_distribution(1)
    % simulating no noise hrf response of voxel
    amplitudes = [0.1:0.1:3]; % never 0
    widths = [4:10];
    peaks = [6 8];

    A = amplitudes(randperm(length(amplitudes),1));
    peak1 = peaks(randperm(length(peaks),1));
    fwhm1 = widths(randperm(length(widths),1));

    for x = 0:18
        simulated_data(i,x+1) = A*((((x/peak1)^((8*log10(2))*(peak1^2/fwhm1^2)))*exp(-((x-peak1)/((fwhm1^2)/((8*log10(2))*peak1))))));
    end

    figure(1); clf;
    plot(0:18,simulated_data(i,:));

    % adding noise to data
    for reps = 1:nReps
        for x = 0:1
            simulated_data_all_reps(reps,i,x+1) = simulated_data(i,x+1)+(randn*std_noise_t1_2);
        end
        for x = 2:18
            simulated_data_all_reps(reps,i,x+1) = simulated_data(i,x+1)+(randn*std_noise_t3_end);
        end
        %plot(0:18, simulated_data_all_reps(reps,i,:),'o');
    end
    hold on;
    plot(0:18,squeeze(mean(simulated_data_all_reps(:,i,:))));

    pause(0.1); 
end

%% 2. 1 gamma -
for i = nVox_distribution(1)+1:nVox_distribution(2)

    % simulating no noise hrf response of voxel
    amplitudes = [-3:0.1:-0.1]; % never 0
    widths = [4:10];
    peaks = [6 8];

    A = amplitudes(randperm(length(amplitudes),1));
    peak1 = peaks(randperm(length(peaks),1));
    fwhm1 = widths(randperm(length(widths),1));

    for x = 0:18
        simulated_data(i,x+1) = A*((((x/peak1)^((8*log10(2))*(peak1^2/fwhm1^2)))*exp(-((x-peak1)/((fwhm1^2)/((8*log10(2))*peak1))))));
    end

    figure(1); clf
    plot(0:18,simulated_data(i,:));

    % adding noise
    for reps = 1:nReps
        for x = 0:1
            simulated_data_all_reps(reps,i,x+1) = simulated_data(i,x+1)+randn*std_noise_t1_2;
        end
        for x = 2:18
            simulated_data_all_reps(reps,i,x+1) = simulated_data(i,x+1)+randn*std_noise_t3_end;
        end
        %plot(0:18, simulated_data_all_reps(reps,i,:),'o');
    end
    hold on;
    plot(0:18,squeeze(mean(simulated_data_all_reps(:,i,:))));

    pause(0.1); clf
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 3. 2 gamma + +
for i = nVox_distribution(2)+1:nVox_distribution(3)
    amplitudes = [0.1:0.1:3]; % never 0
    widths1 = [2:7];
    peaks1 = [2:7];

    widths2 = [3:9];
    peaks2 = [9:16];
    ratios1 = [0.5:0.1:3];

    A = amplitudes(randperm(length(amplitudes),1));
    peak1 = peaks1(randperm(length(peaks1),1));
    fwhm1 = widths1(randperm(length(widths1),1));
    peak2 = peaks2(randperm(length(peaks2),1));
    fwhm2 = widths2(randperm(length(widths2),1));
    ratio = ratios1(randperm(length(ratios1),1));

    for x = 0:18
        simulated_data(i,x+1) = A * ((((x/peak1)^((8*log10(2)) * (peak1^2/fwhm1^2))) * exp(-((x-peak1)/((fwhm1^2) / ((8*log10(2)) * peak1))))) + (ratio * (((x/peak2)^((8*log10(2)) * (peak2^2/fwhm2^2))) * exp(-((x-peak2)/((fwhm2^2) / ((8*log10(2)) * peak2)))))));
    end

    figure(1);
    plot(0:18,simulated_data(i,:));

    % adding noise
    for reps = 1:nReps
        for x = 0:1
            simulated_data_all_reps(reps,i,x+1) = simulated_data(i,x+1)+randn*std_noise_t1_2;
        end
        for x = 2:18
            simulated_data_all_reps(reps,i,x+1) = simulated_data(i,x+1)+randn*std_noise_t3_end;
        end
        %plot(0:18, simulated_data_all_reps(reps,i,:),'o');
    end
    hold on;
    plot(0:18,squeeze(mean(simulated_data_all_reps(:,i,:))));

    pause(0.1); clf
end

%% 4. 2 gamma + -
for i = nVox_distribution(3)+1:nVox_distribution(4)

    amplitudes = [0.1:0.1:3]; % never 0
    widths1 = [2:6];
    peaks1 = [2:7];

    widths2 = [3:6];
    peaks2 = [8:12];
    ratios1 = [-3:0.1:-0.5];

    A = amplitudes(randperm(length(amplitudes),1));
    peak1 = peaks1(randperm(length(peaks1),1));
    fwhm1 = widths1(randperm(length(widths1),1));
    peak2 = peaks2(randperm(length(peaks2),1));
    fwhm2 = widths2(randperm(length(widths2),1));
    ratio = ratios1(randperm(length(ratios1),1));

    for x = 0:18
        simulated_data(i,x+1) = A * ((((x/peak1)^((8*log10(2)) * (peak1^2/fwhm1^2))) * exp(-((x-peak1)/((fwhm1^2) / ((8*log10(2)) * peak1))))) + (ratio * (((x/peak2)^((8*log10(2)) * (peak2^2/fwhm2^2))) * exp(-((x-peak2)/((fwhm2^2) / ((8*log10(2)) * peak2)))))));
    end

    figure(1);
    plot(0:18,simulated_data(i,:));

    % adding noise
    for reps = 1:nReps
        for x = 0:1
            simulated_data_all_reps(reps,i,x+1) = simulated_data(i,x+1)+randn*std_noise_t1_2;
        end
        for x = 2:18
            simulated_data_all_reps(reps,i,x+1) = simulated_data(i,x+1)+randn*std_noise_t3_end;
        end
        %plot(0:18, simulated_data_all_reps(reps,i,:),'o');
    end
    hold on;
    plot(0:18,squeeze(mean(simulated_data_all_reps(:,i,:))));

%     pause(0.1); clf
end

%% 5. 2 gamma - +
for i = nVox_distribution(4)+1:nVox_distribution(5)

    amplitudes = [-3:0.4:0.1]; % never 0
    widths1 = [2:7];
    peaks1 = [2:7];

    widths2 = [3:9];
    peaks2 = [6:12];
    ratios1 = [-3:0.1:-0.5];

    A = amplitudes(randperm(length(amplitudes),1));
    peak1 = peaks1(randperm(length(peaks1),1));
    fwhm1 = widths1(randperm(length(widths1),1));
    peak2 = peaks2(randperm(length(peaks2),1));
    fwhm2 = widths2(randperm(length(widths2),1));
    ratio = ratios1(randperm(length(ratios1),1));

    for x = 0:18
        simulated_data(i,x+1) = A * ((((x/peak1)^((8*log10(2)) * (peak1^2/fwhm1^2))) * exp(-((x-peak1)/((fwhm1^2) / ((8*log10(2)) * peak1))))) + (ratio * (((x/peak2)^((8*log10(2)) * (peak2^2/fwhm2^2))) * exp(-((x-peak2)/((fwhm2^2) / ((8*log10(2)) * peak2)))))));
    end

    figure(1);
    plot(0:18,simulated_data(i,:));

    % adding noise
    for reps = 1:nReps
        for x = 0:1
            simulated_data_all_reps(reps,i,x+1) = simulated_data(i,x+1)+randn*std_noise_t1_2;
        end
        for x = 2:18
            simulated_data_all_reps(reps,i,x+1) = simulated_data(i,x+1)+randn*std_noise_t3_end;
        end
        %plot(0:18, simulated_data_all_reps(reps,i,:),'o');
    end
    hold on;
    plot(0:18,squeeze(mean(simulated_data_all_reps(:,i,:))));

    pause(0.1); clf
end

%% 6. 2 gamma - -
for i = nVox_distribution(5)+1:nVox_distribution(6)

    amplitudes = [-3:0.4:0.1]; % never 0
    widths1 = [2:7];
    peaks1 = [2:7];

    widths2 = [3:9];
    peaks2 = [9:18];
    ratios1 = [0.1:0.1:3];

    A = amplitudes(randperm(length(amplitudes),1));
    peak1 = peaks1(randperm(length(peaks1),1));
    fwhm1 = widths1(randperm(length(widths1),1));
    peak2 = peaks2(randperm(length(peaks2),1));
    fwhm2 = widths2(randperm(length(widths2),1));
    ratio = ratios1(randperm(length(ratios1),1));

    for x = 0:18
        simulated_data(i,x+1) = A * ((((x/peak1)^((8*log10(2)) * (peak1^2/fwhm1^2))) * exp(-((x-peak1)/((fwhm1^2) / ((8*log10(2)) * peak1))))) + (ratio * (((x/peak2)^((8*log10(2)) * (peak2^2/fwhm2^2))) * exp(-((x-peak2)/((fwhm2^2) / ((8*log10(2)) * peak2)))))));
    end

    figure(1);
    plot(0:18,simulated_data(i,:));

    % adding noise
    for reps = 1:nReps
        for x = 0:1
            simulated_data_all_reps(reps,i,x+1) = simulated_data(i,x+1)+randn*std_noise_t1_2;
        end
        for x = 2:18
            simulated_data_all_reps(reps,i,x+1) = simulated_data(i,x+1)+randn*std_noise_t3_end;
        end
        %plot(0:18, simulated_data_all_reps(reps,i,:),'o');
    end
    hold on;
    plot(0:18,squeeze(mean(simulated_data_all_reps(:,i,:))));

%     pause(0.1); clf
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 7. 3 gamma + - + (early)
for i = nVox_distribution(6)+1:nVox_distribution(7)

    amplitudes = [0.1:0.1:3]; % never 0
    widths1 = [3:6];
    peaks1 = [2:6];

    widths2 = [1:5];
    peaks2 = [7:13];
    ratios1 = [-1:0.1:-0.1];

    widths3 = [2:4];
    peaks3 = [14:18];
    ratios2 = [0.1:0.1:1];

    A = amplitudes(randperm(length(amplitudes),1));
    peak1 = peaks1(randperm(length(peaks1),1));
    fwhm1 = widths1(randperm(length(widths1),1));
    peak2 = peaks2(randperm(length(peaks2),1));
    fwhm2 = widths2(randperm(length(widths2),1));
    ratio1 = ratios1(randperm(length(ratios1),1));
    peak3 = peaks3(randperm(length(peaks3),1));
    fwhm3 = widths3(randperm(length(widths3),1));
    ratio2 = ratios2(randperm(length(ratios2),1));


    for x = 0:18
        simulated_data(i,x+1) = A*((((x/peak1)^((8*log10(2))*(peak1^2/fwhm1^2)))*exp(-((x-peak1)/((fwhm1^2)/((8*log10(2))*peak1)))))+(ratio1*(((x/peak2)^((8*log10(2))*(peak2^2/fwhm2^2)))*exp(-((x-peak2)/((fwhm2^2)/((8*log10(2))*peak2))))))+(ratio2*(((x/peak3)^((8*log10(2))*(peak3^2/fwhm3^2)))*exp(-((x-peak3)/((fwhm3^2)/((8*log10(2))*peak3)))))));
    end

    figure(1);
    plot(0:18,simulated_data(i,:));

    % adding noise
    for reps = 1:nReps
        for x = 0:1
            simulated_data_all_reps(reps,i,x+1) = simulated_data(i,x+1)+randn*std_noise_t1_2;
        end
        for x = 2:18
            simulated_data_all_reps(reps,i,x+1) = simulated_data(i,x+1)+randn*std_noise_t3_end;
        end
        %plot(0:18, simulated_data_all_reps(reps,i,:),'o');
    end
    hold on;
    plot(0:18,squeeze(mean(simulated_data_all_reps(:,i,:))));

%     pause; clf
end

%% 8. 3 gamma + - + (delayed)
for i = nVox_distribution(7)+1:nVox_distribution(8)

    amplitudes = [0.1:0.1:3]; % never 0
    widths1 = [3:6];
    peaks1 = [3:9];

    widths2 = [1:5];
    peaks2 = [10:14];
    ratios1 = [-1:0.1:-0.1];

    widths3 = [2:4];
    peaks3 = [15:18];
    ratios2 = [0.1:0.1:1];

    A = amplitudes(randperm(length(amplitudes),1));
    peak1 = peaks1(randperm(length(peaks1),1));
    fwhm1 = widths1(randperm(length(widths1),1));
    peak2 = peaks2(randperm(length(peaks2),1));
    fwhm2 = widths2(randperm(length(widths2),1));
    ratio1 = ratios1(randperm(length(ratios1),1));
    peak3 = peaks3(randperm(length(peaks3),1));
    fwhm3 = widths3(randperm(length(widths3),1));
    ratio2 = ratios2(randperm(length(ratios2),1));


    for x = 0:18
        simulated_data(i,x+1) = A*((((x/peak1)^((8*log10(2))*(peak1^2/fwhm1^2)))*exp(-((x-peak1)/((fwhm1^2)/((8*log10(2))*peak1)))))+(ratio1*(((x/peak2)^((8*log10(2))*(peak2^2/fwhm2^2)))*exp(-((x-peak2)/((fwhm2^2)/((8*log10(2))*peak2))))))+(ratio2*(((x/peak3)^((8*log10(2))*(peak3^2/fwhm3^2)))*exp(-((x-peak3)/((fwhm3^2)/((8*log10(2))*peak3)))))));
    end

    figure(1);
    plot(0:18,simulated_data(i,:));

    % adding noise
    for reps = 1:nReps
        for x = 0:1
            simulated_data_all_reps(reps,i,x+1) = simulated_data(i,x+1)+randn*std_noise_t1_2;
        end
        for x = 2:18
            simulated_data_all_reps(reps,i,x+1) = simulated_data(i,x+1)+randn*std_noise_t3_end;
        end
        %plot(0:18, simulated_data_all_reps(reps,i,:),'o');
    end
    hold on;
    plot(0:18,squeeze(mean(simulated_data_all_reps(:,i,:))));

%     pause; clf
end

%% 9. 3 gamma - + +(-) 
for i = nVox_distribution(8)+1:nVox_distribution(9)

    amplitudes = [-3:0.1:-0.1]; % never 0
    widths1 = [2:4];
    peaks1 = [3:5];

    widths2 = [1:6];
    peaks2 = [6:10];
    ratios1 = [-3:0.1:-0.1];

    widths3 = [2:10];
    peaks3 = [8:18];
    ratios2 = [-1:0.1:1];

    A = amplitudes(randperm(length(amplitudes),1));
    peak1 = peaks1(randperm(length(peaks1),1));
    fwhm1 = widths1(randperm(length(widths1),1));
    peak2 = peaks2(randperm(length(peaks2),1));
    fwhm2 = widths2(randperm(length(widths2),1));
    ratio1 = ratios1(randperm(length(ratios1),1));
    peak3 = peaks3(randperm(length(peaks3),1));
    fwhm3 = widths3(randperm(length(widths3),1));
    ratio2 = ratios2(randperm(length(ratios2),1));


    for x = 0:18
        simulated_data(i,x+1) = A*((((x/peak1)^((8*log10(2))*(peak1^2/fwhm1^2)))*exp(-((x-peak1)/((fwhm1^2)/((8*log10(2))*peak1)))))+(ratio1*(((x/peak2)^((8*log10(2))*(peak2^2/fwhm2^2)))*exp(-((x-peak2)/((fwhm2^2)/((8*log10(2))*peak2))))))+(ratio2*(((x/peak3)^((8*log10(2))*(peak3^2/fwhm3^2)))*exp(-((x-peak3)/((fwhm3^2)/((8*log10(2))*peak3)))))));
    end

    figure(1);
    plot(0:18,simulated_data(i,:));

    % adding noise
    for reps = 1:nReps
        for x = 0:1
            simulated_data_all_reps(reps,i,x+1) = simulated_data(i,x+1)+randn*std_noise_t1_2;
        end
        for x = 2:18
            simulated_data_all_reps(reps,i,x+1) = simulated_data(i,x+1)+randn*std_noise_t3_end;
        end
        %plot(0:18, simulated_data_all_reps(reps,i,:),'o');
    end
    hold on;
    plot(0:18,squeeze(mean(simulated_data_all_reps(:,i,:))));

%     pause(0.1); clf
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 10. 3 gamma - + +(-) (initial dip)
for i = nVox_distribution(9)+1:nVox

    amplitudes = [-3:0.1:-0.1]; % never 0
    widths1 = [0.5:2];
    peaks1 = [0.5:3];

    widths2 = [2:4];
    peaks2 = [4:7];
    ratios1 = [-3:0.1:-0.1];

    widths3 = [3:7];
    peaks3 = [8:18];
    ratios2 = [-1:0.1:1];

    A = amplitudes(randperm(length(amplitudes),1));
    peak1 = peaks1(randperm(length(peaks1),1));
    fwhm1 = widths1(randperm(length(widths1),1));
    peak2 = peaks2(randperm(length(peaks2),1));
    fwhm2 = widths2(randperm(length(widths2),1));
    ratio1 = ratios1(randperm(length(ratios1),1));
    peak3 = peaks3(randperm(length(peaks3),1));
    fwhm3 = widths3(randperm(length(widths3),1));
    ratio2 = ratios2(randperm(length(ratios2),1));


    for x = 0:18
        simulated_data(i,x+1) = A*((((x/peak1)^((8*log10(2))*(peak1^2/fwhm1^2)))*exp(-((x-peak1)/((fwhm1^2)/((8*log10(2))*peak1)))))+(ratio1*(((x/peak2)^((8*log10(2))*(peak2^2/fwhm2^2)))*exp(-((x-peak2)/((fwhm2^2)/((8*log10(2))*peak2))))))+(ratio2*(((x/peak3)^((8*log10(2))*(peak3^2/fwhm3^2)))*exp(-((x-peak3)/((fwhm3^2)/((8*log10(2))*peak3)))))));
    end

    figure(1);
    plot(0:18,simulated_data(i,:));

    % adding noise
    for reps = 1:nReps
        for x = 0:1
            simulated_data_all_reps(reps,i,x+1) = simulated_data(i,x+1)+randn*std_noise_t1_2;
        end
        for x = 2:18
            simulated_data_all_reps(reps,i,x+1) = simulated_data(i,x+1)+randn*std_noise_t3_end;
        end
        %plot(0:18, simulated_data_all_reps(reps,i,:),'o');
    end
    hold on;
    plot(0:18,squeeze(mean(simulated_data_all_reps(:,i,:))));

%     pause(0.1); clf
end


% save(outfile,'simulated_data_all_reps');