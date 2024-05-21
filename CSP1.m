
% Script Name: CSP1
% Author: Fatemeh Delavari 
% Version: 1.0
% Description: This script applies Common Spatial Pattern (CSP) method for
% classifying RH and LH EEG data in BCI Competition dataset
 
clear; clc;  % Clear workspace and command window
tic

%% Load the preprocessed EEG data
load("PLR1.mat");

%% Computing CSP filter
num_samples = 72; % number of trials
n = 5; % number of folds
cv = cvpartition(num_samples, 'KFold', n); % create a partitioning vector

for d = 1:9 % Subjects
    for ii = 1:n
        train_idx = cv.training(ii); % indices of training samples for fold i
        test_idx = cv.test(ii); % indices of testing samples for fold i

        classesT = {squeeze(PLd(d, train_idx, :, :)), squeeze(PRd(d, train_idx, :, :))};
        numClasses = length(classesT);
        cspFiltersOvAT = cell(1, numClasses);

        % Compute CSP filters for each class vs all others
        for i = 1:numClasses
            covClassT = mean_covariance(classesT{i});
            otherClassesT = classesT;
            otherClassesT(i) = [];
            covOthersT = mean_covariance(cell2mat(otherClassesT'));

            % Compute CSP for the current class vs all others
            [VT, ~] = eig(covClassT, covClassT + covOthersT);

            % Storing CSP filters
            cspFiltersOvAT{i} = VT;
        end

        %%
        for tr = 1:length(train_idx)
            tridx = find(train_idx == 1);
            tsidx = find(test_idx == 1);
        end

        %%
        clear cspFeaturesLtr cspFeaturesRtr fltcLtr fltcRtr
        for tr = 1:length(tridx)
            cLtr = squeeze([PLd(d, tridx(tr), :, :)]);
            cRtr = squeeze([PRd(d, tridx(tr), :, :)]);

            fltcLtr(:, :, tr) = cspFiltersOvAT{1,1}'*cLtr';
            fltcRtr(:, :, tr) = cspFiltersOvAT{1,1}'*cRtr';

            cspFeaturesLtr(:, tr) = log(diag(fltcLtr(:, :, tr)*fltcLtr(:, :, tr)')/trace(fltcLtr(:, :, tr)*fltcLtr(:, :, tr)'));
            cspFeaturesRtr(:, tr) = log(diag(fltcRtr(:, :, tr)*fltcRtr(:, :, tr)')/trace(fltcRtr(:, :, tr)*fltcRtr(:, :, tr)'));
        end
cspFeaturesLtrd(ii, d) = {cspFeaturesLtr};
cspFeaturesRtrd(ii, d) = {cspFeaturesRtr};

        clear cspFeaturesLts cspFeaturesRts fltcLts fltcRts
        for tr = 1:length(tsidx)
            cLtr = squeeze([PLd(d, tsidx(tr), :, :)]);
            cRtr = squeeze([PRd(d, tsidx(tr), :, :)]);

            fltcLts(:, :, tr) = cspFiltersOvAT{1,1}'*cLtr';
            fltcRts(:, :, tr) = cspFiltersOvAT{1,1}'*cRtr';

            cspFeaturesLts(:, tr) = log(diag(fltcLts(:, :, tr)*fltcLts(:, :, tr)')/trace(fltcLts(:, :, tr)*fltcLts(:, :, tr)'));
            cspFeaturesRts(:, tr) = log(diag(fltcRts(:, :, tr)*fltcRts(:, :, tr)')/trace(fltcRts(:, :, tr)*fltcRts(:, :, tr)'));
        end
cspFeaturesLtsd(ii, d) = {cspFeaturesLts};
cspFeaturesRtsd(ii, d) = {cspFeaturesRts};

    end
end

%%
save('cspLR1.mat', "cspFeaturesRtsd", "cspFeaturesLtsd", "cspFeaturesRtrd", "cspFeaturesLtrd");

toc

