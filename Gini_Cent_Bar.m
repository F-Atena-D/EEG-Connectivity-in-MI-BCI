% Script Name: Gini_Cent_Bar.m
% Author: Fatemeh Delavari (Atena)
% Date: 2024-03-03
% Version: 1.0
% Description: This script compares Gini importance and centrality values
% for the top EEG channels and visualizes them in a horizontal bar chart.

%% Initialization
clear; clc;

%% Load Data
load('mgini3.mat', 'mginiImp');            % Gini importance values
load('cent3.mat', 'nmrCentRL');            % Centrality values
chcent = nmrCentRL;                        % Centrality for plotting

%% Sort Channels by Gini Importance
[schimp, ichimp] = sort(mean(mginiImp, 1), 'descend');

%% Prepare Data for Plotting (Top Channels)
y = 37:-1:1;                               % Bar plot y-axis positions
x1 = -1 .* schimp(1:37);                   % Negative Gini importance
x2 = chcent(ichimp(1:37));                 % Corresponding centrality

%% Create Horizontal Bar Plot
fig = figure;
hb1 = barh(y, x1, 'DisplayName', 'Gini Importance');
hb1.FaceColor = 'b';
hold on;
hb2 = barh(y, x2, 'DisplayName', 'Centrality Difference');
hb2.FaceColor = 'r';

axis off;

%% Load Channel Names from EDF File
directory = 'C:\Users\Atena\OneDrive - University of Connecticut\DriveCbackup\MIBCI_May2024\Pre3\';
SN = 1;
subdirectory1 = sprintf('S%03d', SN);
subdirectory2 = sprintf('S%03dR04.edf', SN);
path = fullfile(directory, subdirectory1, subdirectory2);
[data, annotations] = edfread(path);
chanNames = data.Properties.VariableNames;

%% Clean Channel Names (Remove Underscores)
cleaned_channel_names = regexprep(chanNames, '_', '');
disp(cleaned_channel_names);

%% Add Placeholders Instead of Channel Names (Optional)
for i = 1:2:37
    text(-0.035, i - 0.7, '-', ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'bottom', ...
        'FontSize', 12, ...
        'FontName', 'Times New Roman');
end

%% Final Plot Adjustments
lgd = legend('show');
set(lgd, 'Location', 'southoutside');
set(lgd, 'Orientation', 'horizontal');
set(lgd, 'FontSize', 12);
set(lgd, 'FontName', 'Times New Roman');
