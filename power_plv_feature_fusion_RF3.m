
% Script Name: power_plv_fusion_RF3.m
% Author: Fatemeh Delavari (Atena)
% Date: 2024-03-04
% Version: 1.0
% Description: This script performs k-fold cross-validated classification of
% right and left hand motor imagery using a combination of power and PLV features.
% Feature selection is performed using Random Forest importance scores.

%% Initialization
clear; clc;

%% Parameters
ntr = 21;                          % Trials per class (Right/Left)
nch = 64;                          % Number of EEG channels
fs = 160;                          % Sampling frequency
num_samples = 2 * ntr;             % Total trials (Right + Left)
n = 5;                             % Number of folds for cross-validation
numTrees = 100;                    % Number of trees in Random Forest

cv = cvpartition(num_samples, 'KFold', n);  % Cross-validation partition

%% Load Data
load("powerLR3.mat", "RP_L3", "RP_R3");     % Power features
load("PLV3.mat", "plvL3", "plvR3");         % PLV connectivity features
load('pi3.mat');

%% Classification Loop
for num_feat = 2:10                          % Vary number of selected features
    tic
    for d = 1:109                            % Loop through subjects
        if pi(d)<0.05
            XR = squeeze(RP_R3(d, :, :));
            XL = squeeze(RP_L3(d, :, :));

            % Skip subjects with NaNs
            if ~any(isnan(XR), 'all') && ~any(isnan(XL), 'all')

                % Prepare power features
                Xpower = [XR; XL];
                Ydata = [ones(ntr, 1); 2 * ones(ntr, 1)];  % Labels

                % Prepare PLV features
                XR2 = reshape(plvR3(d, :, :, :), ntr, []);
                XL2 = reshape(plvL3(d, :, :, :), ntr, []);
                Xplv = [XR2; XL2];

                % Normalize power and PLV features per trial
                Xpower = normalize(Xpower, 2);
                Xplv = normalize(Xplv, 2);

                % Fuse features
                Xdata = [Xpower, Xplv];

                for i = 1:n  % Cross-validation folds
                    train_idx = cv.training(i);
                    test_idx = cv.test(i);

                    % Select training and testing sets
                    train_data = Xdata(train_idx, :);
                    test_data = Xdata(test_idx, :);
                    train_label = Ydata(train_idx);
                    test_label = Ydata(test_idx);

                    % Initial RF to rank feature importance
                    rf_temp = TreeBagger(numTrees, train_data, train_label, ...
                        'Method', 'classification', ...
                        'OOBPredictorImportance', 'on');
                    feature_importance = rf_temp.OOBPermutedVarDeltaError;
                    [~, sorted_idx] = sort(feature_importance, 'descend');
                    top_features = sorted_idx(1:num_feat);

                    % Train RF on top-k features
                    rf_final = TreeBagger(numTrees, train_data(:, top_features), train_label, ...
                        'Method', 'classification', ...
                        'OOBPredictorImportance', 'on');
                    [predictedLabels, ~] = predict(rf_final, test_data(:, top_features));
                    Y_pred = str2double(predictedLabels);

                    % Compute accuracy
                    acCVf(d, num_feat, i) = 100 * sum(Y_pred == test_label) / length(test_label);
                end
            end
        end
        toc
    end
end


%% Compute Performance Metrics
% Fold-averaged accuracy: [subjects × features]
acCV2 = mean(acCVf, 3);

% Global accuracy
mAcc = mean(acCV2, 'all');
sAcc = std(acCV2, [], 'all');

% Per-subject accuracy
mAcc1 = mean(acCVf, 3);
sAcc1 = std(acCVf, [], 3);

% Per-feature accuracy
mAcc2 = mean(mAcc1, 1);
sAcc2 = std(mAcc1, [], 1);

%% Save Results
save('powerplvfusionCV3.mat', 'acCVf', 'acCV2', ...
    'mAcc', 'sAcc', 'mAcc1', 'sAcc1', 'mAcc2', 'sAcc2');
