
% Script Name: AccAllvsTop3.m
% Author: Fatemeh Delavari (Atena)
% Date: 2024-03-03
% Version: 1.0
% Description: This script compares classification accuracy using all features 
% versus top 1% important connections for Dataset 3 (64-channel EEG).
% It performs statistical testing and visualizes the comparison.

%% Initialization
clear; clc;

%% Load Accuracy Data
load('RFp3.mat');                    % acc: accuracy using all features
load('acc3p.mat');                  % acc3p: permutation/randomized accuracies (optional)
load('acc_perct3.mat', 'acCV');    % acCV: accuracy matrix [subjects × features × folds]

%% Compute Mean Accuracy Across Folds and Extract Max per Subject
acCVs = squeeze(mean(acCV, 2));    % Mean over folds → [subjects × features]
macc = max(acCVs, [], 2);          % Max accuracy for each subject over feature counts

%% Identify Number of Top Features Giving Max Accuracy
for i = 1:108
    pl(i) = max(find(acCVs(i, :) == macc(i)));
end

%% Percentage of Top Features Used to Reach Peak Accuracy
feature_percent = 100 - pl;
mean_top_feature_percent = mean(feature_percent);
std_top_feature_percent = std(feature_percent);

%% Filter Valid Subjects (Exclude Empty / Failed Trials)
valid_idx = (macc > 0);
maccV = macc(valid_idx);          % Valid maximum accuracies
accV = acc(valid_idx);            % Corresponding baseline accuracies

%% Accuracy Comparison
diffAcc = 100 * accV - maccV;     % Drop in accuracy with top features
ma = mean(diffAcc);
sa = std(diffAcc);

%% Combine for Plotting
data = [100 * accV'; maccV']';    % [subjects × 2] → All vs Top features

%% Violin Plot
figure;
violin(data);
ylabel('Accuracy (%)', 'FontSize', 18, 'FontName', 'Times New Roman');
xticks([1 2]);
xticklabels({'All Conn.', 'Top Conn.'});
set(gca, 'FontName', 'Times New Roman');
grid on;

%% Paired T-Test: All vs. Top Connections
[h, p] = ttest(data(:, 1), data(:, 2));

%% Display Results
fprintf('\n--- Statistical Comparison (All vs. Top Connections) ---\n');
fprintf('Paired t-test: H = %d (1 = significant), p = %.4f\n', h, p);
fprintf('Mean accuracy drop: %.2f%% ± %.2f%%\n', ma, sa);
fprintf('Mean top connection usage: %.2f%% ± %.2f%%\n', ...
        mean_top_feature_percent, std_top_feature_percent);
