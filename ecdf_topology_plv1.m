
% Script Name: ecdf_topology_plv1.m
% Author: Fatemeh Delavari (Atena)
% Date: 2024-03-03
% Version: 1.0
% Description: Computes and visualizes ECDFs of topology metrics
% (Graph Density, Shortest Path Length, and Clustering Coefficient)
% using PLV connectivity matrices binarized at (mean + std) threshold.

%% Initialization
clear; clc;

%% Load PLV Data
load('C:\Users\Atena\OneDrive - University of Connecticut\DriveCbackup\MIBCI_2024\PLV1.mat');

%% Define Matrix Indexing (Upper Triangle)
M = zeros(22, 22);
counter = 1;
for i = 1:22
    for j = i:22
        M(i, j) = counter;
        counter = counter + 1;
    end
end

%% Compute Network Metrics for Each Subject and Trial
for SN = 1:9
    XRL = [reshape(plvR1(SN, :, :, :), 1, []), reshape(plvL1(SN, :, :, :), 1, [])];
    threshold = mean(XRL) + std(XRL);  % Binarization threshold

    for tr = 1:72
        % Vectorize PLV matrices
        XVL = reshape(plvL1(SN, tr, :, :), 1, []);
        XVR = reshape(plvR1(SN, tr, :, :), 1, []);
        XVL = double(XVL > threshold);
        XVR = double(XVR > threshold);

        % Construct adjacency matrices
        XML = zeros(22); XMR = zeros(22);
        for i = 1:22
            for j = i:22
                if i ~= j
                    XML(i, j) = XVL(M(i, j));
                    XMR(i, j) = XVR(M(i, j));
                end
            end
        end

        % Compute network metrics
        densityL(tr, SN) = calculateDensityUndirected(XML);
        densityR(tr, SN) = calculateDensityUndirected(XMR);

        pathL(tr, SN) = averagePathLengthUndirect(XML);
        pathR(tr, SN) = averagePathLengthUndirect(XMR);

        dCCL(tr, SN) = undirected_clustering_coefficient(XML);
        dCCR(tr, SN) = undirected_clustering_coefficient(XMR);
    end
end

%% Function: Plot ECDF for two datasets
plot_ecdf_comparison = @(x, y, xlab) ...
    figure;
     hold on;
     [xs1, f1] = ecdf(x); stairs(xs1, f1, 'r', 'LineWidth', 2);
     [xs2, f2] = ecdf(y); stairs(xs2, f2, 'b', 'LineWidth', 2);
     plot(xs1, f1, 'ro', 'MarkerFaceColor', 'r');
     plot(xs2, f2, 'bo', 'MarkerFaceColor', 'b');
     xlabel(xlab, 'FontWeight', 'bold');
     ylabel('ECDF', 'FontWeight', 'bold');
     legend('LH MI', 'RH MI');
     xlim([min([x; y]), max([x; y])]);
     ylim([0, 1]);
     set(gca, 'FontSize', 12);
     hold off;

%% ECDF Plot: Graph Density
plot_ecdf_comparison(reshape(densityL, [], 1), reshape(densityR, [], 1), 'Graph Density');

%% ECDF Plot: Shortest Path Length
plot_ecdf_comparison(reshape(pathL, [], 1), reshape(pathR, [], 1), 'Shortest Path Length');

%% ECDF Plot: Clustering Coefficient
plot_ecdf_comparison(reshape(dCCL, [], 1), reshape(dCCR, [], 1), 'Clustering Coefficient');
