function ExtractEpochs(data_dir, sync_times_file)
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

% gets the sync times from the input (gives the timing in the EEG signal
% that the displays started
load(sync_times_file);

% gets all the subjects folder
data_folders = dir(data_dir);

% gets the details about each display
[display_details_in_num, display_names, display_interval_times_in_ms] = GetESCDisplayMap();

% go over all sujects
for subj_folder=data_folders'
    
   % skip if not data folder
   if (strcmp(subj_folder.name,'.') || strcmp(subj_folder.name,'..'))
       continue;
   end
   
   % gets the subject number
   subj_number = str2num(subj_folder.name(end-4:end-3)); 
   
   % imports EEG from the SET file
   EEG_set_file = fullfile(subj_folder.folder,subj_folder.name, [subj_folder.name '.set']);   
   basic_EEG = pop_loadset(EEG_set_file);
   
   % updates the EEG channels (done also manually if there were online changes
   % during the study
   basic_EEG.chanlocs=pop_chanedit(basic_EEG.chanlocs, 'load',{ 'Enobio32.locs', 'filetype', 'autodetect'});
   
  % check if there is a valid sync event in the EEG
  if (isempty(basic_EEG.event))
       error(['subject' num2str(subj_number) ' does not have a sync in the EEG']);
  end
  if (isempty(sync_times(sync_times(:,1)==subj_number,2)))
       error(['subject' num2str(subj_number) ' does not have a sync in the Video']);
  end
   EEG_sync_events_ix = find([basic_EEG.event.type]=='1');
   if (isempty(EEG_sync_events_ix))
       error(['subject' num2str(subj_number) ' does not have a sync in the EEG']);
   end
   diff_array = (diff([basic_EEG.event(:).latency_ms])>2000);
   if (max(diff_array)>0)
       gaps = find(diff_array==1);
       trigger_ind=gaps(end)+1;
   else
       trigger_ind=1;
   end
   
   % gets timing of the sync in the EEG 
   EEG_sync_events = basic_EEG.event(EEG_sync_events_ix);
   EEG_sync_time_in_ms = EEG_sync_events(trigger_ind).latency_ms;
   
   % delete all other events that are not sync (can be noise from pressing
   % the light 
   subject_event_counter=2;
   event_ix_to_delete = 1:length(EEG_sync_events);
   event_ix_to_delete(trigger_ind)=[];
   basic_EEG = pop_editeventvals( basic_EEG , 'delete', event_ix_to_delete); 
   
   % duplicate EEG for relevant analyses
   EEG_presenter_identity_interval1 = basic_EEG;
   EEG_hammering_condition_interval1 = basic_EEG;
   EEG_presenter_identity_interval2 = basic_EEG;
   EEG_hammering_condition_interval2 = basic_EEG;
   EEG_presenter_identity_interval3 = basic_EEG;
   EEG_hammering_condition_interval3 = basic_EEG;
      
   % reads the display time from the txt file and add them to the EEG data 
   subj_group = subj_folder.name(end-1:end); 
   text_file = fullfile(subj_folder.folder,subj_folder.name, [subj_folder.name '.txt']);   
   all_text=fileread(text_file);
   all_lines = strsplit(all_text,'\n');
   initial_start_recording_time_stamp=-1;
   times_for_analyses = [];
   for line_IX=1:length(all_lines)
        line = all_lines{line_IX};
        line_parts = strsplit(line,'\t');
        if (length(line_parts)>4)
            
            % get the stimulus times and name from the file
            stim_times = line_parts{3};
            stim_times = ConvertSMITimeToMillisecond(stim_times);
            stim_name = line_parts{5};
            stim_name = stim_name(1:end-5);
            stim_ind_in_displays = find(strcmp(stim_name,display_names));
            
            % ignore if this is not one of the hammering displays
            if (~isempty(stim_ind_in_displays))
                
                % check the relevant trigger time from the list
                sync_time = sync_times(sync_times(:,1)==subj_number,2);
                if (isempty(sync_time))
                   error(['subject' num2str(subj_number) ' does not have a sync in the video']);
                end
                
                % checks if there 
                if (length(sync_time)==1)

                    % calculate the stimulus time relative to the trigger
                    stim_time_relative_to_trigger_in_ms = stim_times - (sync_time);
                    
                    % gets the stimulus time in "EEG time"
                    EEG_stim_time_in_ms = EEG_sync_time_in_ms+stim_time_relative_to_trigger_in_ms;
                    EEG_stim_time_in_ms_interval1 = EEG_stim_time_in_ms+display_interval_times_in_ms(stim_ind_in_displays,1); 
                    
                    % add the event to each EEG according to the relevant index                    
                    EEG_hammering_condition_interval1 = pop_editeventvals( EEG_hammering_condition_interval1 , 'insert', {subject_event_counter num2str(display_details_in_num(stim_ind_in_displays,2)) EEG_stim_time_in_ms_interval1/1000 EEG_stim_time_in_ms_interval1}); 
                    subject_event_counter=subject_event_counter+1;
                else
                    error('ERROR - Problem with sync times');
                end
            end
        end
   end
   
   % remove the sync event
   EEG_hammering_condition_interval1 = pop_editeventvals( EEG_hammering_condition_interval1 , 'delete', 1); 
   EEG_hammering_all =EEG_hammering_condition_interval1;
   
   % Extract epochs
   EEG_hammering_all = pop_epoch( EEG_hammering_all , {}, [-1.5 4]);
   pop_saveset(EEG_hammering_all , 'filepath', fullfile(subj_folder.folder,subj_folder.name), 'filename', [subj_folder.name '_epoched.set']);
end 