% RunEEGAnalysis runs all the EEG analyses in the paper 
%
%% Description
% RunEEGAnalysis runs all the EEG analyses in the paper after preprocessing
% - create epochs, find channels from localizer and run SVM classification.
%%
%
% data folder that includes the EEG data
data_dir = 'EEG_data';

% MATLAB file with all the sync times for each participants
sync_times_file='ESCPerception_EEG_sync_times.mat';

% edit the EEG files to includes epochs according to the displays
ExtractEpochs(data_dir, sync_times_file)

addpath(genpath('/scratch/oo8/Util/'));
rmpath(genpath('/scratch/oo8/Util/eeglab13_6_5b/eeglab13_6_5b/functions/octavefunc'));

% runs localizer 
SingleSubject_TimeFrequencyAnalysis(data_dir,[2 4]);

% runs classification analysis
ClassifyConditionsAfterLocalizer(data_dir, [1 3],500,1000);
