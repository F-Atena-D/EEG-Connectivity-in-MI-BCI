
% Script Name: PLV3.m
% Author: Fatemeh Delavari (Atena)
% Date: 2024-03-03
% Version: 1.0
% Description: This script extracts PLV features from EEG data during right and left 
% motor imagery tasks (from three runs: R03, R07, R11) and classifies them using SVM.

%% Initialization
clear; clc;
tic;

%% Parameters
SN = 1;  % Subject number (change for batch processing)
fs = 160;  % Sampling frequency
nTimePoints = fs;  % 1-second segments
nch = 64;  % Number of EEG channels
ntr = 63;  % Total trials (3 per task per run × 3 runs × 7 trials per label)

%% Load and Parse EEG Runs
baseDir = 'C:\Users\Atena\Downloads\eeg-motor-movementimagery-dataset-1.0.0\files\';
runs = {'R03', 'R07', 'R11'};

PL = []; PR = [];

for r = 1:length(runs)
    runID = runs{r};
    subDir = sprintf('S%03d', SN);
    edfFile = fullfile(baseDir, subDir, sprintf('S%03d%s.edf', SN, runID));

    % Read EEG and annotations
    [data, annotations] = edfread(edfFile);

    % Identify motor imagery events: T1 = Left, T2 = Right
    idxL = find(annotations.Annotations == "T1");
    idxR = find(annotations.Annotations == "T2");

    onsetL = ceil(annotations.Onset(idxL));
    onsetR = ceil(annotations.Onset(idxR));

    L_times = [onsetL; onsetL + seconds(1); onsetL + seconds(2)];
    R_times = [onsetR; onsetR + seconds(1); onsetR + seconds(2)];

    L_data = data(L_times, :);
    R_data = data(R_times, :);

    % --- Convert timetable to 3D array ---
    % Each row = trial, each column = time, third dim = channels
    [nRows, nCols] = size(L_data);
    PLtemp = zeros(nRows, nTimePoints, nCols);
    PRtemp = zeros(nRows, nTimePoints, nCols);

    for row = 1:nRows
        for ch = 1:nCols
            PLtemp(row, :, ch) = L_data{row, ch}{1};
            PRtemp(row, :, ch) = R_data{row, ch}{1};
        end
    end

    PL = [PL; PLtemp];
    PR = [PR; PRtemp];
end

%% Compute PLV Features
for tr = 1:ntr
    % Left trials
    for ch = 1:nch
        signal = squeeze(PL(tr, :, ch));
        phase(:, ch) = angle(hilbert(signal));
    end
    for i = 1:nch
        for j = 1:nch
            dphi(:, i, j) = phase(:, i) - phase(:, j);
        end
    end
    plvtL(SN, tr, :, :) = abs(mean(exp(1i * dphi), 1));

    % Right trials
    for ch = 1:nch
        signal = squeeze(PR(tr, :, ch));
        phase(:, ch) = angle(hilbert(signal));
    end
    for i = 1:nch
        for j = 1:nch
            dphi(:, i, j) = phase(:, i) - phase(:, j);
        end
    end
    plvtR(SN, tr, :, :) = abs(mean(exp(1i * dphi), 1));
end

%% Prepare Dataset
XR = reshape(plvtR(SN, :, :, :), ntr, []);  % Right trials
XL = reshape(plvtL(SN, :, :, :), ntr, []);  % Left trials

Xdata = [XR; XL];                          % Combined features
Ydata = [ones(ntr, 1); 2 * ones(ntr, 1)];  % Labels: 1 = Right, 2 = Left

%% Classification using SVM with 5-fold Cross-Validation
cv = cvpartition(2 * ntr, 'KFold', 5);

for i = 1:cv.NumTestSets
    train_idx = cv.training(i);
    test_idx = cv.test(i);

    train_data = Xdata(train_idx, :);
    test_data = Xdata(test_idx, :);
    train_label = Ydata(train_idx);
    test_label = Ydata(test_idx);

    % Train linear SVM
    svmModel = fitcsvm(train_data, train_label, 'KernelFunction', 'linear');

    % Predict
    Y_pred = predict(svmModel, test_data);

    % Accuracy
    acCVc(i, SN) = 100 * sum(Y_pred == test_label) / length(test_label);
end

%% Evaluation
mAcc = mean(acCVc, 'all');        % Overall mean accuracy
sAcc = std(acCVc, [], 'all');     % Overall std deviation

mAcc1 = mean(acCVc, 1);           % Per subject mean
sAcc1 = std(acCVc, [], 1);        % Per subject std

%% Save Results
save('plv3ma.mat', 'mAcc1', 'sAcc1', 'acCVc');

toc;
