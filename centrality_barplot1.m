
% Script Name: centrality_barplot1.m
% Author: Fatemeh Delavari (Atena)
% Date: 2024-03-03
% Version: 1.0
% Description: This script visualizes the difference in average PageRank centrality 
% between left and right-hand conditions using horizontal bar plots. Channels 
% are sorted based on descending combined centrality difference.

%% Initialization
clear; clc;

%% Load Centrality and Importance Data
load('mgini1.mat', 'mginiImp');
load('cent1_2.mat', 'nmrCentRL', 'nrCentR', 'nrCentL');
load('pi.mat');  % Optional: significance mask

%% Compute Absolute Mean Centralities for Right and Left
nmrCentR = abs(mean(nrCentR, 2));
nmrCentL = abs(mean(nrCentL, 2));

%% Sort Centrality Differences in Descending Order
[schimp, ichimp] = sort(nmrCentRL, 'descend');

%% Prepare Bar Plot
figure;

% y-axis categories (e.g., 22 → 1)
y = 22:-1:1;

% Normalize centrality difference for visualization
x1 = -10 .* (schimp - min(schimp));   % Scaled difference (red bars)
x2 = nmrCentR(ichimp);                % Right-hand centrality (green bars)

% Horizontal bars for centrality difference
hb1 = barh(y, x1, 'DisplayName', '10× Centrality Difference');
hb1.FaceColor = 'r'; hold on;

% Horizontal bars for right-hand centrality
hb2 = barh(y, x2, 'DisplayName', 'Centrality Right');
hb2.FaceColor = 'g';

%% Define Sorted Electrode Labels
labels = {'Fz', 'Fc3', 'Fc1', 'Fcz', 'Fc2', 'Fc4', 'C5', 'C3', 'C1', 'Cz', 'C2', ...
          'C4', 'C6', 'Cp3', 'Cp1', 'Cpz', 'Cp2', 'Cp4', 'P1', 'Pz', 'P2', 'Poz'};

% Display labels beside bars
for i = 1:22
    text(-1.3, i - 0.7, labels(ichimp(23 - i)), ...
         'HorizontalAlignment', 'center', ...
         'VerticalAlignment', 'bottom', ...
         'FontSize', 12, ...
         'FontName', 'Times New Roman');
end

%% Legend and Formatting
lgd = legend('show');
set(lgd, 'Location', 'southoutside', ...
         'Orientation', 'horizontal', ...
         'FontSize', 12, ...
         'FontName', 'Times New Roman');

axis off;  % Remove axis ticks
