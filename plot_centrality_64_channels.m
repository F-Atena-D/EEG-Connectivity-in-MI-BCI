% Script Name: plot_centrality_64_channels.m
% Author: Fatemeh Delavari (Atena)
% Date: 2024-03-03
% Version: 1.0
% Description: This script loads centrality and EEG data, computes and visualizes 
% right hemisphere centrality vs. combined centrality for 64 EEG channels, and 
% annotates the plot with channel names.

%% Initialization
clear; clc;

%% Load Data
load('mgini3.mat', 'mginiImp');
load('cent3.mat', 'nmrCentRL', 'nrCentR', 'nrCentL');
load('pi3.mat');

%% Calculate Mean Absolute Centrality
nmrCentR = abs(mean(nrCentR, 2));
nmrCentL = abs(mean(nrCentL, 2));

%% Sort Combined Centrality
[schimp, ichimp] = sort(nmrCentRL, 'descend');

%% Prepare Data for Plotting
y = 64:-1:1;                             % Category indices
x1 = -10 * (schimp - min(schimp));      % Scaled difference from min
x2 = nmrCentR(ichimp);                  % Sorted right centrality

%% Create Horizontal Bar Plot
figure;
hb1 = barh(y, x1, 'DisplayName', '10x Centrality Difference');
hb1.FaceColor = 'r';
hold on;
hb2 = barh(y, x2, 'DisplayName', 'Centrality Right');
hb2.FaceColor = 'g';

%% Load Channel Names from EDF File
directory = 'C:\Users\Atena\OneDrive - University of Connecticut\DriveCbackup\SecondPhaseofThesis\Pre3\';
SN = 1;
subdirectory1 = sprintf('S%03d', SN);
subdirectory2 = sprintf('S%03dR04.edf', SN);
path = fullfile(directory, subdirectory1, subdirectory2);

[data, annotations] = edfread(path);              % Read EDF
chanNames = data.Properties.VariableNames;        % Get channel names

%% Clean Channel Names (Remove Underscores)
cleaned_channel_names = regexprep(chanNames, '_', '');
disp(cleaned_channel_names);

%% Annotate Selected Channel Names
axis off;
label_indices = 1:5:64;  % Label every 5th channel
for i = label_indices
    text(-1.1, i - 0.7, cleaned_channel_names{ichimp(65 - i)}, ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'bottom', ...
        'FontSize', 12, ...
        'FontName', 'Times New Roman');
end

%% Fill in Gaps with Dashes
for i = 1:64
    if ~ismember(i, label_indices)
        text(-1.1, i - 0.7, '-', ...
            'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'bottom', ...
            'FontSize', 10, ...
            'FontName', 'Times New Roman');
    end
end

%% Final Plot Adjustments
axis off;
lgd = legend('show');
set(lgd, 'Location', 'southoutside');
set(lgd, 'Orientation', 'horizontal');
set(lgd, 'FontSize', 12);
set(lgd, 'FontName', 'Times New Roman');
