
% Script Name: Acc_Percentile1.m
% Author: Fatemeh Delavari (Atena)
% Date: 2024-03-04
% Version: 1.0
% Description: This script computes classification accuracy using top-x% most 
% important PLV features (based on Random Forest importance ranking). It evaluates 
% accuracy trends using linear regression and visualizes the results.

%% Start Timer
tic;

%% Load Data
load('RFp1.mat');           % sim, sis: Random Forest importance info
load('PLV1.mat');           % plvR1, plvL1: PLV features

%% Parameters
ntr = 72;
num_samples = 2 * ntr;
num_folds = 5;
cv = cvpartition(num_samples, 'KFold', num_folds);
numTrees = 100;
subject_id = 8;

%% Extract Real Importance for All Connections
nrsi = zeros(9, 484);
for cn = 1:483
    nrsi(subject_id, cn + 1) = sim(subject_id, sis(subject_id, :) == cn);
end

XR = reshape(plvR1(subject_id, :, :, :), ntr, []);
XL = reshape(plvL1(subject_id, :, :, :), ntr, []);

%% Evaluate Accuracy for Top-x% of Features
for pct = 1:99
    threshold = prctile(nrsi(subject_id, :), pct);
    selected_conn = find(nrsi(subject_id, :) > threshold);

    Xdata = [XR(:, selected_conn); XL(:, selected_conn)];
    Ydata = [ones(ntr, 1); 2 * ones(ntr, 1)];

    for i = 1:num_folds
        train_idx = cv.training(i);
        test_idx = cv.test(i);

        train_data = Xdata(train_idx, :);
        test_data = Xdata(test_idx, :);
        train_label = Ydata(train_idx);
        test_label = Ydata(test_idx);

        rf_model = TreeBagger(numTrees, train_data, train_label, ...
            'Method', 'classification', 'OOBPredictorImportance', 'on');

        [predictedLabels, ~] = predict(rf_model, test_data);
        Y_pred = str2double(predictedLabels);

        acCV(subject_id, i, pct) = 100 * sum(Y_pred == test_label) / length(test_label);
    end
end
toc;

%% Compute Mean Accuracy Across Folds
mAcc = squeeze(mean(acCV(subject_id, :, :), 2));
mAcc2 = mAcc(mAcc > 0);  % Remove zero-filled entries

%% Plot Accuracy vs. Top-x% Features
figure;
hold on;
plot(mAcc2, '.k', 'MarkerSize', 15);
ylim([0 100]);

%% Linear Regression
x = 1:length(mAcc2);  % Percentile values
y = mAcc2;
p = polyfit(x, y, 1);     % Linear fit

% Predicted regression line
y_pred = polyval(p, x);
plot(x, y_pred, '-r', 'LineWidth', 2);

% Regression metrics
slope = p(1);
alpha = p(2);

SS_res = sum((y - y_pred).^2);
SS_tot = sum((y - mean(y)).^2);
R_squared = 1 - (SS_res / SS_tot);

% Display regression results
fprintf('\nLinear Fit:\n');
fprintf('  Slope: %.4f\n', slope);
fprintf('  Intercept (alpha): %.4f\n', alpha);
fprintf('  R-squared: %.4f\n', R_squared);

%% Axis Formatting
ax = gca;
ax.FontSize = 11;
ax.XTickLabel = 100 - ax.XTick;  % Flip x-axis labels to show top-x%
xlabel('Top x%', 'FontSize', 14, 'FontName', 'Times New Roman');
ylabel('Accuracy (%)', 'FontSize', 14, 'FontName', 'Times New Roman');

%% Save Output
save('acc_perct3n.mat', 'acCV', 'mAcc', 'nrsi', 'mp');

%% Identify Best Percentile Point
mp(subject_id) = max(find(mAcc == max(mAcc, [], 'all')));
mmp = mean(mp);  % Mean best percentile if repeated across subjects

%% Visualization of Accuracy Heatmap and Distribution
figure; imagesc(mAcc);
title('Accuracy vs Percentile (Subject 8)');

figure; plot(mAcc', '.', 'MarkerSize', 15);
title('Accuracy at Each Percentile');
