
% Script Name: Power1
% Author: Fatemeh Delavari 
% Version: 1.0
% Description: This script calculates Relative Power of EEG signals
% in BCI Competition dataset

clear; clc;  % Clear workspace and command window
tic

%% Load the preprocessed EEG data
load("PLR1.mat");

%%  Calculate and save the Relative Power of all channels
for d = 1:9 %Subjects
    for tr = 1:72 %Trials
        RP_R1(d, tr, :) = log(diag(squeeze(PRd(d, tr, :, :))'*squeeze(PRd(d, tr, :, :)))/trace(squeeze(PRd(d, tr, :, :))'*squeeze(PRd(d, tr, :, :))));
        RP_L1(d, tr, :) = log(diag(squeeze(PLd(d, tr, :, :))'*squeeze(PLd(d, tr, :, :)))/trace(squeeze(PLd(d, tr, :, :))'*squeeze(PLd(d, tr, :, :))));
    end
end

save("powerLR1.mat", "RP_L1", "RP_R1");

toc