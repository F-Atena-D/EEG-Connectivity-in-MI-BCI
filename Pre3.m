
% Script Name: Pre3
% Author: Fatemeh Delavari 
% Version: 1.0
% Description: This script performs preprocessing of the project's second EEG dataset 
% (Physionet MI dataset)

clear; clc;  % Clear workspace and command window
tic

%%
directory = 'C:\BCI\Pre3\';
Fs = 160; % Sampling frequency
Td = 4.1; % Task Duration
ntr = 21; % Number of trials
nch = 64; % Number of Channels

%%
SN = 1;
subdirectory1 = sprintf('S%03d', SN);
subdirectory2 = sprintf('S%03dR04.edf', SN);
path = fullfile(directory, subdirectory1, subdirectory2);
[data, annotations] = edfread(path);

%%
% Get a list of all channel names in the timetable
chanNames = data.Properties.VariableNames;

%%
% High-pass filtering (8 Hz)
dd = fdesign.highpass('Fst,Fp,Ast,Ap',(7)*(2/Fs),(8.0)*(2/Fs),70,0.1);
Hd = design(dd,'equiripple');
[numH, denH] = tf(Hd);

% Low-pass filtering (13 Hz)
dd = fdesign.lowpass('Fp,Fst,Ap,Ast',13*(2/Fs),15*(2/Fs),0.1,70);
Ld = design(dd,'equiripple');
[numL, denL] = tf(Ld);

%%
for SN = 1:109

    %% Run 1 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    subdirectory1 = sprintf('S%03d', SN);
    subdirectory2 = sprintf('S%03dR04.edf', SN);
    path = fullfile(directory, subdirectory1, subdirectory2);
    [data, annotations] = edfread(path);

    %%
    for ch = 1:64
        % Initialize an empty vector to hold the concatenated result
        ContD = [];
        % Loop through each row of the timetable
        for dsn = 1:123
            % Concatenate the vector from the current cell to the end
            ContD = [ContD; data.(chanNames{ch}){dsn}];
        end
        ContE(:, ch) = ContD;
    end

    %%
    % High-pass filtering (8 Hz)
    dfilth = filtfilt(numH, denH, ContE);

    % Low-pass filtering (13 Hz)
    dfilthl = filtfilt(numL, denL, dfilth);

    preprocD = dfilthl;

    %%
    La = find(annotations.Annotations == "T1");
    Ra = find(annotations.Annotations == "T2");

    %%
    Lo = annotations.Onset(La);
    Ro = annotations.Onset(Ra);

    %%
    Ls = Lo*Fs;
    Rs = Ro*Fs;

    %%
    Lsb = seconds(Ls);
    Lse = Lsb + (Td*Fs) - 1;

    Rsb = seconds(Rs);
    Rse = Rsb + (Td*Fs) - 1;

    %%
    for tr = 1:7
        LE1(tr, :, :) = preprocD(Lsb(tr):Lse(tr), :);
    end

    for tr = 1:7
        RE1(tr, :, :) = preprocD(Rsb(tr):Rse(tr), :);
    end

    %% Run 2 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    subdirectory1 = sprintf('S%03d', SN);
    subdirectory2 = sprintf('S%03dR08.edf', SN);
    path = fullfile(directory, subdirectory1, subdirectory2);
    [data, annotations] = edfread(path);

    %%
    clear ContE
    for ch = 1:64
        % Initialize an empty vector to hold the concatenated result
        ContD = [];
        % Loop through each row of the timetable
        for dsn = 1: 123
            % Concatenate the vector from the current cell to the end
            ContD = [ContD; data.(chanNames{ch}){dsn}];
        end
        ContE(:, ch) = ContD;
    end

    %%
    % High-pass filtering (8 Hz)
    dfilth = filtfilt(numH, denH, ContE);

    % Low-pass filtering (13 Hz)
    dfilthl = filtfilt(numL, denL, dfilth);

    preprocD = dfilthl;

    %%
    La = find(annotations.Annotations == "T1");
    Ra = find(annotations.Annotations == "T2");

    %%
    Lo = annotations.Onset(La);
    Ro = annotations.Onset(Ra);

    %%
    Ls = Lo*Fs;
    Rs = Ro*Fs;

    %%
    Lsb = seconds(Ls);
    Lse = Lsb + (Td*Fs) - 1;

    Rsb = seconds(Rs);
    Rse = Rsb + (Td*Fs) - 1;

    %%
    for tr = 1:7
        LE2(tr, :, :) = preprocD(Lsb(tr):Lse(tr), :);
    end

    for tr = 1:7
        RE2(tr, :, :) = preprocD(Rsb(tr):Rse(tr), :);
    end

    %% Run 3 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    subdirectory1 = sprintf('S%03d', SN);
    subdirectory2 = sprintf('S%03dR12.edf', SN);
    path = fullfile(directory, subdirectory1, subdirectory2);
    [data, annotations] = edfread(path);

    %%
    % Get a list of all channel names in the timetable
    chanNames = data.Properties.VariableNames;

    %%
    clear ContE
    for ch = 1:64
        % Initialize an empty vector to hold the concatenated result
        ContD = [];
        % Loop through each row of the timetable
        for dsn = 1: 123
            % Concatenate the vector from the current cell to the end
            ContD = [ContD; data.(chanNames{ch}){dsn}];
        end
        ContE(:, ch) = ContD;
    end

    %%
    % High-pass filtering (8 Hz)
    dfilth = filtfilt(numH, denH, ContE);

    % Low-pass filtering (13 Hz)
    dfilthl = filtfilt(numL, denL, dfilth);

    preprocD = dfilthl;

    %%
    La = find(annotations.Annotations == "T1");
    Ra = find(annotations.Annotations == "T2");

    %%
    Lo = annotations.Onset(La);
    Ro = annotations.Onset(Ra);

    %%
    Ls = Lo*Fs;
    Rs = Ro*Fs;

    %%
    Lsb = seconds(Ls);
    Lse = Lsb + (Td*Fs) - 1;

    Rsb = seconds(Rs);
    Rse = Rsb + (Td*Fs) - 1;

    %%
    for tr = 1:7
        LE3(tr, :, :) = preprocD(Lsb(tr):Lse(tr), :);
    end

    for tr = 1:7
        RE3(tr, :, :) = preprocD(Rsb(tr):Rse(tr), :);
    end

    %%
    PR = [RE1; RE2; RE3];
    PL = [LE1; LE2; LE3];

    DR(SN, :, :, :) = PR;
    DL(SN, :, :, :) = PL;

end

toc

%%
save("PLR3.mat", 'DL', "DR");

