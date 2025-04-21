
% Script Name: power_plv_fusion_RF.m
% Author: Fatemeh Delavari (Atena)
% Date: 2024-03-04
% Version: 1.0
% Description: This script performs k-fold cross-validated classification of 
% right and left-hand motor imagery using fused power and PLV features.
% Random Forest is used for both classification and top-k feature selection.

%% Initialization
clear; clc;
tic;

%% Parameters
ntr = 72;                        % Number of trials per condition
nch = 22;                        % Number of EEG channels
num_samples = 2 * ntr;           % Total samples (Right + Left)
n = 5;                           % Number of CV folds
numTrees = 100;                 % Number of trees in Random Forest

cv = cvpartition(num_samples, 'KFold', n);  % Stratified cross-validation

%% Load Data
load("powerLR1.mat", "RP_L1", "RP_R1");       % Power features
load("PLV1.mat", "plvL1", "plvR1");           % PLV features

%% Classification and Feature Selection
for num_feat = 2:20                            % Test top-k features from 1 to 22
    for d = 1:9                                % Loop over 9 subjects

        % Extract and reshape power features
        XR1 = squeeze(RP_R1(d, :, :));         % Power - Right hand
        XL1 = squeeze(RP_L1(d, :, :));         % Power - Left hand

        % Extract and reshape PLV features
        XR2 = reshape(plvR1(d, :, :, :), ntr, []);
        XL2 = reshape(plvL1(d, :, :, :), ntr, []);

        % Combine features and labels
        Xdata1 = [XR1; XL1];                   % Power
        Xdata2 = [XR2; XL2];                   % PLV
        Ydata = [ones(ntr, 1); 2 * ones(ntr, 1)];  % 1 = Right, 2 = Left

        % Normalize each trial independently
        Xdata1 = normalize(Xdata1, 2);
        Xdata2 = normalize(Xdata2, 2);

        % Fuse features
        Xdata12 = [Xdata1, Xdata2];

        for i = 1:n  % Cross-validation loop
            train_idx = cv.training(i);
            test_idx = cv.test(i);

            % Train a temporary RF to get feature importance
            rf_temp = TreeBagger(numTrees, Xdata12, Ydata, ...
                                 'Method', 'classification', ...
                                 'OOBPredictorImportance', 'on');
            feature_importance = rf_temp.OOBPermutedVarDeltaError;
            [~, sorted_idx] = sort(feature_importance, 'descend');
            top_features = sorted_idx(1:num_feat);

            % Select top-k features
            train_data = Xdata12(train_idx, top_features);
            test_data = Xdata12(test_idx, top_features);
            train_label = Ydata(train_idx);
            test_label = Ydata(test_idx);

            % Train final RF classifier
            rf_final = TreeBagger(numTrees, train_data, train_label, ...
                                  'Method', 'classification', ...
                                  'OOBPredictorImportance', 'on');
            [predictedLabels, ~] = predict(rf_final, test_data);
            Y_pred = str2double(predictedLabels);

            % Compute accuracy
            acCVf(d, num_feat, i) = 100 * sum(Y_pred == test_label) / length(test_label);
        end
    end
end
toc;

%% Compute Mean Accuracy Across Folds
acCV = mean(acCVf, 3);                 % [subjects × features]

%% Global Accuracy Stats
mAcc = mean(acCV, 'all');              % Mean over all subjects and features
sAcc = std(acCV, [], 'all');           % Std deviation over all

%% Per-Subject Accuracy Stats
mAcc1 = mean(acCVf, 3);                 % Mean over folds → [subjects × features]
sAcc1 = std(acCVf, [], 3);              % Std over folds → [subjects × features]

%% Per-Feature Accuracy Stats
mAcc2 = mean(mAcc1, 1);                 % Mean across subjects (per feature count)
sAcc2 = std(mAcc1, [], 1);              % Std across subjects (per feature count)

%% Save Results
save('powerplvfusionCV.mat', 'acCVf', 'acCV', ...
     'mAcc', 'sAcc', 'mAcc1', 'sAcc1', 'mAcc2', 'sAcc2');
