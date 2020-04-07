function CalculatePupilDilation(pupil_array)
% CalculatePupilDilation calculate changes in pupil size between displays and groups
%
%% Syntax
% CalculatePupilDilation(pupil_array)
%
%% Description
% CalculatePupilDilation gets a data array that contains the pupil size at
% any moment. The function calculates the changes in pupil size compare
% to baseline in each display type (in our study - efficient/inefficient)
% and for each group. It calculates significant difference (FDR correction
% for multiple comparisons) and prints a figure with the differences.
%
% Required input arguments.
% pupil_array : MATLAB array containing the pupil data from SMI BeGaze
%
%%

% gets the array of valid subjects in the study
load('good_subjects.mat');

% gets the display information (conditions, actors, etc.)
[display_details_in_num, display_names, display_interval_times_in_ms] = GetESCDisplayMap();
display_interval_times_in_ms=[ones(size(display_interval_times_in_ms,1),1) display_interval_times_in_ms];

% divides the display to number of bins to calculate the pupil size, and
% average the pupil size within each bin 
num_of_bins = 180;
display_interval_times_in_bins = [(display_interval_times_in_ms(:,3)-display_interval_times_in_ms(:,2))./((display_interval_times_in_ms(:,4)--display_interval_times_in_ms(:,2))/num_of_bins)];
display_interval_times_in_bins = mean(display_interval_times_in_bins,1);

for group=1:2

    % creates a figure for the group
    figure;
    
    % initialize array for calculating statistics of changes in pupil size 
    % per group between the displays
    for_stats = [];

    % initialize an array for averaging the pupil size across trials 
    num_of_trials_in_each_cond = [];

    % go over the conditions (= display types, efficient/inefficient)
    for cond_ix=[1 3]
        
        % gets all the subjects of particular group
        group_subjects = unique(pupil_array(pupil_array(:,1)==group-1,2));

        % initialize an array that contains the change in pupil size per subject
        pupil_subj_data = [];
        
        % initialize an array that contains the amount of excluded trials
        % per subject
        total_amount_bad_trials_per_subject = [];
        
        % go over subjects
        for subj_ix=1:length(group_subjects)
            
            % initialize amount of bad trials for current subject
            how_much_bad_trials = 0;
            
            % checks if the subject is valid. Skip if not.
            if (~ismember(group_subjects(subj_ix),good_subjects(:,1)))
                continue;
            end
            
            % gets the subject pupil data
            subj_data = pupil_array(pupil_array(:,2)==group_subjects(subj_ix),:); 
            
            % gets the trials with the specific display for the particular
            % subject
            subj_trials = unique(subj_data(:,4));
            
            % initialize array that will contain the trials data binned 
            trial_data_cond=[];
            
            % go over trials 
            for trial_ix=1:length(subj_trials)
                
                % gets the display type and check if it's the current one 
                stim_ind = unique(subj_data(subj_data(:,4)==subj_trials(trial_ix),3)); 
                cond = unique(subj_data(subj_data(:,4)==subj_trials(trial_ix),5)); 
                if (cond~=cond_ix)
                    continue;
                end
                stim_ind = stim_ind(stim_ind>=1);
                
                % gets trial data and verify it's valid (not more than 25% missing data)
                trial_data = subj_data(subj_data(:,4)==subj_trials(trial_ix),6)';
                trial_data = trial_data(trial_data>3);
                if (length(trial_data)<170) 
                    how_much_bad_trials = how_much_bad_trials + 1;
                    continue;
                end

                % gets the movement onset time and calculates the pupil
                % size in baseline
                move_onset_time = display_interval_times_in_ms(stim_ind,2)/display_interval_times_in_ms(stim_ind,4)*length(trial_data);
                baseline_pupil = mean(trial_data(1:round(move_onset_time/4)));
                
                % gets the data from movement onset until end of movement
                trial_data = trial_data(move_onset_time:end);
                
                % bins the data from movement onset until end of movement
                time_points = linspace(1,size(trial_data ,2)+1,num_of_bins+1);
                time_points = round(time_points);
                trial_data_binned=[];
                for i=1:length(time_points)-1
                    trial_data_binned = [trial_data_binned mean(trial_data(time_points(i):time_points(i+1)-1))];
                end
                
                % verifies there is no missing data in particular bin
                % (nans) and if not - adds it to the binned trial array
                if (max(isnan(trial_data_binned))==0)
                    trial_data_cond = [trial_data_cond; trial_data_binned/baseline_pupil-1];
                end
            end
            
            % if there is data from the trial - adds it to the subject 
            if (~isempty(trial_data_cond))
                pupil_size_over_time = (mean(trial_data_cond,1));
                pupil_subj_data = [pupil_subj_data;  pupil_size_over_time];
            end
            
            % updates the number of bad trials in the current subject
            total_amount_bad_trials_per_subject = [total_amount_bad_trials_per_subject; how_much_bad_trials]; 
        end  
        
        % plots the data (including error bars)
        errorbar(mean(pupil_subj_data),std(pupil_subj_data)/sqrt(size(pupil_subj_data,1)));
        ylim([-0.025 0.05]);
        
        % updates the stats array for calculating signficance
        for_stats = [for_stats; pupil_subj_data];
        num_of_trials_in_each_cond = [num_of_trials_in_each_cond; size(pupil_subj_data,1)];
        hold on;
        line([display_interval_times_in_bins display_interval_times_in_bins],[min(mean(pupil_subj_data)) max(mean(pupil_subj_data))],'linewidth',3);
    end
    
    % calculates differences between displays (efficient/inefficient) and
    % correct for multiple comparisons using FDR
    for_stats1 = for_stats(1:num_of_trials_in_each_cond(1),:);
    for_stats2 = for_stats(num_of_trials_in_each_cond(1)+1:end,:);
    [h,p,ci,stats]=ttest2(for_stats1,for_stats2,0.05);
    [h_fdr]=fdr_bh(p,0.05);
    plot(h);
    max(p(h==1))
    max(stats.tstat(h==1))
end