
% Script Name: Pre1
% Author: Fatemeh Delavari 
% Version: 1.0
% Description: This script performs preprocessing of the project's first EEG dataset 
% (BCI Competition 4 dataset 2a)

clear; clc;  % Clear workspace and command window
tic

%% 
Fs = 250; % Sampling frequency
parent_directory = 'C:\BCI';  % Specify the path to the parent directory
subdirectory1_name = 'BCICompetition4Dataset2a';  % Specify the subdirectory

dh = fdesign.highpass('Fst,Fp,Ast,Ap',(7)*(2/Fs),(8)*(2/Fs),70,0.1);
Hd = design(dh,'equiripple');
[numh, denh] = tf(Hd);

dl = fdesign.lowpass('Fp,Fst,Ap,Ast',13*(2/Fs),15*(2/Fs),0.1,70);
Ld = design(dl,'equiripple');
[numl, denl] = tf(Ld);

for SN = 1:9 % Subject Number
    subdirectory2_name = sprintf('A0%dT', SN);  % train set
    % Create the full path to the subdirectory
    Path = fullfile(parent_directory, subdirectory1_name, subdirectory2_name);
    % Load the EEG data
    load(Path)
    %
    for tn = 4:9 % trial number (the first three trials are related to EOG influence and are not used in this study)
        if SN == 4 % In the training set, subject 4 has 7 trials instead of 9 (due to technical problems!)
            tn = tn-2;
        end
        ED = data{1, tn}.X; % Load the EEG data
        ET = data{1, tn}.trial; % Load the MI task start time
        EY = data{1, tn}.y; % Load the labels

        dfilth = filtfilt(numh, denh, ED);
        dfilthl = filtfilt(numl, denl, dfilth);

        EDM = dfilthl(:, 1:22); % Keep only the main channels (remove the EOG channels)

        % left hand
        c1 = ET(EY==1);
        for i = 1:12
            LD(:, i, :) = EDM(c1(i)+751: c1(i)+1500, 1:22);
        end
        % right hand
        c2 = ET(EY==2);
        for i = 1:12
            RD(:, i, :) = EDM(c2(i)+751: c2(i)+1500, 1:22);
        end

        if SN ==4 % For training set
            tn = tn+2;
        end

        tn = tn -3;

        LDC( :, tn, :) = reshape(LD, [], 22);
        RDC(:, tn, :) = reshape(RD, [], 22);

    end
    LDCT = reshape(LDC, [], 22);
    RDCT = reshape(RDC, [], 22);

    save(sprintf('L%dT.mat', SN), "LDCT");
    save(sprintf('R%dT.mat', SN), "RDCT");
end

%%
nch = 22; % number of channels
ntr = 72; % number of trials

%%
for SN = 1:9 
    %%
    load(sprintf('L%dT.mat', SN), "LDCT");
    load(sprintf('R%dT.mat', SN), "RDCT");
    % Epoch duration and overlap (in seconds)
    epochDuration = 3;  % seconds
    epochOverlap = 0; % 0% overlap

    % Convert epoch duration and overlap from seconds to samples
    epochSamples = round(epochDuration * Fs);
    overlapSamples = round(epochOverlap * Fs);

    %%
    % Define the EEG data and labels (assuming two classes)
    eegDataR = double(RDCT'); % EEG data matrix (channels x samples)
    eegDataL = double(LDCT'); % EEG data matrix (channels x samples)

    %%
    for ch = 1:nch
        eegDataa = squeeze(eegDataL(ch, :))';
        eegEpochsFC = buffer(eegDataa, epochSamples, overlapSamples, 'nodelay');
        PL(:,:,ch) = eegEpochsFC(:, 1:ntr)';

        eegDataa = squeeze(eegDataR(ch, :))';
        eegEpochsSC = buffer(eegDataa, epochSamples, overlapSamples, 'nodelay');
        PR(:,:,ch) = eegEpochsSC(:, 1:ntr)';
    end

    PLd (SN, :, :, :) = PL;
    PRd (SN, :, :, :) = PR;

    %%
end

%%
save("PLR1.mat", 'PRd', "PLd");

toc

