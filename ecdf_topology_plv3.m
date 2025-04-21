
% Script Name: ecdf_topology_plv3.m
% Author: Fatemeh Delavari (Atena)
% Date: 2024-03-03
% Version: 1.0
% Description: Computes and visualizes ECDFs of topology metrics 
% using binary PLV graphs (thresholded at mean + std) for LH and RH motor imagery.

%% Initialization
clear; clc;

%% Load PLV Data
load('C:\Users\Atena\OneDrive - University of Connecticut\DriveCbackup\MIBCI_2024\PLV3.mat');

%% Build Matrix Index Map (Upper Triangle of 64×64)
M = zeros(64, 64);
counter = 1;
for i = 1:64
    for j = i:64
        M(i, j) = counter;
        counter = counter + 1;
    end
end

%% Compute Network Metrics for All Subjects and Trials
for SN = 1:109
    all_conn = [reshape(plvR3(SN, :, :, :), 1, []), reshape(plvL3(SN, :, :, :), 1, [])];
    threshold = mean(all_conn) + std(all_conn);  % Binarization threshold

    for tr = 1:21
        XVL = reshape(plvL3(SN, tr, :, :), 1, []);
        XVR = reshape(plvR3(SN, tr, :, :), 1, []);
        XVL = double(XVL > threshold);
        XVR = double(XVR > threshold);

        % Construct upper-triangular adjacency matrices
        XML = zeros(64); XMR = zeros(64);
        for i = 1:64
            for j = i:64
                if i ~= j
                    XML(i, j) = XVL(M(i, j));
                    XMR(i, j) = XVR(M(i, j));
                end
            end
        end

        % Compute metrics
        densityL(tr, SN) = calculateDensityUndirected(XML);
        densityR(tr, SN) = calculateDensityUndirected(XMR);

        pathL(tr, SN) = averagePathLengthUndirect(XML);
        pathR(tr, SN) = averagePathLengthUndirect(XMR);

        dCCL(tr, SN) = undirected_clustering_coefficient(XML);
        dCCR(tr, SN) = undirected_clustering_coefficient(XMR);
    end
end

%% Helper Function: ECDF Plotting
plot_ecdf_comparison = @(data1, data2, xlab) ...
    figure;
     hold on;
     [x1, f1] = ecdf(data1); stairs(x1, f1, 'r', 'LineWidth', 2);
     [x2, f2] = ecdf(data2); stairs(x2, f2, 'b', 'LineWidth', 2);
     plot(x1, f1, 'ro', 'MarkerFaceColor', 'r');
     plot(x2, f2, 'bo', 'MarkerFaceColor', 'b');
     xlabel(xlab, 'FontWeight', 'bold');
     ylabel('ECDF', 'FontWeight', 'bold');
     legend('LH MI', 'RH MI');
     xlim([min([data1; data2]), max([data1; data2])]);
     ylim([0, 1]);
     set(gca, 'FontSize', 12);
     hold off;

%% ECDF Plot: Graph Density
plot_ecdf_comparison(reshape(densityL, [], 1), reshape(densityR, [], 1), 'Graph Density');

%% ECDF Plot: Shortest Path Length
plot_ecdf_comparison(reshape(pathL, [], 1), reshape(pathR, [], 1), 'Shortest Path Length');

%% ECDF Plot: Clustering Coefficient
plot_ecdf_comparison(reshape(dCCL, [], 1), reshape(dCCR, [], 1), 'Clustering Coefficient');
