
% Script Name: Power3
% Author: Fatemeh Delavari 
% Version: 1.0
% Description: This script calculates Relative Power of EEG signals
% in Physionet dataset

clear; clc;  % Clear workspace and command window
tic

%%
load('PLR3.mat', "DL", "DR");

for SN = 1:109
    for tr = 1:21
        RP_R3(SN, tr, :) = log(diag(squeeze(DR(SN, tr, :, :))'*squeeze(DR(SN, tr, :, :)))/trace(squeeze(DR(SN, tr, :, :))'*squeeze(DR(SN, tr, :, :))));
        RP_L3(SN, tr, :) = log(diag(squeeze(DL(SN, tr, :, :))'*squeeze(DL(SN, tr, :, :)))/trace(squeeze(DL(SN, tr, :, :))'*squeeze(DL(SN, tr, :, :))));
    end
end

save("powerLR3.mat", "RP_L3", "RP_R3");

toc