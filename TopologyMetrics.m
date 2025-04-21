
% Script Name: TopologyMetrics.m
% Author: Fatemeh Delavari (Atena)
% Date: 2024-03-04
% Version: 1.0
% Description: This script binarizes PLV-based connectivity matrices using a 
% statistical threshold and computes network-level graph metrics (density, 
% shortest path length, clustering coefficient) for both left and right motor 
% imagery conditions. Results are averaged across trials and subjects and plotted.

%% Initialization
clear; clc;
tic;

%% Load PLV Connectivity Data
load('C:\Users\Atena\OneDrive - University of Connecticut\DriveCbackup\MIBCI_2024\PLV1.mat');

%% Create Upper-Triangle Index Mapping Matrix (22 × 22)
M = zeros(22, 22);
counter = 1;
for i = 1:22
    for j = i:22
        M(i, j) = counter;
        counter = counter + 1;
    end
end

%% Graph Metric Computation Loop
for SN = 1:9
    % Flatten and concatenate all PLV matrices for left and right conditions
    XRL = [reshape(plvR1(SN, :, :, :), 1, []), reshape(plvL1(SN, :, :, :), 1, [])];

    % Compute threshold: mean + std
    threshold = mean(XRL) + std(XRL);

    for tr = 1:72
        % Extract upper triangle PLV values per trial
        XVL = reshape(plvL1(SN, tr, :, :), 1, []);
        XVR = reshape(plvR1(SN, tr, :, :), 1, []);

        % Thresholding (binary adjacency matrix)
        XVL = double(XVL > threshold);
        XVR = double(XVR > threshold);

        XML = zeros(22, 22);  % Left
        XMR = zeros(22, 22);  % Right

        for i = 1:22
            for j = i:22
                if i ~= j
                    XML(i, j) = XVL(M(i, j));
                    XMR(i, j) = XVR(M(i, j));
                end
            end
        end

        % Compute graph metrics
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

%% Group-Level Mean ± SEM
n = 72 * 9;  % Total data points
amdensityL = mean(20 * densityL, 'all');   asdensityL = std(20 * densityL, [], 'all') / sqrt(n);
amdensityR = mean(20 * densityR, 'all');   asdensityR = std(20 * densityR, [], 'all') / sqrt(n);

ampathL = mean(pathL, 'all');              aspathL = std(pathL, [], 'all') / sqrt(n);
ampathR = mean(pathR, 'all');              aspathR = std(pathR, [], 'all') / sqrt(n);

amdCCL = mean(20 * dCCL, 'all');           asdCCL = std(20 * dCCL, [], 'all') / sqrt(n);
amdCCR = mean(20 * dCCR, 'all');           asdCCR = std(20 * dCCR, [], 'all') / sqrt(n);

%% Prepare Bar Plot of LH vs RH for All Metrics
groups = {'20×GD', 'SPL', '20×ClustCoeff'};
subgroups = {'LH', 'RH'};

means = [amdensityL amdensityR; ampathL ampathR; amdCCL amdCCR];        % [metrics × LH/RH]
std_devs = [asdensityL asdensityR; aspathL aspathR; asdCCL asdCCR];

num_groups = numel(groups);
num_subgroups = numel(subgroups);

%% Bar Plot with Error Bars
figure; hold on;
bar_width = 0.8;
group_width = bar_width / num_subgroups;
colors = [0.3010 0.7450 0.9330; 0.4660 0.6740 0.1880];

for i = 1:num_groups
    for j = 1:num_subgroups
        x = i - group_width * (num_subgroups/2) + (2*j-1) * group_width / 2;
        bar(x, means(i, j), group_width, 'FaceColor', colors(j, :));
        errorbar(x, means(i, j), std_devs(i, j), 'k', 'LineWidth', 1, 'linestyle', 'none');
    end
end

set(gca, 'xtick', 1:num_groups, 'xticklabel', groups);
ylabel('Graph Metric Value', 'FontSize', 14, 'FontName', 'Times New Roman');
legend(subgroups, 'FontName', 'Times New Roman');
set(gca, 'FontSize', 14, 'FontWeight', 'bold', 'FontName', 'Times New Roman');
grid on;
