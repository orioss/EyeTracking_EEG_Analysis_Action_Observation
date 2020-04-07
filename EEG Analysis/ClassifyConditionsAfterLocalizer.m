function ClassifyConditionsAfterLocalizer(data_folder, conds_to_compare,iter_num,shuf_num)
% ClassifyConditionsAfterLocalizer gets a folder with all participants datasets, 
% and performs classification of the test videos based on the localizer
% results 
%
%% Syntax
% ClassifyConditionsAfterLocalizer(data_folder, conds_to_compare,subj_count,iter_num,shuf_num)
%
%% Description
% ClassifyConditionsAfterLocalizer gets the folder with participants
% datasets, the conditions to classify, the number of classification
% iteration ('leave-one-out' procedure), and the number of shuffles (for
% significance test), performs SVM classification and saves classification
% results (real and shuffled data) in results folder
%
% Required Input.
% data_folder: folder with EEG data per subject (including localizer results)
% conds_to_compare: which conditions (indicated by event number in EEG structure) to classify
% iter_num: number of iterations for leave-one-out procedure.
% shuf_num: number of shuffles for significance test)

% creating a classification results folder
result_folder = fullfile(data_folder,'ClassificationResults',['conds' num2str(conds_to_compare)]);
mkdir(result_folder);

% indicates the time limites of the EEG epoch
lims = [-1.5 4];

% loads the the times and frequencies of ERSP map for printing purposes
load('time_freqs.mat');

% gets the subject folders
subj_folders = dir(data_folder);

% go over all subjects
for subj_folder = subj_folders'
    if (strcmp(subj_folder.name,'.') | strcmp(subj_folder.name,'..'))
        continue;
    end

    % loads the subject's epoched EEG file (according to EEGLAB)
    EEG = pop_loadset(fullfile(subj_folder.folder,subj_folder.name ,[subj_folder.name '_epoched.set']));
    
    % gets the group and subject number from the folder name
    subject_name=subj_folder.name;
    subj_num = str2double(subject_name(end-4:end-3));
    subj_group = strcmp(subject_name(end-1:end),'AD');
    
    % convert EEG event types to numbers and gets which events are relevant
    % to localizer displays only
    trials_for_classification = {EEG.event.type};
    trials_for_classification (cell2mat(cellfun(@(elem) strcmp(elem, '1'), trials_for_classification, 'UniformOutput', false))) = {1};
    trials_for_classification (cell2mat(cellfun(@(elem) strcmp(elem, '2'), trials_for_classification, 'UniformOutput', false))) = {2};
    trials_for_classification (cell2mat(cellfun(@(elem) strcmp(elem, '3'), trials_for_classification, 'UniformOutput', false))) = {3};
    trials_for_classification (cell2mat(cellfun(@(elem) strcmp(elem, '4'), trials_for_classification, 'UniformOutput', false))) = {4};
    trials_for_classification = cell2mat(trials_for_classification);
    trials_for_classification_ids = find(ismember(trials_for_classification,[1 3]));
    trials_for_classification = trials_for_classification(trials_for_classification_ids);

    % loads the localizer results 
    clusters_found_in_localizer = dir(fullfile(subj_folder.folder,subj_folder.name ,['timef_localizer_2  4' ],'*localizer.mat'));
    
    % initialize data array to combine data from all clusters 
    data_for_classification = [];
    
    % go over all subject's clusters
    for clusters_file=clusters_found_in_localizer'
        
        % initialize a label array for classification
        labels_for_classification=[];
        
        % loads the file with the information about the clusters
        load(fullfile(clusters_file.folder,clusters_file.name));
        
        % adding the times and freqs that should be used for classification from the clusters 
        idx_of_clusters = [];
        for c_i=1:length(clusters)
            current_cluster_idx = clusters{c_i};
            idx_of_clusters = [idx_of_clusters; current_cluster_idx];
        end
        
        % gets the channel data only for test-video trials
        channel_data = EEG.data(good_channel,:,trials_for_classification_ids);
        
        % gets the number of relevant trials (trials that contain one of
        % the displays to classify
        number_of_trials = size(channel_data,3);
        
        % go over all relevant trials
        for t_ix=1:number_of_trials 
            
            % gets the channel data for the specific trial
            trial_channel_data = channel_data(:,:,t_ix);
         
            % if channel is disconnected or have some error - skip (should not
            % happen in case of using only the good channels
            if (length(unique(trial_channel_data))<10)  
              continue;    
            end
            
            % perform time-frequency analyses on the trial data
            [trial_ersp,~,~,ersp_times,ersp_freqs,~,~] = newtimef(trial_channel_data, size(trial_channel_data ,2), lims*1000,EEG.srate, [6 0.5], ... 
                                                'basenorm','on','baseline',[-1500 0],'verbose', 'off','freqscale','log', 'maxfreq',25, 'timesout',200,'nfreqs', 200, ... 
                                                'plotersp','off','plotitc','off','plotphasesign','off','plotphaseonly','off'); 
    
            % initialize the trial data for classification
            trial_data_for_classification = [];
            
            % gets the relevant values for the cluster - the
            % times and frequencies that were found significant in the
            % localizer procedure
            for ii=1:size(idx_of_clusters,1)
                trial_data_for_classification = [trial_data_for_classification trial_ersp(idx_of_clusters(ii,1),idx_of_clusters(ii,2))];
            end
            
            % adds the trial data to the labels structure and to the
            % data set that will be used for classification
            ch_data_for_classification(t_ix,:) = trial_data_for_classification; 
            trial_idx_for_classification_labels = [trial_idx_for_classification_labels ]; 
            labels_for_classification = [labels_for_classification trials_for_classification(t_ix)];
        end
        
        % adds the channel data for classification to the subjects' data for
        % classification (which is a long array with the ERSP values in the subject's significant
        % time and frequency from the localizer procedure
        data_for_classification = [data_for_classification ch_data_for_classification];
        clear ch_data_for_classification
    end

    % performs and SVM classification ('leave-one-out' procedre)
    [acc,total_acc_shuff]=Classify(data_for_classification(labels_for_classification==1,:), data_for_classification(labels_for_classification==3,:),iter_num, shuf_num);
    
    % calculates classification significance 
    total_acc_shuff_sorted = sort(total_acc_shuff);
    p = acc>total_acc_shuff_sorted;
    p = 1 - (length(p(p==1))/shuf_num);
    clear data_for_classification
    
    % saves classification results to the results folder
    save(fullfile(data_folder,['S' num2str(subj_num) '_' subject_name(end-1:end) '_classification_results.mat']),'acc','total_acc_shuff','p','subj_group','subj_num');
end