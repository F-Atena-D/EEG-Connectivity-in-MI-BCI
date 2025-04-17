% Script Name: power_plv_fusion_RF.m
% Author: Fatemeh Delavari (Atena)
% Date: 2024-03-03
% Version: 1.0
% Description: This script performs k-fold cross-validated classification of 
% right and left hand motor imagery using a combination of power and PLV features.
% Top-k feature selection is performed using Random Forest importance scores.

%% Initialization
clear; clc;
tic;

%% Parameters
nepoch = 72;
nch = 22;
ntr = 72;
num_samples = 2 * ntr;       % Total number of samples (Right + Left)
n = 5;                       % Number of folds for cross-validation
numTrees = 100;              % Number of trees in Random Forest

cv = cvpartition(num_samples, 'KFold', n);  % Create partitioning vector

%% Load Data
load("powerLR1.mat", "RP_L1", "RP_R1");     % Power features
load("PLV1.mat", "plvL1", "plvR1");         % PLV features
load("RFp1.mat");                           % Optional: pre-saved RF model

%% Feature Fusion, Normalization, and Classification
for num_feat = 1:20                         % Vary number of selected features
    for d = 1:9                             % Loop over 9 subjects

        % Extract power and PLV features
        XR1 = squeeze(RP_R1(d, :, :));      % Power - Right hand
        XL1 = squeeze(RP_L1(d, :, :));      % Power - Left hand
        XR2 = reshape(plvR1(d, :, :, :), ntr, []);  % PLV - Right hand
        XL2 = reshape(plvL1(d, :, :, :), ntr, []);  % PLV - Left hand

        % Concatenate data and labels
        Xdata1 = [XR1; XL1];                % Power
        Xdata2 = [XR2; XL2];                % PLV
        Ydata = [ones(ntr, 1); 2 * ones(ntr, 1)];  % Labels

        % Normalize feature sets per trial
        Xdata1 = (Xdata1 - min(Xdata1, [], 2)) ./ (max(Xdata1, [], 2) - min(Xdata1, [], 2));
        Xdata2 = (Xdata2 - min(Xdata2, [], 2)) ./ (max(Xdata2, [], 2) - min(Xdata2, [], 2));

        % Concatenate power and PLV features
        Xdata12 = [Xdata1, Xdata2];

        for i = 1:n  % Cross-validation folds

            train_idx = cv.training(i);
            test_idx = cv.test(i);

            % Initial model to determine feature importance
            rfModel_temp = TreeBagger(numTrees, Xdata12, Ydata, ...
                                      'Method', 'classification', ...
                                      'OOBPredictorImportance', 'on');
            feature_importance = rfModel_temp.OOBPermutedVarDeltaError;
            [~, sorted_idx] = sort(feature_importance, 'descend');

            top_features = sorted_idx(1:num_feat);

            % Train/test sets with selected features
            train_data12 = Xdata12(train_idx, top_features);
            test_data12 = Xdata12(test_idx, top_features);
            train_label12 = Ydata(train_idx);
            test_label12 = Ydata(test_idx);

            % Final model training
            randomForest = TreeBagger(numTrees, train_data12, train_label12, ...
                                      'Method', 'classification', ...
                                      'OOBPredictorImportance', 'on');
            [predictedLabels, ~] = predict(randomForest, test_data12);
            Y_pred = str2double(predictedLabels);

            % Store accuracy for subject d, feature count, fold i
            acCVf(d, num_feat, i) = 100 * sum(Y_pred == test_label12) / length(test_label12);
        end
    end
end
toc;

%% Compute Mean Across Folds
acCV2 = mean(acCVf, 3);  % Average over folds → shape: [subjects × num_feat]

%% Global Performance Metrics
mAcc = mean(acCV2, "all");        % Mean accuracy across all
sAcc = std(acCV2, [], "all");     % Std deviation across all

%% Per-Subject Accuracy Statistics
mAcc1 = mean(acCV3, 3);           % Mean per subject
sAcc1 = std(acCV3, [], 3);        % Std per subject

%% Per-Feature Accuracy Statistics
mAcc2 = mean(mAcc1, 1);           % Mean across subjects (per feature count)
sAcc2 = std(mAcc1, [], 1);        % Std across subjects (per feature count)

%% Save Results
save('powerplvfusionCV.mat', 'acCVf');
