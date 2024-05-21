% function mPLI:
% Description: Computes the Weighted Phase Lag Index (wPLI) between two signals

function wPLI = mPLI(signal1, signal2)
% Inputs:
%   signal1 - First signal [1 x nSamples]
%   signal2 - Second signal [1 x nSamples]

% Output:
%   wPLI - Weighted Phase Lag Index value

% Compute the analytic signal using the Hilbert transform for both signals
analytic1 = hilbert(signal1);
analytic2 = hilbert(signal2);

% Extract instantaneous phases from the analytic signals
phase1 = angle(analytic1);
phase2 = angle(analytic2);

% Compute the phase difference between the two signals
phase_difference = phase1 - phase2;

% Compute the imaginary part of the phase difference
imaginary_phase_difference = imag(exp(1i * phase_difference));

% Compute the numerator as the absolute mean of the imaginary part of the phase difference
numerator = abs(mean(imaginary_phase_difference));

% Compute the denominator as the mean of the absolute imaginary part of the phase difference
denominator = mean(abs(imaginary_phase_difference));

% Compute the Weighted Phase Lag Index (wPLI)
wPLI = numerator / denominator;

end
