
% Script Name: Permutation1.m
% Author: Fatemeh Delavari (Atena)
% Date: 2024-03-03
% Version: 1.0
% Description: This script performs permutaion test to see if the
% classification performed using the true labels is significantly better
% than those using fake labels in the first dataset

%% Initialization
clear; clc;

%% Load Data
load('P_acc_si_1_4.mat');  % acc_p: permutation accuracies [subjects × permutations]
load('RFp1.mat');          % acc: true classification accuracies [subjects × 1]

%% Perform One-Sample Left-Tailed T-Test
for i = 1:9
    racc = repmat(acc(i), 100, 1);  % replicate true accuracy

    % Perform left-tailed t-test: H0 = acc_p >= acc
    [h, p, ci, stats] = ttest(acc_p(i, 1:100)', racc, 'Tail', 'left');

    hi(i) = h;   % Hypothesis test result (1 = reject null)
    pi(i) = p;   % P-value
end

%% Save p-values
save('pi.mat', "pi");

%% Optional: Manual T-Test Calculation (Commented)
% for i = 1:9
%     data_mean = mean(acc_p(i, 1:100));
%     data_std = std(acc_p(i, 1:100));
%     n = 100;
%     sem = data_std / sqrt(n);
%     t_stat = (data_mean - acc(i)) / sem;
%     df = n - 1;
%     p = tcdf(t_stat, df);  % One-tailed (left) p-value
%     pii(i) = p;
% end

%% Optional: Mean Permutation Accuracy (Commented)
% aacc_p = mean(acc_p(:, 1:100), 2);
