
% Script Name: power_plv_violin3.m
% Author: Fatemeh Delavari (Atena)
% Date: 2024-03-03
% Version: 1.0
% Description: Compares mu-band relative power and PageRank centrality at channel 20
% between LH and RH motor imagery trials across significant subjects (pi3 < 0.01).

%% Initialization
clear; clc;

%% Load Relative Power Data
load("powerLR3.mat", "RP_L3", "RP_R3");
load("pi3.mat");

%% Extract Channel 20 Power for Significant Subjects
psR = reshape(RP_R3(pi < 0.01, :, 20), [], 1);
psL = reshape(RP_L3(pi < 0.01, :, 20), [], 1);

% Remove NaNs
psR = psR(~isnan(psR));
psL = psL(~isnan(psL));

%% Plot Power Violin Plot
figure;
violin([psL, psR], 'facecolor', [0.2 0.6 1; 1 0.4 0.4], 'medc', 'k');
set(gca, 'XTick', [1 2], ...
         'XTickLabel', {'LH MI', 'RH MI'}, ...
         'FontSize', 14, ...
         'FontName', 'Times New Roman', ...
         'FontWeight', 'bold');
ylabel('Relative Power 8–13 Hz (a.u.)', 'FontSize', 18, 'FontName', 'Times New Roman');
title('Mu-Band Power (Channel 20)', 'FontWeight', 'bold');

%% Paired t-test for Power
[h, p3p] = ttest(psL, psR);

%% Load PLV Data and Compute PageRank Centrality
load('PLV3.mat', "plvR3", "plvL3");

for SN = 1:109
    for tr = 1:21
        G = graph(squeeze(plvR3(SN, tr, :, :)), 'upper');
        CentR(SN, tr, :) = centrality(G, 'pagerank', 'Importance', G.Edges.Weight);

        G = graph(squeeze(plvL3(SN, tr, :, :)), 'upper');
        CentL(SN, tr, :) = centrality(G, 'pagerank', 'Importance', G.Edges.Weight);
    end
end

%% Extract Channel 20 Centrality for Significant Subjects
plvsR = reshape(CentR(pi < 0.01, :, 20), [], 1);
plvsL = reshape(CentL(pi < 0.01, :, 20), [], 1);

%% Plot Centrality Violin Plot
figure;
violin([plvsL, plvsR], 'facecolor', [0.2 0.6 1; 1 0.4 0.4], 'medc', 'k');
set(gca, 'XTick', [1 2], ...
         'XTickLabel', {'LH MI', 'RH MI'}, ...
         'FontSize', 14, ...
         'FontName', 'Times New Roman', ...
         'FontWeight', 'bold');
ylabel('PageRank Centrality', 'FontSize', 18, 'FontName', 'Times New Roman');
title('PageRank Centrality (Channel 20)', 'FontWeight', 'bold');

%% Paired t-test for Centrality
[h, p2plv] = ttest(plvsL, plvsR);
