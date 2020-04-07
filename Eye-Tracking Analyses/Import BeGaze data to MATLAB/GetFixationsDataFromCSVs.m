function all_fixation_data=GetFixationsDataFromCSVs(data_dir)
% GetEventsDataFromCSVs Converts all data about fixations from SVMI 
% CSV file to MATLAB file 

%% Syntax
% all_event_data=GetAOIDataFromCSVs(data_dir)
%
%% Description
% GetEventsDataFromCSVs gets a folder that contains all the eye tracking data
% or a particular project or projects, reads all the CSV files in the
% folder according to SMI events format and aggregates all of them to one 
% MAT file that contains all the necessary data for probability map analyses
%
% Required input arguments.
% data_dir : A path to a folder with all SMI-events CSV files (exported from SMI
% BeGaze folder)
%
%%
% reads all file in data folder
data_files = dir(fullfile(data_dir,'*.csv'));

% gets all the details regarding the displays - name of the video file,
% and the details about the display (e.g., conditions, actors, acting hand,
% etc.) in integers
[display_details_in_num, display_names, display_interval_times_in_ms] = GetESCDisplayMap();


% ges all the subject numbers that are valid in the study. Subject numbers
% must be identical to the numbers in the SMI BeGaze program.
load('good_subjects.mat');


% Initialize the data array that will be saved in the MAT file. 
% Array structure:
% group | participant | stim_ind | trial | event start | event end  | AOI | presenter | cond | pupil| 
all_fixation_data = [];

% go over all the files in the folder  
for file=data_files'
    
    % import the CSV file into matlab
    data = csvimport(fullfile(file.folder,file.name));
    
    % Extracts only the relevant information from the SMI CSV file (features are in columns):
    % 1 = trial; 2 = stimulus; 5 = participant ; 8 = tracking rate; 10 =
    % event category; 13 = fixationx; 14 = fixationy; 22 = pupil;18 = event start; 19 = event end; 
    data = data(2:end,[1 3 6 8 10 18 19 22 13 14]);%[1 2 5 10 21 22 28]
    
    % go over each entity in the data (samples are in rows)
    for i=1:size(data,1)
        
       % gets the subject name as appeared in the SMI BeGaze program
       subject_name = data{i,3};
       
       % extract the group
       if (~strcmp(subject_name(end-1:end),'AD') & ~strcmp(subject_name(end-1:end),'04'))
           continue;
       end
       subj_group = strcmp(subject_name(end-1:end),'AD');
       
       % extract the subject number
       subj_num = str2double(subject_name(end-4:end-3));
       if (~ismember(subj_num,good_subjects(:,1)))
         continue;
       end
       
       % gets all the information about the sample - trial number, stimulus
       % type, condition, who is the actor
       trial_name = data{i,1};
       trial_num = str2double(trial_name(end-2:end));
       stim_name = data{i,2};
       stim_ind = find(strcmp(stim_name(1:end-4),display_names));  
       if (isempty(stim_ind))
           continue;
       end
       cond = display_details_in_num(stim_ind ,2);
       presenter = display_details_in_num(stim_ind ,3);
       
       % gets information about all eye-tracking events
       event_tracking_rate = data{i,4};
       event_category = data{i,5};
       fixation_x = data{i,6};
       fixation_y = data{i,7};
       
       % gets information about pupil dilation
       pupil = data{i,8};
       
       % gets information about fixations (onset, offset, location)
       start_fixation = data{i,9};
       if (~isnumeric(start_fixation))
           start_fixation=str2num(start_fixation);
       end
       end_fixation = data{i,10};
       if (~isnumeric(end_fixation))
           end_fixation=str2num(end_fixation);
       end
       
       % if no information about sample - skip
       if (isempty(cond) | isempty(presenter)) 
           continue;
       end
       
       %% Gets only the fixations data
       if (strcmp(event_category,'Fixation') && ~strcmp(fixation_x,'-') && ~strcmp(fixation_y,'-') && ~strcmp(pupil,'-') && ...
               ~isempty(start_fixation) && ~isempty(end_fixation))
             all_fixation_data = [all_fixation_data; subj_group subj_num              ...
               stim_ind trial_num cond str2num(fixation_x) str2num(fixation_y) str2num(pupil) ...
               str2num(event_tracking_rate) presenter start_fixation end_fixation]; 
       end
    end
end
end