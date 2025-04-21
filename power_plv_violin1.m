
% Script Name: power_plv_violin1.m
% Author: Fatemeh Delavari (Atena)
% Date: 2024-03-03
% Version: 1.0
% Description: Compares relative power and PageRank centrality at channel 18 
% between LH and RH motor imagery for significant subjects (p < 0.01).
% Visualization is done using violin plots. Significance tested via paired t-test.

%% Initialization
clear; clc;

%% Load Relative Power Data
load("powerLR1.mat", "RP_L1", "RP_R1");
load("pi.mat");  % significance mask from earlier stats

%% Extract Relative Power (Channel 18) for Significant Subjects
psR = reshape(RP_R1(pi < 0.01, :, 18), [], 1);  % RH MI
psL = reshape(RP_L1(pi < 0.01, :, 18), [], 1);  % LH MI

%% Plot Relative Power Comparison
figure;
violin([psL, psR], 'facecolor', [0.2 0.6 1; 1 0.4 0.4], 'medc', 'k');
set(gca, 'XTick', [1 2], ...
         'XTickLabel', {'LH MI', 'RH MI'}, ...
         'FontSize', 14, ...
         'FontName', 'Times New Roman', ...
         'FontWeight', 'bold');
ylabel('Relative Power 8-13 Hz (a.u.)', 'FontSize', 18, 'FontName', 'Times New Roman');
title('Mu-Band Relative Power (Channel 18)', 'FontWeight', 'bold');

%% Statistical Test - Power
[h, p1p] = ttest(psL, psR);

%% Load PLV and Compute PageRank Centrality
load('PLV1.mat', "plvR1", "plvL1");

for SN = 1:9
    for tr = 1:72
        % Right-hand MI
        G = graph(squeeze(plvR1(SN, tr, :, :)), 'upper');
        CentR(SN, tr, :) = centrality(G, 'pagerank', 'Importance', G.Edges.Weight);

        % Left-hand MI
        G = graph(squeeze(plvL1(SN, tr, :, :)), 'upper');
        CentL(SN, tr, :) = centrality(G, 'pagerank', 'Importance', G.Edges.Weight);
    end
end

%% Extract PageRank Centrality (Channel 18) for Significant Subjects
plvsR1 = reshape(CentR(pi < 0.01, :, 18), [], 1);  % RH MI
plvsL1 = reshape(CentL(pi < 0.01, :, 18), [], 1);  % LH MI

%% Plot Centrality Comparison
figure;
violin([plvsL1, plvsR1], 'facecolor', [0.2 0.6 1; 1 0.4 0.4], 'medc', 'k');
set(gca, 'XTick', [1 2], ...
         'XTickLabel', {'LH MI', 'RH MI'}, ...
         'FontSize', 14, ...
         'FontName', 'Times New Roman', ...
         'FontWeight', 'bold');
ylabel('PageRank Centrality', 'FontSize', 18, 'FontName', 'Times New Roman');
title('PageRank Centrality (Channel 18)', 'FontWeight', 'bold');

%% Statistical Test - Centrality
[h, p1plv] = ttest(plvsL1, plvsR1);
