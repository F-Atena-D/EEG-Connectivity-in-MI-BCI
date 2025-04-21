
% Script Name: TopologyMetric3
% Author: Fatemeh Delavari (Atena)
% Date: 2024-03-04
% Version: 1.0
% Description: This script calculates network topology metrics (graph density,
% average path length, and clustering coefficient) using thresholded PLV matrices
% for left-hand and right-hand motor imagery, across 109 subjects and 21 trials.

%% Initialization
clear; clc;
tic;

%% Load PLV Data (64-channel)
load('C:\Users\Atena\OneDrive - University of Connecticut\DriveCbackup\MIBCI_2024\PLV3.mat');

%% Create Upper-Triangle Index Mapping Matrix (64 × 64)
M = zeros(64, 64);
counter = 1;
for i = 1:64
    for j = i:64
        M(i, j) = counter;
        counter = counter + 1;
    end
end

%% Graph Metric Computation
for SN = 1:109
    % Concatenate all PLV values from both hands for thresholding
    XRL = [reshape(plvR3(SN, :, :, :), 1, []), reshape(plvL3(SN, :, :, :), 1, [])];
    
    meanValue = mean(XRL);
    stdValue = std(XRL);
    threshold = meanValue + stdValue;

    for tr = 1:21
        % Extract trial connectivity
        XVL = reshape(plvL3(SN, tr, :, :), 1, []);
        XVR = reshape(plvR3(SN, tr, :, :), 1, []);

        % Binarize by threshold
        XVL = double(XVL > threshold);
        XVR = double(XVR > threshold);

        XML = zeros(64, 64);
        XMR = zeros(64, 64);
        for i = 1:64
            for j = i:64
                if i ~= j
                    XML(i, j) = XVL(M(i, j));
                    XMR(i, j) = XVR(M(i, j));
                end
            end
        end

        % Compute Graph Metrics
        densityL(tr, SN) = calculateDensityUndirected(XML);
        densityR(tr, SN) = calculateDensityUndirected(XMR);

        pathL(tr, SN) = averagePathLengthUndirect(XML);
        pathR(tr, SN) = averagePathLengthUndirect(XMR);

        dCCL(tr, SN) = undirected_clustering_coefficient(XML);
        dCCR(tr, SN) = undirected_clustering_coefficient(XMR);
    end
end

toc;

%% Trial-Averaged Subject-Level Stats
mdensityL = mean(densityL, 1);    sdensityL = std(densityL, [], 1);
mdensityR = mean(densityR, 1);    sdensityR = std(densityR, [], 1);

mpathL = mean(pathL, 1);          spathL = std(pathL, [], 1);
mpathR = mean(pathR, 1);          spathR = std(pathR, [], 1);

mdCCL = mean(dCCL, 1);            sdCCL = std(dCCL, [], 1);
mdCCR = mean(dCCR, 1);            sdCCR = std(dCCR, [], 1);

%% Global Mean ± SEM (scaled metrics where noted)
n = 21 * 109;

amdensityL = mean(20 * densityL, 'all');
asdensityL = std(20 * densityL, [], 'all') / sqrt(n);
amdensityR = mean(20 * densityR, 'all');
asdensityR = std(20 * densityR, [], 'all') / sqrt(n);

ampathL = mean(pathL, 'all');
aspathL = std(pathL, [], 'all') / sqrt(n);
ampathR = mean(pathR, 'all');
aspathR = std(pathR, [], 'all') / sqrt(n);

amdCCL = mean(20 * dCCL, 'all');
asdCCL = std(20 * dCCL, [], 'all') / sqrt(n);
amdCCR = mean(20 * dCCR, 'all');
asdCCR = std(20 * dCCR, [], 'all') / sqrt(n);

%% Grouped Bar Plot (LH vs RH, 3 Metrics)
groups = {'20×GD', 'SPL', '20×ClustCoeff'};
subgroups = {'LH', 'RH'};
means = [amdensityL amdensityR; ampathL ampathR; amdCCL amdCCR];
std_devs = [asdensityL asdensityR; aspathL aspathR; asdCCL asdCCR];

num_groups = numel(groups);
num_subgroups = numel(subgroups);
bar_width = 0.8;
group_width = bar_width / num_subgroups;
colors = [0.3010 0.7450 0.9330; 0.4660 0.6740 0.1880];

figure; hold on;
for i = 1:num_groups
    for j = 1:num_subgroups
        % Position each bar
        x = i - group_width * (num_subgroups / 2) + (2 * j - 1) * group_width / 2;
        bar(x, means(i, j), group_width, 'FaceColor', colors(j, :));
        errorbar(x, means(i, j), std_devs(i, j), 'k', 'LineWidth', 1, 'linestyle', 'none');
    end
end

set(gca, 'xtick', 1:num_groups, 'xticklabel', groups);
ylabel('Graph Metric Value', 'FontSize', 14, 'FontName', 'Times New Roman');
legend(subgroups, 'FontName', 'Times New Roman', 'Location', 'northeast');
set(gca, 'FontSize', 14, 'FontWeight', 'bold', 'FontName', 'Times New Roman');
grid on;
