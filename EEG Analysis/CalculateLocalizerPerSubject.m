function CalculateLocalizerPerSubject(data_folder, localizer_conds)
% ExtractEpochs gets a folder with all participants datasets, and cut each EEG signal 
% to epochs according to a given sync file
%
%% Syntax
% ExtractEpochs(data_dir, sync_times_file)
%
%% Description
% ExtractEpochs gets the folder with participants datasets and the timing
% of their display. It saves a new dataset with EEG epochs
% (according to conditions) for each participant with EEG data and the
% timing of the sync (the sync is an event in the EEG data that correspond
% a light in the third-person video (the sync light allows synchronization
% between the display and the EEG signal
%
% Required Input.
% data_dir:  folder that contains subjects folder with EEG dataset (.set
% file).
% sync_times_file: a file containing the order and time of each display to
% create epochs in the EEG signal

% initialize the time limits of the epochs
lims = [-1.5 3];

% extract MATLAB file with the good subject and their good motor channels (based
% on manual inspection)
load('good_subjects.mat');
load('good_channels.mat');

% gets all subject folders 
subj_folders = dir(data_folder);

% go over all subjects
subject_counter=1; 
for subj_folder = subj_folders'
    if (strcmp(subj_folder.name,'.') | strcmp(subj_folder.name,'..'))
        continue;
    end

    % loads subject's EEG
    EEG = pop_loadset(fullfile(subj_folder.folder,subj_folder.name ,[subj_folder.name '_epoched.set']));
    
    % gets subject number and group from file name
    subject_name=subj_folder.name;
    subj_num = str2double(subject_name(end-4:end-3));  
    subj_group = strcmp(subject_name(end-1:end),'AD');
    
    % create a folder for all clustering plots to validate clusters
    clusters_figures_folder = fullfile(subj_folder.folder,subj_folder.name,sprintf(['timef_localizer_' num2str(localizer_conds)]));
    mkdir(clusters_figures_folder);
    
    % convert EEG event types to numbers and gets which events are relevant
    % to localizer displays only
    trials_for_localizer = {EEG.event.type};
    trials_for_localizer (cell2mat(cellfun(@(elem) strcmp(elem, '1'), trials_for_localizer, 'UniformOutput', false))) = {1};
    trials_for_localizer (cell2mat(cellfun(@(elem) strcmp(elem, '2'), trials_for_localizer, 'UniformOutput', false))) = {2};
    trials_for_localizer (cell2mat(cellfun(@(elem) strcmp(elem, '3'), trials_for_localizer, 'UniformOutput', false))) = {3};
    trials_for_localizer (cell2mat(cellfun(@(elem) strcmp(elem, '4'), trials_for_localizer, 'UniformOutput', false))) = {4};
    trials_for_localizer = cell2mat(trials_for_localizer);
    trials_for_localizer = find(ismember(trials_for_localizer,localizer_conds));
    
    % initialize an array to check which trials were removed because they
    % were outliers in the signal (
    number_of_trials_removed = [];
    
    % go over all channels (possible also run only on valid motor channels that
    % are after manual inspection. in that case, the loop will be on 
    % 'subject_good_channels' variable. we did both. 
    for ch=1:size(EEG.data,1)        
        
        % gets only the relevant trials that has an epoch in the EEG
        trials_for_localizer(trials_for_localizer>size(EEG.data,3))=[];
        
        % gets the channel data only for localizer trials
        channel_data = EEG.data(ch,:,trials_for_localizer);
        
        % if channel is disconnected or have some error - skip (should not
        % happen in case of using only the good channels
        if (length(unique(channel_data))<10)  
            continue;
        end
        
        % remove outliers (more than 3 SDs than average
        data_similarity = squareform(pdist(squeeze(channel_data)'));
        m_dsm = mean(data_similarity);
        outliers = find(m_dsm>mean(m_dsm)+3*std(m_dsm) | m_dsm<mean(m_dsm)-3*std(m_dsm));
        valid_indices = 1:size(channel_data,3);
        valid_indices = valid_indices(~ismember(valid_indices,outliers));
        data_no_outliers=channel_data(:,:,valid_indices);
        channel_data = data_no_outliers;
        
        % adds removed trials to the removed-trials structure
        number_of_trials_removed = [number_of_trials_removed; subj_num ch length(outliers)];

        % gets the updated number of trials
        number_of_trials = size(channel_data,3);
         
         % creates data structure for calculating supression significance
         % (clustering analysis)
         data_for_clustering = zeros(number_of_trials,200,200);
         
         % go over tirals 
         for t_ix=1:number_of_trials 
             
             % gets the trial data of the specific channel
              trial_channel_data = channel_data(:,:,t_ix);

              % checks if the channel was not disconnected in the specific trial
              if (length(unique(trial_channel_data))<10)  
                  continue;
              end

              % performs time-frequency analysis
              [trial_ersp,~,~,ersp_times,ersp_freqs,~,~] = newtimef(trial_channel_data, size(trial_channel_data ,2), lims*1000,EEG.srate, [6 0.1], ... 
                                                     'basenorm','on','baseline',[-2500 0],'verbose', 'off','freqscale','log', 'maxfreq',25, 'timesout',200,'nfreqs', 200,... ... ...'maxfreq',25, ... 
                                                     'plotersp','off','plotitc','off','plotphasesign','off','plotphaseonly','off'); 
              
              % adds the ERSP map to the data structure for calculating
              % significance
              data_for_clustering(t_ix,:,:) = trial_ersp;
         end
         
         % gets only the time after movement onset for clustering analysis
         data_for_clustering=data_for_clustering(:,:,ersp_times>0);
         
         % performs clustering analysis
         [clusters,hip]=ClusterAnalysisOnLocalizerERSP(data_for_clustering,zeros(size(data_for_clustering)),2);
        
         % prints the clusters to the a localizer folder 
         hip_for_printing = [zeros(size(hip,1),length(ersp_times(ersp_times<0))) hip];
         save(fullfile(clusters_figures_folder, sprintf('ch_%.f_localizer.mat',good_channel)),'clusters','hip','ersp_times','ersp_freqs','ch','data_for_clustering','good_channel');       
         f = figure('visible','off');
         hold on;
         imagesc(hip_for_printing);
         xticks(1:20:length(ersp_times));
         xticklabels(round(ersp_times(1:20:end)));
         yticks(1:20:length(ersp_freqs));
         yticklabels(ersp_freqs(1:20:end));
         ylabel('Frequency (Hz)');
         xlabel('Time (ms)');
         set(f,'color','w');
         line_time = length(ersp_times(ersp_times<0));
         line([line_time(1) line_time(1)],[0 length(ersp_freqs(ersp_freqs<25))+1],'Color','r','LineWidth',4);
         set(gca,'YDir','normal');
         saveas(f, fullfile(clusters_figures_folder, sprintf('ch_%.f_clusters.eps',good_channel)));
         saveas(f, fullfile(clusters_figures_folder, sprintf('ch_%.f_clusters.jpg',good_channel)));
         close all;
         subject_counter=subject_counter+1;
     end

    
end