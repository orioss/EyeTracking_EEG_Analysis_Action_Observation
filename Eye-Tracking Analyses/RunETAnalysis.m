% RunETAnalysis runs all the eye-tracking analyses in the paper by the order
% of the figures (Figures 2-4)
%
%% Description
% RunETAnalysis script is the main script of the eye tracking analysis
% it gets the ET data from SMI (or any other source according to the CSV
% structure of SMI) and perform the following analyses: AOI, Gaze shift,
% probability patterns, and pupil resonse
%%
% data folder that includes the SMI CSV files (see example in the Data
% folder
data_dir = 'Data';

% convert the data from SMI summary data to MATLAB file
all_AOI_summary_data=GetAOISummaryDataFromCSVs(fullfile(data_dir,'AOI_summary'))

% save the eye tracking sumary data in a MAT file to save time in the future
save('AOI_Summary.mat','all_AOI_data');

% Performs AOI analysis (that is, amount of time each group looked at a
% specific AOI (Figure 2B-C) 
CalculateAOISummary(all_AOI_summary_data);

% convert the data from the CSV to MAT. depending on the data, this might
% take some time because this is not summary but AOI data from SMI BeGaze program 
AOI_ET_events=GetAOIDataFromCSVs(fullfile(data_dir,'AOI'))

% Performs AOI analysis - gaze shifts between pairs of AOIs (Figure 2D)
CalculateAOITransitions(AOI_ET_events)

% convert the SMI BeGaze events data (any eye-tracking event) from the CSV to MAT.  
ET_fixation_data=GetFixationsDataFromCSVs(fullfile(data_dir,'EVENTS'))

% Performs probability map analysis (Figure 3A)
CreateLookingProbabilityMaps(ET_fixation_data)

% runs machine-learning analysis (video-based CNN classification; Figure 3B)
CreateVideoReaders();
PrepareLookingVideosForCNN(ET_fixation_data);
CreateCNNFirstModelLayerAndInput(ET_fixation_data);
shuffle_num = 1000;
for shuf_num=0:1000
    VideoClassification(ET_fixation_data, shuf_num);
end

% convert the SMI BeGaze pupil data from the CSV to MAT.  
ET_pupil_data=GetFixationsDataFromCSVs(fullfile(data_dir,'PUPIL'))

% Performs pupil dilation analysis (Figure 4)
CalculatePupilDilation(ET_pupil_data)