function all_AOI_data=GetAOIDataFromCSVs(data_dir)
% GetAOIDataFromCSV Converts eye-tracking data from SVMI CSV file to MATLAB file 

%% Syntax
% all_AOI_data=GetAOIDataFromCSVs(data_dir)
%
%% Description
% GetAOIDataFromCSV gets a folder that contains all the eye tracking data
% or a particular project or projects, reads all the CSV files in the
% folder and aggregates all of them to one MAT file that contains all the
% necessary data for AOI trnsitions analyses (Figure 2D).
%
% Required input arguments.
% data_dir : A path to a folder with all SMI CSV files (exported from SMI
% BeGaze folder)
%
%%
% reads all file in data folder
data_files = dir(fullfile(data_dir,'*.csv'));

% gets all the details regarding the displays - name of the video file,
% and the details about the display (e.g., conditions, actors, acting hand,
% etc.) in integers
[display_details_in_num, display_names, ~] = GetESCDisplayMap();

% Gets the name of the AOIs in the study, as defined in SMI BeGaze program
AOIs_right = {'Hammer';'Peg';'Right hand';'Left hand'; 'Face'; };
AOIs_left = {'Hammer';'Peg';'Left hand'; 'Right hand';'Face'; };
AOI_extra = 'Between Hammer-Peg';

% ges all the subject numbers that are valid in the study. Subject numbers
% must be identical to the numbers in the SMI BeGaze program.
load('good_subjects.mat');

% Initialize the data array that will be saved in the MAT file. 
% Array structure:
% group | participant | stim_ind | trial | event start | event end  | AOI | presenter | cond | pupil| 
all_AOI_data = [];

% go over all the files in the folder
for file=data_files'
    
    % import the CSV file into matlab
    data = csvimport(fullfile(file.folder,file.name));
    
    % Extracts only the relevant information from the SMI CSV file (features are in columns):
    % 1 = trial; 2 = stimulus; 5 = participant ; 10 = AOI name; 21 = event start; 22 = event end; 28 = pupil
    data = data(2:end,[1 2 5 10 21 22 28]);
    
    % go over each entity in the data (samples are in rows)
    for i=1:size(data,1)
        
       % gets the subject name as appeared in the SMI BeGaze program
       subject_name = data{i,3};
       
       % extract the group
       if (~strcmp(subject_name(end-1:end),'AD') & ~strcmp(subject_name(end-1:end),'04'))
           group_id = strfind(subject_name,'AD')
           if (isempty(group_id))
                group_id = strfind(subject_name,'04')
           end
           subject_name=subject_name(1:group_id+1)
       end
       subj_group = strcmp(subject_name(end-1:end),'AD');
              
       % extract the subject number
       subj_num = str2double(subject_name(end-4:end-3));
       if (~ismember(subj_num,good_subjects(:,1)))
         continue;
       end
       
       % extract the dominant hand of the subject (can be any other
       % feature, and loads the relevant AOIs accordingly)
       dominant_hand = good_subjects(good_subjects(:,1)==subj_num,2);
       if (dominant_hand==1)
           AOIs = AOIs_right;
       else
           AOIs = AOIs_left;
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
       
       % gets information about the the fixations
       fixation_start = data{i,5};
       fixation_end = data{i,6};
       
       % gets information about pupil dilation
       pupil = data{i,7};
       
       % gets information about AOI
       AOI_ind=find(strcmp(upper(data{i,4}),upper(AOIs)));  
       if (strcmp(upper(data{i,4}),upper(AOI_extra)))
          AOI_ind=1;
       end
       
       % if no information about sample - skip
       if (isempty(AOI_ind) | isempty(cond) | isempty(presenter)) 
           continue;
       end
       
       % save data in array 
       all_AOI_data = [all_AOI_data; subj_group subj_num              ...
                       stim_ind trial_num fixation_start fixation_end ...
                       AOI_ind presenter cond pupil];
    end
end
end