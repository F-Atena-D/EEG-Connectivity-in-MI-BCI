
% Script Name: Permutation3.m
% Author: Fatemeh Delavari (Atena)
% Date: 2024-03-03
% Version: 1.0
% Description: This script performs permutaion test to see if the
% classification performed using the true labels is significantly better
% than those using fake labels in the second dataset

%% Initialization
clear; clc;

%% Load Data
load('P_acc_si_35.mat');  % acc_p: permutation accuracies [subjects × permutations]
load('RFp3.mat');         % acc: true classification accuracies [subjects × 1]

%% One-Sample T-Test (Left-Tailed) for Each Subject
for i = 1:109
    racc = repmat(acc(i), 100, 1);  % replicate subject's true accuracy
    [h, p, ci, stats] = ttest(acc_p(i, 1:100)', racc, 'Tail', 'left');

    hi(i) = h;   % Hypothesis result (1 = significant)
    pi(i) = p;   % P-value
end

%% Save P-values
save('pi3.mat', 'pi');

%% Count Number of Subjects with Statistically Significant Results
nimpconn = sum(hi, 'all');

%% Optional: Manual T-Test Calculation (Alternative Validation)
for i = 1:109
    data_mean = mean(acc_p(i, :));
    data_std = std(acc_p(i, :));
    n = size(acc_p, 2);
    sem = data_std / sqrt(n);
    
    % Compute t-statistic
    t_stat = (data_mean - acc(i)) / sem;
    df = n - 1;
    
    % One-sided p-value
    pii(i) = tcdf(t_stat, df);
end

%% Compute Mean Permutation Accuracy per Subject
aacc_p = mean(acc_p, 2);  % [109 × 1]
