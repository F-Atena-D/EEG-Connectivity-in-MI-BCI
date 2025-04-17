% Script Name: compute_and_plot_centrality.m
% Author: Fatemeh Delavari (Atena)
% Date: 2024-03-03
% Version: 1.0
% Description: Calculates PageRank and degree centrality for left and right hemispheres 
% based on PLV matrices, normalizes the values, computes their differences, and visualizes 
% node centralities on a 2D topographic plot.

%% Initialization
clear; clc;
tic;

%% Load Required Data
load('PLV3.mat', "plvR3", 'plvL3');  % Phase Locking Values for right and left
load('pi3.mat', 'pi');               % Statistical significance values

%% Compute Centrality Measures
ntr = 21;  % Number of trials per subject
for SN = 1:109
    for tr = 1:ntr
        G = graph(squeeze(plvR3(SN, tr, :, :)), 'upper');
        CentRp(:, tr, SN) = centrality(G, 'pagerank', 'Importance', G.Edges.Weight);
        
        G = graph(squeeze(plvL3(SN, tr, :, :)), 'upper');
        CentLp(:, tr, SN) = centrality(G, 'pagerank', 'Importance', G.Edges.Weight);
        
        G = graph(squeeze(plvR3(SN, tr, :, :)), 'upper');
        CentRd(:, tr, SN) = centrality(G, 'degree', 'Importance', G.Edges.Weight);
        
        G = graph(squeeze(plvL3(SN, tr, :, :)), 'upper');
        CentLd(:, tr, SN) = centrality(G, 'degree', 'Importance', G.Edges.Weight);
    end
end

%% Select Statistically Significant Subjects
iCentLp = CentLp(:, :, pi < 0.05);
iCentRp = CentRp(:, :, pi < 0.05);

%% Reshape and Normalize Centralities
rCentR = reshape(iCentRp, 64, []);
rCentL = reshape(iCentLp, 64, []);
A = [rCentR, rCentL];

[m, n] = size(A);
normalizedA = zeros(m, n);

for i = 1:n
    minVal = min(A(:, i));
    maxVal = max(A(:, i));
    range = maxVal - minVal;
    if range == 0
        normalizedA(:, i) = 0;  % Avoid division by zero
    else
        normalizedA(:, i) = (A(:, i) - minVal) / range;
    end
end

nrCentR = normalizedA(:, 1:size(rCentR, 2));
nrCentL = normalizedA(:, size(rCentR, 2) + 1:end);

%% Compute Centrality Differences
nrCentRL = nrCentR - nrCentL;
nmrCentRL = abs(mean(nrCentRL, 2));

%% Topographic Plot Coordinates
X = [-0.6, -0.4, -0.2, 0, 0.2, 0.4, 0.6, -0.6, -0.4, -0.2, 0, 0.2, 0.4, 0.6, ...
     -0.6, -0.4, -0.2, 0, 0.2, 0.4, 0.6, -0.3, 0, 0.3, ...
     -0.5, -0.3, 0, 0.3, 0.5, -0.8, -0.6, -0.4, -0.2, 0, 0.2, 0.4, 0.6, 0.8, ...
     -0.8, 0.8, -0.8, 0.8, -1, 1, -0.8, 0.8, -0.8, -0.6, ...
     -0.4, -0.2, 0, 0.2, 0.4, 0.6, 0.8, -0.5, -0.3, 0, 0.3, 0.5, -0.3, 0, 0.3, 0];
Y = [0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0, 0, 0, 0, 0, 0, 0, ...
     -0.2, -0.2, -0.2, -0.2, -0.2, -0.2, -0.2, 0.8, 0.8, 0.8, ...
     0.7, 0.6, 0.6, 0.6, 0.7, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, ...
     0.2, 0.2, 0, 0, 0, 0, -0.2, -0.2, -0.4, -0.4, ...
     -0.4, -0.4, -0.4, -0.4, -0.4, -0.4, -0.4, -0.7, -0.6, -0.6, -0.6, -0.7, ...
     -0.8, -0.8, -0.8, -1];

%% Plot EEG Node Centrality Map
figure;
hold on;
rectangle('Position', [-1, -1, 2, 2], 'Curvature', [1, 1], 'EdgeColor', 'k', 'FaceColor', 'none');

% Top triangle representing head orientation
XX = [0, 0.2, -0.2, 0];
YY = [1.2, 1, 1, 1.2];
line(XX, YY, 'Color', 'k');

axis equal;
axis off;

%% Overlay Centrality as Bubble Plot
scatter(X, Y, 5000 * (nmrCentRL + 0.01), ...
    'MarkerFaceColor', [0 0.4470 0.7410], ...
    'MarkerEdgeColor', [0 0.4470 0.7410]);

% Add Channel Indices
for i = 1:64
    text(X(i), Y(i) + 0.03, sprintf('%d', i), ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'bottom');
end

%% Save Normalized Centrality Results
save('cent3.mat', "nrCentL", 'nrCentR');
