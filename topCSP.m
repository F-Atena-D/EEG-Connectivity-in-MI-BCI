
% Script Name: TopCSP
% Author: Fatemeh Delavari
% Version: 1.1
% Description: Classification using top-N CSP features (varying N from 2 to 22) across 9 subjects.

clear; clc; tic;

load('cspLR1.mat');  % Load precomputed CSP features
numSubjects = 9;
n = 5; % Number of folds
numTrees = 100;
numFeaturesRange = 2:22;

% Accuracy array (fold x subject x numFeatures)
acCVc = zeros(n, numSubjects, length(numFeaturesRange));

for nf = numFeaturesRange
    numfeat = nf;
    for d = 1:numSubjects
        for fold = 1:n
            % Get training data
            X_R_train = cspFeaturesRtrd{fold, d}';
            X_L_train = cspFeaturesLtrd{fold, d}';
            X_train = [X_R_train; X_L_train];
            Y_train = [ones(size(X_R_train, 1), 1); 2*ones(size(X_L_train, 1), 1)];

            % Train full feature model for importance
            rfModel_temp = TreeBagger(numTrees, X_train, Y_train, 'Method', 'classification', 'OOBPredictorImportance', 'on');
            feature_importance = rfModel_temp.OOBPermutedVarDeltaError;
            [~, sorted_idx] = sort(feature_importance, 'descend');

            % Select top N features
            top_features = sorted_idx(1:numfeat);

            % Retrain model with top features
            rfTop = TreeBagger(numTrees, X_train(:, top_features), Y_train, 'Method', 'classification');

            % Get test data
            X_R_test = cspFeaturesRtsd{fold, d}';
            X_L_test = cspFeaturesLtsd{fold, d}';
            X_test = [X_R_test; X_L_test];
            Y_test = [ones(size(X_R_test, 1), 1); 2*ones(size(X_L_test, 1), 1)];

            % Predict
            [Y_pred_str, ~] = predict(rfTop, X_test(:, top_features));
            Y_pred = str2double(Y_pred_str);

            % Accuracy
            acCVc(fold, d, numfeat) = 100 * sum(Y_pred == Y_test) / length(Y_test);
        end
    end
end
toc

%% Summary Statistics
mAcc = mean(acCVc, 'all');
sAcc = std(acCVc, 0, 'all');

mAcc1 = mean(acCVc, 1); % mean over folds
sAcc1 = std(acCVc, 0, 1); % std over folds

%% Subject-wise Max Accuracy per Feature Count
acC = mean(acCVc, 1); % average over folds
acC2 = squeeze(acC); % shape: subjects x numFeatures

for d = 1:numSubjects
    mp(d) = max(find(acC2(d, :) == max(acC2(d, :), [], 'all')));
end

mpp = (mp / 22) * 100; % normalized feature position
mmpp = mean(mpp);
smpp = std(mpp);

for d = 1:numSubjects
    macC(d) = acC2(d, mp(d)); % max accuracy per subject
end

mmac = mean(macC);
smac = std(macC);

% Accuracy using all 22 features
for d = 1:numSubjects
    mac(d) = mAcc1(1, d, 22);
end

md = mean(macC - mac);
sd = std(macC - mac);
