
% Script Name: Acc_Percentile3(2).m
% Author: Fatemeh Delavari (Atena)
% Date: 2024-03-04
% Version: 1.0
% Description: This script evaluates classification accuracy for varying top-x% 
% of most important PLV features (based on RF importance). It uses 5-fold 
% cross-validation and performs subject-level linear regression on accuracy trends.

%% Start Timer
tic;

%% Load Required Data
load('RFp3.mat');          % sim, sis: feature importances and indices
load('PLV3.mat');          % plvR3, plvL3: PLV connectivity matrices
load('pi3.mat');           % pi: subject-wise significance indicators

%% Parameters
ntr = 21;
num_samples = 2 * ntr;
n_folds = 5;
numTrees = 100;
cv = cvpartition(num_samples, 'KFold', n_folds);
numConns = 4096;           % For 64x64 upper triangle (excluding self-loops)

%% Extract Real Importance Values
nrsi = zeros(109, numConns);
for d = 1:109
    for cn = 1:length(sis) - 1
        nrsi(d, cn + 1) = sim(d, sis(d, :) == cn);
    end
end

%% Accuracy Calculation for Top-x% Connections
for d = 5  % You can change this to a list like 1:109
    if pi(d) < 0.05
        XR = reshape(plvR3(d, :, :, :), ntr, []);
        XL = reshape(plvL3(d, :, :, :), ntr, []);

        for pct = 1:99
            threshold = prctile(nrsi(d, :), pct);
            selected = find(nrsi(d, :) > threshold);

            Xdata = [XR(:, selected); XL(:, selected)];
            Ydata = [ones(ntr, 1); 2 * ones(ntr, 1)];

            for i = 1:n_folds
                train_idx = cv.training(i);
                test_idx = cv.test(i);

                train_data = Xdata(train_idx, :);
                test_data = Xdata(test_idx, :);
                train_label = Ydata(train_idx);
                test_label = Ydata(test_idx);

                model = TreeBagger(numTrees, train_data, train_label, ...
                    'Method', 'classification', 'OOBPredictorImportance', 'on');
                Y_pred = str2double(predict(model, test_data));

                acCV(d, i, pct) = 100 * sum(Y_pred == test_label) / length(test_label);
            end
        end
    end
end

toc;

%% Compute Mean Accuracy per Percentile
for d = 5
    mAcc(d, :) = squeeze(mean(acCV(d, :, :), 2));
end

%% Plot Accuracy vs Top-x% and Fit Linear Trend
figure; hold on;
mAcc2 = mAcc(d, :);
mAcc2(mAcc2 == 0) = [];

x = 1:length(mAcc2);
y = mAcc2;

% Scatter plot
plot(x, y, '.', 'MarkerSize', 15, 'LineWidth', 2);
ylim([0 100]);

% Linear regression
p = polyfit(x, y, 1);
y_pred = polyval(p, x);
plot(x, y_pred, '-', 'LineWidth', 2);

% Store slope and intercept
sl(d - 2) = p(1);       % d = 5 → index 3
alpha(d - 2) = p(2);

%% Identify Best Percentile for Each Subject
for d = 1:108
    mp(d) = max(find(mAcc(d, :) == max(mAcc(d, :), [], 'all')));
end
mp2 = mp; mp2(mp2 == 99) = [];  % Remove potential saturation

mmp = mean(mp);  % Average best percentile

%% Max Accuracy Per Subject
for d = 1:108
    mmAcc(d) = max(mAcc(d, :), [], 'all');
end
mmAcc(mmAcc == 0) = [];

%% Save Results
save('acc_perct3.mat', 'acCV', 'mp', 'nrsi');

%% Analyze Accuracy at 97th Percentile
acCVs = squeeze(mean(acCV, 2));
ac97 = acCVs(:, 97);
ac97 = ac97(pi < 0.01);     % Only significant subjects
ac97(ac97 == 0) = [];
mAC = mean(ac97);

%% Optional Visualization
% figure; imagesc(mAcc); colorbar; title('Accuracy Heatmap (Subject 5)');
% figure; plot(mAcc(d, :), '.', 'MarkerSize', 15); title('Accuracy per Percentile');
