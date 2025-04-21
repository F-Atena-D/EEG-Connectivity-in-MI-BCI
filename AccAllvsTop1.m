
% Script Name: AccAllvsTop1.m
% Author: Fatemeh Delavari (Atena)
% Date: 2024-03-03
% Version: 1.0
% Description: This script compares classification accuracy using all features 
% versus top 1% important features based on Random Forest importance scores

%% Initialization
clear; clc;

%% Load Data
load('RFp1.mat');                   % acc: classification accuracy using all features (per subject)
load('acc1p.mat');                 % acc1p: permuted/alternative accuracies (optional)
load('acc_perct1.mat', 'acCV');   % acCV: accuracy matrix [subjects × features × folds]

%% Process Accuracy Data
acCVs = squeeze(mean(acCV, 2));    % Mean accuracy over folds → [subjects × num_features]
macc = max(acCVs, [], 2);          % Best accuracy per subject (over features)

%% Identify Number of Top Features Leading to Max Accuracy
for i = 1:9
    pl(i) = max(find(acCVs(i, :) == macc(i)));  % Index of last occurrence of max accuracy
end

%% Analyze Percentage of Features Required
feature_percent = 100 - pl;
mean_features_used = mean(feature_percent);     % Mean percentage of features used
std_features_used = std(feature_percent);       % Std deviation

%% Compute Accuracy Drop When Using Only Top Features
diffAcc = 100 * acc - macc;                     % Accuracy drop per subject
ma = mean(diffAcc);                             % Mean drop
sa = std(diffAcc);                              % Std drop

%% Prepare Data for Plotting
% Rows = subjects, Columns = conditions: [All Features, Top-k Features]
data = [100 * acc'; macc']';                    % [9 × 2]

%% Visualization (Violin Plot)
figure;
violin(data);
ylabel('Accuracy (%)', 'FontSize', 18, 'FontName', 'Times New Roman');
xticks([1 2]);
xticklabels({'All Conn.', 'Top Conn.'});
set(gca, 'FontName', 'Times New Roman');
grid on;

%% Statistical Comparison (Paired t-test)
[h, p] = ttest(data(:, 1), data(:, 2));         % H = 1 if significant, p = p-value

% Optional display:
fprintf('\nPaired t-test result:\n');
fprintf('  H = %d (1 = significant)\n', h);
fprintf('  p = %.4f\n', p);
fprintf('Mean accuracy drop: %.2f ± %.2f\n', ma, sa);
fprintf('Mean features used (%%): %.2f ± %.2f\n', mean_features_used, std_features_used);
