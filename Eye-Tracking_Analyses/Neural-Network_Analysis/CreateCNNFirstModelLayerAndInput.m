function CreateCNNFirstModelLayerAndInput(trial_data)
% CreateCNNFirstModelLayerAndInput construct the first layer of the  CNN model 
% for video classification and the input to the classifier (data and labels)
%
%% Syntax
% CreateCNNFirstModelLayerAndInput(trial_data)
%
%% Description
% CreateCNNFirstModelLayerAndInput starts the CNN model for classification. The
% model is based on MATLAB deep learning video classifier (Yue-Hei Ng et
% al. 2015). The model is a combination of a pre-trained image model
% (GoogleNet) and an LSTM network. The function also created the input to
% the classifier - the data (looking videos) and the labels (display type -
% efficient/inefficient)
%
% Required Input.
% trial_data:  MATLAB array containing data about the trials of all
% subjects in both groups

% gets data about group, subjects, and trials.
trial_data=trial_data(:,[1 2 4]);
trial_data=unique(trial_data,'rows');

% go over the groups
for group=1:2

    % gets the group subjects
    group_subjects = unique(trial_data(trial_data(:,1)==group-1,2));

    % go over all subjects in the group
    for subj_ix=1:length(group_subjects)

        % gets the subject data and all information about the trials
        subj_data = trial_data(trial_data(:,2)==group_subjects(subj_ix),:); 
        subj_trials = unique(subj_data(:,3));

        % construct the CNN model based on GoogleNet network
        netCNN = googlenet;

        % construct the first layer of the network to convert video frames to
        % feature vectors
        inputSize = netCNN.Layers(1).InputSize(1:2);
        layerName = "pool5-7x7_s1";

        % sets a counter for the mapping between the relevant trials and their
        % labels for the labels structure
        labels_counter=1;

        % go over all trials 
        for trial_ix=1:length(subj_trials)

            % loads the looking-video structure that was saved by
            % "PrepareLookingVideosForCNN" function
            load(fullfile('ESC_CNN',['group_' num2str(group) '_subj_' num2str(subj_ix) '_trial_' num2str(subj_trials(trial_ix)) '.mat']),'trial_data_for_CNN','trial_cond','presenter','stim_ind');

            % use only trials with test videos - efficient and inefficientactions
            if (trial_cond==1 | trial_cond==3)

                % gets the first frame in the trial
                first_frame = trial_data_for_CNN{1};

                % gets the size of each frame
                H = size(first_frame,1);
                W = size(first_frame,2);

                % creates a video structure (to later convert the frames to
                % feature vectors
                numFrames = length(trial_data_for_CNN);
                video = zeros(H,W,3,numFrames);

                % Read frames and insert to the video structure
                for i=1:length(trial_data_for_CNN)
                    video(:,:,:,i) = trial_data_for_CNN{i};
                end
                clear trial_data_for_CNN

                % resize video to match the input size of the GoogLeNet network
                video = CenterCrop(video,inputSize);

                % convert the video frames to a sequence of feature vectors 
                sequences{labels_counter,1} = activations(netCNN,video,layerName,'OutputAs','columns');
                clear video

                % sets the label according to the trial cond (in the paper we
                % only used labels1. labels2 is the actor).
                labels1{labels_counter}=num2str(trial_cond);
                labels2{labels_counter}=num2str(presenter);
                original_trials(labels_counter)=trial_ix;
                labels_counter=labels_counter+1;
            end
        end

        % removes trials without enough data for classification
        [sequences,labels1,labels2,original_trials] = RemoveTrialsWithNoData(sequences,labels1,labels2,original_trials);

        % saves data to classifer per subject 
        save(fullfile('DataForCNN',['group_' num2str(group) '_subj_' num2str(subj_ix) '.mat']),'sequences','labels1','labels2','netCNN','original_trials');

        % cleans all variables besides basic vars
        clearvars -except subj_ix group_subjects group AOI_event_array
    end
end