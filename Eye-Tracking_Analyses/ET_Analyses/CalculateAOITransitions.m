function CalculateAOITransitions(AOI_array)
% CalculateAOIAverages Calculates transitions between diferent AOIs for
% each group (Figure 2D)
%
%% Syntax
% CalculateAOITransitions(AOI_array)
%
%% Description
% CalculateAOITransitions gets a data array that contains all the eye-tracking
% data from SMI BeGaze and calculates the shifts between pairs of AOIs for
% each group
%
% Required input arguments.
% all_AOI_data : MATLAB array containing all the SMI eye-tracking data
% (calculated in GetAOISummaryDataFromCSV)
%
%%
% loads the valid subject file
load('good_subjects');

% gets the display information (conditions, actors, etc.)
[display_details_in_num, display_names, display_interval_times_in_ms] = GetESCDisplayMap();
display_interval_times_in_ms=[ones(size(display_interval_times_in_ms,1),1) display_interval_times_in_ms];

% sets the maximal time for shift between the AOIs
transition_time_thresh=100;

% defines which AOI to include in the analysis
action_AOIs = [1 2 3 4 5];

% initialize array for calculating shifts using SPSS
all_subjects_transition_data_for_SPSS = [];

% go over each group
for group=1:2
    
    % create the group transition array for printing
    subject_transitions_for_printing = zeros(length(action_AOIs),length(action_AOIs));    
    
    % gets the subject numbers for each group
    group_subjs = unique(AOI_array(AOI_array(:,1)==group-1,2));
    
    % go over each subject in the group
    for s_ix=1:length(group_subjs)  
        
        % if the subject does not belong to the valid subjects - skip
        if (~ismember(group_subjs(s_ix),good_subjects(:,1)))
            continue;
        end
        
        % gets the conditions
        conds = unique(AOI_array(AOI_array(:,2)==group_subjs(s_ix),9));
        
        % initialize the transition array for the subject - this is
        % calculated per condition and then averaged
        subjects_transition_mat_across_conds = zeros(length(action_AOIs),length(action_AOIs),length(conds));
        
        % go over the differnt conditions (types of displays)
        for cond=1:length(conds)
            
            % initialize the subject transition array for the specific
            % display type
            subject_transition_mat = zeros(length(action_AOIs),length(action_AOIs));
            
            % gets the relevant trial numbers
            trials = unique(AOI_array(AOI_array(:,2)==group_subjs(s_ix) & AOI_array(:,9)==cond,4));
            
            % go over all the trials
            for t=1:length(trials)
                
                % gets the trial data for a specific subject, display type
                % and trial
                trial_data =  AOI_array(AOI_array(:,2)==group_subjs(s_ix) & AOI_array(:,9)==cond & AOI_array(:,4)==trials(t) ,[7 5 6 8 3]);
              
                % go over each fixation
                for fixation_idx=2:size(trial_data,1)
                    
                    % gets the AOI of the previous fixation
                     prev_AOI = trial_data(fixation_idx-1,1);
                     
                     % gets the AOI of the current fixation
                     current_AOI = trial_data(fixation_idx,1);
                     
                     % in case there is a transition - prev AOI and current AOI are different 
                     % AND both are in the relevant AOIs (in our study - all five AOIs 
                     % AND the time between the fixations is less than threshold (100ms) 
                     if (ismember(prev_AOI, action_AOIs) && ismember(current_AOI, action_AOIs) && ...     
                         prev_AOI~=current_AOI  && ...                                                    
                         trial_data(fixation_idx,2)-trial_data(fixation_idx-1,3)<transition_time_thresh)  
                     
                         % defines the AOI id in the AOIs array (in our study is the same)
                         AOI1_pos_in_action_AOI = find(action_AOIs==prev_AOI);
                         AOI2_pos_in_action_AOI = find(action_AOIs==current_AOI);
                         
                         % adds the transition to the subject matrix
                         % (symmentric transition from printing reasons 
                         subject_transition_mat(AOI1_pos_in_action_AOI,AOI2_pos_in_action_AOI)= ...
                             subject_transition_mat(AOI1_pos_in_action_AOI ,AOI2_pos_in_action_AOI)+1;
                         subject_transition_mat(AOI2_pos_in_action_AOI,AOI1_pos_in_action_AOI)= ...
                             subject_transition_mat(AOI2_pos_in_action_AOI ,AOI1_pos_in_action_AOI)+1;
                     end
                end
            end
             
            % calculates the transition average per trial
            subjects_transition_mat_across_conds(:,:,cond)=subject_transition_mat./length(trials);
        end
        
        % calculates the transition average across all display types
        subject_transitions = mean(subjects_transition_mat_across_conds,3);
        
        % add subject transition for printing the group transitions 
        subject_transitions_for_printing = subject_transitions_for_printing+subject_transitions;
        
        % adds the transition (as a row) to the data for checking
        % significance in SPSS
        subject_transitions = reshape(subject_transitions,1,size(subject_transitions,1)*size(subject_transitions,2));
        all_subjects_transition_data_for_SPSS = [all_subjects_transition_data_for_SPSS; group subject_transitions];
    end
    
    figure;
    circularGraph(subject_transitions_for_printing);
end

% saves the transition array for calculating signficance in SPSS
save('transition_stats_for_SPSS.mat','all_subjects_transition_data');