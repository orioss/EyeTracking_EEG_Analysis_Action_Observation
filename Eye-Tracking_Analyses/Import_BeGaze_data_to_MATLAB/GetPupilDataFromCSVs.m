function pupil_data=GetPupilDataFromCSVs(data_dir)
% GetPupilDataFromCSVs Converts pupil data from SMI CSV file to MATLAB file 

%% Syntax
% pupil_data=GetPupilDataFromCSVs(data_dir)
%
%% Description
% GetPupilDataFromCSVs gets a folder that contains all the eye tracking
% summary data of a particular project or projects, reads all the CSV files in the
% folder and aggregates all the pupil data to one MAT file.
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
[display_details_in_num, display_names, display_interval_times_in_ms] = GetESCDisplayMap();

% ges all the subject numbers that are valid in the study. Subject numbers
% must be identical to the numbers in the SMI BeGaze program.
load('good_subjects.mat');

% Initialize the data array that will be saved in the MAT file. 
% Array structure:
% group | participant | stim_ind | trial | event start | event end  | AOI | presenter | cond | pupil| 
pupil_data = [];

% go over all the files in the folder
for file=data_files'
    
    % imports the CSV data
    data = csvimport(fullfile(file.folder,file.name));
    
    % gets the pupil datadata:
    data = data(2:end,[3 4 7 11 13]);
    
    % go over each summary entity in the data (summary entities are in rows)
    for i=1:size(data,1)
        
       % gets subject and group details
       subject_name = data{i,3};
       if (~strcmp(subject_name(end-1:end),'AD') & ~strcmp(subject_name(end-1:end),'04'))
           continue;
       end
       subj_num = str2double(subject_name(end-4:end-3));
       if (~ismember(subj_num,good_subjects(:,1)))
         continue;
       end       
       subj_group = strcmp(subject_name(end-1:end),'AD');
       
       % gets details about trial (display, actor, etc.)
       trial_name = data{i,1};
       trial_num = str2double(trial_name(end-2:end));
       stim_name = data{i,2};
       stim_ind = find(strcmp(stim_name(1:end-4),display_names));  
       if (isempty(stim_ind)) 
           continue;
       end
       cond = display_details_in_num(stim_ind ,2);
       presenter = display_details_in_num(stim_ind ,3);
       event_category = data{i,4};
       
       % gets the pupil size in each fixation
       pupil = data{i,5};
       if (isempty(cond) | isempty(presenter)) 
           continue;
       end
       
       % Add the pupil size (only in fixations) to data array
       if (~strcmp(pupil,'-'))
             pupil_data = [pupil_data; subj_group subj_num              ...
               stim_ind trial_num cond str2num(pupil)]; 
       end
    end
end