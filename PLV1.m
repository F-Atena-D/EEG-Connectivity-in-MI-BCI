
% Script Name: PLV1.m
% Author: Fatemeh Delavari (Atena)
% Date: 2024-03-03
% Version: 1.0
% Description: This script computes PLV-based features for EEG trials during 
% right and left-hand motor imagery, and classifies them using Random Forest with K-Fold cross-validation.

%% Initialization
clear; clc;
tic;

%% Parameters
nch = 22;                % Number of EEG channels
ntr = 72;                % Number of trials per class
fs = 250;                % Sampling rate (Hz)
epochDuration = 3;       % Duration of each epoch (seconds)
epochOverlap = 0;        % Overlap between epochs (seconds)
epochSamples = round(epochDuration * fs);
overlapSamples = round(epochOverlap * fs);
num_folds = 5;           % Number of folds for cross-validation
numTrees = 100;          % Number of trees for Random Forest

%% Process Subject Data
for SN = 1 % Loop for subject; change 1:9 to include more
    d = SN;
    path = 'C:\BCI\Dataset2Seg\';

    % Load pre-segmented data for Right and Left motor imagery
    load([path, sprintf('nR%dT.mat', d)]);
    load([path, sprintf('nL%dT.mat', d)]);

    eegDataR = double(RDCT');  % Right-hand EEG data [channels x samples]
    eegDataL = double(LDCT');  % Left-hand EEG data [channels x samples]

    %% Epoching EEG Data
    for ch = 1:nch
        % Left hand
        epochs_L = buffer(eegDataL(ch, :), epochSamples, overlapSamples, 'nodelay');
        PL(:, :, ch) = epochs_L(:, 1:ntr)';

        % Right hand
        epochs_R = buffer(eegDataR(ch, :), epochSamples, overlapSamples, 'nodelay');
        PR(:, :, ch) = epochs_R(:, 1:ntr)';
    end

    %% Compute PLV for Each Trial
    for tr = 1:ntr
        % --- Left Hand ---
        for ch = 1:nch
            y = hilbert(squeeze(PL(tr, :, ch)));  % Analytic signal
            phase(:, ch) = angle(y);              % Phase
        end
        for i = 1:nch
            for j = 1:nch
                dphi(:, i, j) = phase(:, i) - phase(:, j);
            end
        end
        plvtL(d, tr, :, :) = abs(mean(exp(1i * dphi), 1));  % PLV matrix

        % --- Right Hand ---
        for ch = 1:nch
            y = hilbert(squeeze(PR(tr, :, ch)));
            phase(:, ch) = angle(y);
        end
        for i = 1:nch
            for j = 1:nch
                dphi(:, i, j) = phase(:, i) - phase(:, j);
            end
        end
        plvtR(d, tr, :, :) = abs(mean(exp(1i * dphi), 1));
    end

    %% Reshape Features
    XR = reshape(plvtR(d, :, :, :), ntr, []);  % Right hand trials
    XL = reshape(plvtL(d, :, :, :), ntr, []);  % Left hand trials
    Xdata = [XR; XL];                          % Concatenate
    Ydata = [ones(ntr, 1); 2 * ones(ntr, 1)];  % 1 = Right, 2 = Left

    %% Classification with Cross-Validation
    num_samples = 2 * ntr;
    cv = cvpartition(num_samples, 'KFold', num_folds);

    for i = 1:num_folds
        train_idx = cv.training(i);
        test_idx = cv.test(i);

        train_data = Xdata(train_idx, :);
        test_data = Xdata(test_idx, :);
        train_label = Ydata(train_idx);
        test_label = Ydata(test_idx);

        % Train Random Forest
        rfModel = TreeBagger(numTrees, train_data, train_label, ...
                             'Method', 'classification', ...
                             'OOBPredictorImportance', 'on');
        feature_importance = rfModel.OOBPermutedVarDeltaError;
        [~, sorted_idx] = sort(feature_importance, 'descend');

        % Predict
        [predictedLabels, ~] = predict(rfModel, test_data);
        Y_pred = str2double(predictedLabels);

        % Accuracy
        acCVc(i, SN) = 100 * sum(Y_pred == test_label) / length(test_label);
    end
end
toc;

%% Summary Statistics
mAcc = mean(acCVc, 'all');        % Mean accuracy over folds and subject(s)
sAcc = std(acCVc, [], 'all');     % Standard deviation
mAcc1 = mean(acCVc, 1);           % Mean per subject
sAcc1 = std(acCVc, [], 1);        % Std per subject

%% Save Results
save('plv1mi.mat');

toc;
