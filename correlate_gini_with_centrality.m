% Script Name: correlate_gini_with_centrality.m
% Author: Fatemeh Delavari (Atena)
% Date: 2024-03-03
% Version: 1.0
% Description: Calculates the correlation between Gini importance and centrality 
% values (Right - Left) for two datasets, and evaluates the overlap between top 
% features selected by each metric.

%% Initialization
clear; clc;

%% --- Load and Process Dataset 1 (22 channels) ---
load('mgini1.mat', 'mginiImp');
load('cent1.mat', 'nmrCentRL');
load('pi.mat');

% Select significant samples and compute mean Gini importance
mgini1 = mginiImp(pi < 0.01, :);
mmgini1 = mean(mgini1, 1);

% Sort Gini and Centrality features
centRL1 = nmrCentRL;
[schimp1, ichimp1] = sort(mmgini1', 'descend');    % Sorted Gini
[schcent1, ichcent1] = sort(centRL1, 'descend');   % Sorted Centrality

% Correlation between mean Gini importance and centrality
corrgc1 = corr(mmgini1', centRL1);

%% --- Load and Process Dataset 3 (64 channels) ---
load('mgini3.mat', 'mginiImp');
load('cent3.mat', 'nmrCentRL');
load('pi3.mat');

% Select significant samples and compute mean Gini importance
mgini3 = mginiImp(pi < 0.01, :);
mmgini3 = mean(mgini3, 1);

% Sort Gini and Centrality features
centRL3 = nmrCentRL;
[schimp3, ichimp3] = sort(mmgini3', 'descend');    % Sorted Gini
[schcent3, ichcent3] = sort(centRL3, 'descend');   % Sorted Centrality

% Correlation across all and top 37 features
corrgc3 = corr(mmgini3', centRL3);
corrgc3_2 = corr(schimp3(1:37), centRL3(ichimp3(1:37)));

%% --- Compare Top Features Overlap for Dataset 3 ---
pch = 3;  % Top-k features
vector1 = ichimp3(1:pch);    % Top Gini
vector2 = ichcent3(1:pch);   % Top Centrality

common_elements = intersect(vector1, vector2);
number_of_common_elements = numel(common_elements);
prct_int = 100 * number_of_common_elements / pch;

%% --- Compare Top Features Overlap for Dataset 1 ---
pch = 5;  % Top-k features
vector1 = ichimp1(1:pch);    % Top Gini
vector2 = ichcent1(1:pch);   % Top Centrality

common_elements = intersect(vector1, vector2);
number_of_common_elements = numel(common_elements);
prct_int1 = 100 * number_of_common_elements / pch;
