
% Script Name: topCSP3
% Author: Fatemeh Delavari 
% Version: 1.1
% Description: Classify LH/RH EEG from Physionet using top-N CSP features (2:22)

clear; clc; tic;

load("cspLR3.mat");  % Precomputed CSP features
numSubjects = 109;
numFolds = 5;
numFeaturesRange = 2:22;
numTrees = 100;
numTrials = 21;
load('pi3.mat');

%% Classification Loop
% Accuracy matrix: folds x subjects x number of features
acCVc = zeros(numFolds, numSubjects, length(numFeaturesRange));

for nf = numFeaturesRange
    numfeat = nf;
    for d = 1:numSubjects
        if pi(d)<0.05
        cv = cvpartition(numTrials, 'KFold', numFolds);
        for fold = 1:numFolds
            % Training set
            X_R_train = cspFeaturesRtrd{fold, d}';
            X_L_train = cspFeaturesLtrd{fold, d}';
            X_train = [X_R_train; X_L_train];
            Y_train = [ones(size(X_R_train, 1), 1); 2*ones(size(X_L_train, 1), 1)];

            if ~any(isnan(X_train), 'all')

            % Get feature importance
            rfModel_temp = TreeBagger(numTrees, X_train, Y_train, ...
                'Method', 'classification', 'OOBPredictorImportance', 'on');
            feature_importance = rfModel_temp.OOBPermutedVarDeltaError;
            [~, sorted_idx] = sort(feature_importance, 'descend');
            top_features = sorted_idx(1:numfeat);

            % Retrain using only top features
            rfTop = TreeBagger(numTrees, X_train(:, top_features), Y_train, 'Method', 'classification');

            % Test set
            X_R_test = cspFeaturesRtsd{fold, d}';
            X_L_test = cspFeaturesLtsd{fold, d}';
            X_test = [X_R_test; X_L_test];
            Y_test = [ones(size(X_R_test, 1), 1); 2*ones(size(X_L_test, 1), 1)];

            % Prediction
            [Y_pred_str, ~] = predict(rfTop, X_test(:, top_features));
            Y_pred = str2double(Y_pred_str);

            % Accuracy
            acCVc(fold, d, numfeat) = 100 * sum(Y_pred == Y_test) / length(Y_test);
            end
            end
        end
    end
end
toc

%% Aggregate Results
mAcc = mean(acCVc, 'all');
sAcc = std(acCVc, 0, 'all');
mAcc1 = mean(acCVc, 1);
sAcc1 = std(acCVc, 0, 1);

%% Max Accuracy Feature Count per Subject
acC = mean(acCVc, 1); % average over folds
acC2 = squeeze(acC); % subjects x features

for d = 1:numSubjects
    mp(d) = max(find(acC2(d, :) == max(acC2(d, :), [], 'all')));
end

mpp = (mp / 22) * 100; % relative feature positions
mmpp = mean(mpp);
smpp = std(mpp);

for d = 1:numSubjects
    macC(d) = acC2(d, mp(d)); % max accuracy per subject
end

mmac = mean(macC);
smac = std(macC);

% Accuracy using all 22 CSP features
for d = 1:numSubjects
    mac(d) = mAcc1(1, d, 22);
end

% Gain from feature selection
md = mean(macC - mac);
sd = std(macC - mac);
