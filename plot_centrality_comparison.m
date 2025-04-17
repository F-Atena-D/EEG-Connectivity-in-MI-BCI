% Script Name: plot_centrality_comparison.m
% Author: Fatemeh Delavari (Atena)
% Date: 2024-03-03
% Version: 1.0
% Description: This script compares and visualizes centrality values from left and right 
% brain regions using a horizontal bar chart. The top nodes based on combined centrality 
% are sorted and labeled accordingly.

%% Initialization
clear; clc;  % Clear workspace and command window

%% Load Data
load('cent1_2.mat', 'nmrCentRL', 'nrCentR', 'nrCentL');
load('pi.mat');
% load('mgini1.mat', 'mginiImp'); % Optional: Uncomment if needed

%% Preprocessing: Calculate mean absolute centrality for right and left
nmrCentR = abs(mean(nrCentR, 2));
nmrCentL = abs(mean(nrCentL, 2));

%% Sort combined centrality in descending order
[schimp, ichimp] = sort(nmrCentRL, 'descend');

%% Prepare Data for Plotting
y = 22:-1:1;  % Categories (reversed for top-down order)
x1 = -10 * (schimp - min(schimp));  % Scaled difference from minimum
x2 = nmrCentR(ichimp);              % Right hemisphere values sorted

%% Create Horizontal Bar Plot
figure;
hb1 = barh(y, x1, 'DisplayName', '10x Centrality Difference');
hb1.FaceColor = 'r';
hold on;
hb2 = barh(y, x2, 'DisplayName', 'Centrality Right');
hb2.FaceColor = 'g';

%% Define Electrode Labels (in sorted order)
labels = {'Fz', 'Fc3', 'Fc1', 'Fcz', 'Fc2', 'Fc4', 'C5', 'C3', 'C1', 'Cz', 'C2', ...
          'C4', 'C6', 'Cp3', 'Cp1', 'Cpz', 'Cp2', 'Cp4', 'P1', 'Pz', 'P2', 'Poz'};

%% Add Text Labels to Bars
for i = 1:22
    text(-1.3, i - 0.7, labels{ichimp(23 - i)}, ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'bottom', ...
        'FontSize', 12, ...
        'FontName', 'Times New Roman');
end

%% Final Plot Adjustments
axis off;
lgd = legend('show');
set(lgd, 'Location', 'southoutside');
set(lgd, 'Orientation', 'horizontal');
set(lgd, 'FontSize', 12);
set(lgd, 'FontName', 'Times New Roman');
