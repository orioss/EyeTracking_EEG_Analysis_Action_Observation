function all_AOI_data=GetAOISummaryDataFromCSVs(data_dir)
% GetAOISummaryFromCSV Converts eye-tracking summary from SVMI CSV file to MATLAB file 

%% Syntax
% all_AOI_data=GetAOISummaryFromCSVs(data_dir)
%
%% Description
% GetAOISummaryFromCSV gets a folder that contains all the eye tracking
% summary data of a particular project or projects, reads all the CSV files in the
% folder and aggregates all of them to one MAT file that contains all the
% necessary summary for eye-tracking analyses. This function differs from
% GetAOIDataFromCSVs because it matches to SMI Summary reports and not
% sample data. The summary data from SMI alread aggregates eye-tracking
% events and provides basic analyses on multiple measures as fixation time,
% dwell time, number of revisits, etc.
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

% Gets the name of the AOIs in the study, as defined in SMI BeGaze program
AOIs_right = {'Hammer';'Peg';'Right hand';'Left hand'; 'Face'; };%'Between Hammer-Peg'
AOIs_left = {'Hammer';'Peg';'Left hand'; 'Right hand';'Face'; };%'Between Hammer-Peg'
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
    
    % imports the CSV data
    data = csvimport(fullfile(file.folder,file.name));
    
    % gets the relevant summary data:
    % 1 = trial; 2 = stimulus; 5 = participant ; 8 = AOI name; 32 = %
    % fixation times percent; 22 = net dwell times percent; 30 = % dwell time percent; 
    % 28 = fixation counts; % 27 = revisits; % 26 = glances counts; 
    % 24 = diversion duration; 23 = glance duration
    data = data(2:end,[1 2 5 8 32 29 30 28 27 26 24 23]);
    
    % go over each summary entity in the data (summary entities are in rows)
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
       
       % checks if the subject is one of the valid subjects in the study
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
       
       % gets all the the relevant summaries, convert all to numbers   
       trial_name = data{i,1};
       trial_num = str2double(trial_name(end-2:end));
       stim_name = data{i,2};
       stim_ind = find(strcmp(stim_name(1:end-4),display_names));  
       if (isempty(stim_ind))
           continue;
       end
       cond = display_details_in_num(stim_ind ,2);
       presenter = display_details_in_num(stim_ind ,3);
       fixationTimePercent = data{i,5};
       netDwellTimePercent = data{i,6};
       dwellTimePercent = data{i,7};
       fixationCountes = data{i,8};
       revisits = data{i,9};
       glancesCounts = data{i,10};
       diversion_duration = data{i,11};
       glances_duration = data{i,12};
       AOI_ind=find(strcmp(upper(data{i,4}),upper(AOIs))); 
       
       % dealing with typos in our study
       if (strcmp(upper(data{i,4}),upper(AOI_extra)))
          AOI_ind=1;
       end
       if (strcmp(upper(data{i,4}),'Fce'))
          AOI_ind=5;
       end


       % validity check for the measures
      if ischar(revisits) 
          if strcmp(revisits,'-')
            revisits=0;
          else
              revisits=str2num(revisits);
          end
      end
     if ischar(glancesCounts) 
          if strcmp(glancesCounts,'-')
            glancesCounts=0;
          else
              glancesCounts=str2num(glancesCounts);
          end
     end
     
     % if not valid data - skip summary
     if (isempty(AOI_ind) | isempty(cond) | isempty(presenter)) 
           continue;
     end
     
     % insert all summaries to data array
     all_AOI_data = [all_AOI_data; subj_group subj_num              ...
                     stim_ind trial_num AOI_ind presenter cond      ...
                     fixationTimePercent netDwellTimePercent        ...
                     dwellTimePercent fixationCountes revisits      ...
                     glancesCounts diversion_duration glances_duration];
    end
end