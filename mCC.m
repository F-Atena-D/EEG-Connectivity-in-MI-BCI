% function mCC:
% Author: Fatemeh Delavari
% Version: 1.0
% Description: This function computes the maximum cross-correlation (mCC) 
% between pairs of channels in a multichannel EEG data

function cc = mCC(X, maxLag)
    % Input:
    % X - a matrix where each column represents a channel of EEG data
    % maxLag - the maximum lag to consider in the cross-correlation computation
    % Output:
    % cc - a matrix representing the maximum cross-correlation between all pairs of channels

    % Number of channels
    nch = size(X, 2);

    % Initialize the cross-correlation matrix
    cc = zeros(nch, nch);

    % Loop through each pair of channels to compute the cross-correlation
    for i = 1:nch
        for j = 1:nch
            % Compute the cross-correlation sequence between channel i and channel j
            [corrSeq, ~] = xcorr(X(:,i), X(:,j), maxLag, 'coeff'); % 'coeff' normalizes the sequence
            % Find the maximum of the absolute correlation values
            maxCorrelation = max(abs(corrSeq));
            % Assign the maximum correlation value to the cross-correlation matrix
            cc(i,j) = maxCorrelation;
            % Ensure the matrix is symmetric
            cc(j,i) = maxCorrelation;
        end
    end
end
