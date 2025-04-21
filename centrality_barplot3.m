
% Script Name: centrality_barplot3.m
% Author: Fatemeh Delavari (Atena)
% Date: 2024-03-04
% Version: 1.0
% Description: This script visualizes right-hand centrality and centrality differences
% for 64 EEG channels during motor imagery using horizontal bar plots. 
% Electrode labels are automatically extracted and placed next to bars.

%% Initialization
clear; clc;

%% Load Centrality and Gini Importance Data
load('mgini3.mat', 'mginiImp');
load('cent3.mat', 'nmrCentRL', 'nrCentR', 'nrCentL');
load('pi3.mat');  % Optional: significance vector

%% Compute Average Right and Left Centrality
nmrCentR = abs(mean(nrCentR, 2));
nmrCentL = abs(mean(nrCentL, 2));

%% Sort Combined Centrality Differences
[schimp, ichimp] = sort(nmrCentRL, 'descend');  % Sort descending

%% Horizontal Bar Plot
figure;
y = 64:-1:1;                              % Channel indices for plotting
x1 = -10 .* (schimp - min(schimp));       % Scaled centrality difference
x2 = nmrCentR(ichimp);                    % Right-hand centrality

hb1 = barh(y, x1, 'DisplayName', '10× Centrality Difference');
hb1.FaceColor = 'r'; hold on;
hb2 = barh(y, x2, 'DisplayName', 'Centrality Right');
hb2.FaceColor = 'g';

%% Load and Clean Channel Labels
directory = 'C:\Users\Atena\OneDrive - University of Connecticut\DriveCbackup\SecondPhaseofThesis\Pre3\';
SN = 1;
subdirectory1 = sprintf('S%03d', SN);
subdirectory2 = sprintf('S%03dR04.edf', SN);
path = fullfile(directory, subdirectory1, subdirectory2);
[data, ~] = edfread(path);

chanNames = data.Properties.VariableNames;
cleaned_channel_names = regexprep(chanNames, '_', '');  % Remove underscores
disp(cleaned_channel_names);

%% Label Channels on Bar Plot
% Display every 3rd channel label
for i = 1:3:64
    text(-0.35, i - 0.7, cleaned_channel_names{ichimp(65 - i)}, ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'bottom', ...
        'FontSize', 12, ...
        'FontName', 'Times New Roman');
end

% Fill remaining ticks with dashes
for i = 1:64
    if ~ismember(i, 1:3:64)
        text(-0.35, i - 0.7, '-', ...
            'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'bottom', ...
            'FontSize', 10, ...
            'FontName', 'Times New Roman');
    end
end

%% Legend and Formatting
lgd = legend('show');
set(lgd, 'Location', 'southoutside', ...
         'Orientation', 'horizontal', ...
         'FontSize', 12, ...
         'FontName', 'Times New Roman');

axis off;  % Hide axis lines and ticks
