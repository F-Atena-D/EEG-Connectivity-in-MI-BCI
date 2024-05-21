% function mPLV:
% Author: Fatemeh Delavari
% Version: 1.0
% Description: This function computes the Phase Locking Value (mPLV) 
% for a given multichannel time series data.

function plv = mPLV(X)
    % Input:
    % X - a matrix where each column represents a channel of time series data
    % Output:
    % plv - a matrix representing the mean Phase Locking Value between all pairs of channels

    % Number of channels
    nch = size(X, 2);

    % Initialize phase matrix
    phase = zeros(size(X));

    % Loop through each channel to calculate the Hilbert transform and extract the phase
    for ch = 1:nch
        % Calculate the Hilbert transform for the current channel
        hs = hilbert(X(:, ch));
        % Extract the phase of the analytic signal
        phase(:, ch) = angle(hs);
    end

    % Initialize dphi matrix
    dphi = zeros(size(X, 1), nch, nch);

    % Loop through each pair of channels to compute the phase differences
    for i = 1:nch
        for j = 1:nch
            % Compute the phase difference between channel i and channel j
            dphi(:, i, j) = (phase(:, i) - phase(:, j));
        end
    end

    % Compute the Phase Locking Value (PLV) across time
    plv = squeeze(abs(mean(exp(1i*dphi), 1)));
end

