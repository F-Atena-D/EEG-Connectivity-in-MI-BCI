% function mean_covariance:
% Author: Fatemeh Delavari
% Version: 1.0
% Description: This function computes the mean covariance matrix across multiple trials.

function covMatrix = mean_covariance(data)
    % Input:
    % data - a 3D matrix where each slice along the first dimension represents a trial
    % Output:
    % covMatrix - the mean covariance matrix computed across all trials

    % Get the number of trials
    [numTrials, ~, ~] = size(data);

    % Initialize a 3D matrix to store covariance matrices for each trial
    covMatrices = zeros(size(data, 3), size(data, 3), numTrials);

    % Loop through each trial to compute the covariance matrix
    for tr = 1:numTrials
        % Extract data for the current trial and compute its covariance matrix
        c = squeeze(data(tr, :, :));
        covMatrices(:,:,tr) = cov(c);
    end

    % Compute the mean covariance matrix across all trials
    covMatrix = mean(covMatrices, 3);
end


