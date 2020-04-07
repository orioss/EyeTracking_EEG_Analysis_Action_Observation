function CreateLookingProbabilityMaps(AOI_fixation_array)
% CreateLookingProbabilityMaps calculates and prints maps that reflect the
% probability of each group to look at specific area of the screen
%
%% Syntax
% CalculateAOISummary(AOI_array)
%
%% Description
% CreateLookingProbabilityMaps gets a data array that contains all the eye-tracking
% data from SMI BeGaze and perfroms probability map analyses - Figure 3A
%
% Required input arguments.
% AOI_fixation_array : MATLAB array containing all the data about
% fixations, given from SMI BeGaze
%
%%
% loads the valid subjects (ones that are included in the final set) and the children's ages
load('good_subjects.mat');

% gets the display information (conditions, actors, etc.)
[display_details_in_num, display_names, display_interval_times_in_ms] = GetESCDisplayMap();
display_interval_times_in_ms=[ones(size(display_interval_times_in_ms,1),1) display_interval_times_in_ms];

% read image files for figure
I1 = imread('Interval2.jpg');

% sets desired significant level
sig_level=0.05;

% sets the radius around the fixation to be used in probability
RADIUS=75;
minimal_time_duration=100;

% sets the figure for comparing children, adults and their difference
f=figure('units','normalized','outerposition',[0 0 1 1]);

% sets which interval to focus (in our study is from movement onset to
% intial grip which is the second interval.
interval=2;

% go over both groups
for group=1:2
    
    % sets a map and map counter for figure purposes
    interval_group_fixation_map = zeros(1200,1920);
    interval_group_fixation_prob_counter = 1;
    
    % gets the subject in the current group
    group_subjects = unique(AOI_fixation_array(AOI_fixation_array(:,1)==group-1,2));
    
    % go over subjects in group
    for subj_ix=1:length(group_subjects)
        
        % if the subject not part of the valid subject - skip
        if (~ismember(group_subjects(subj_ix),good_subjects(:,1)))
            continue;
        end
        
        % gets subject data
        subj_data = AOI_fixation_array(AOI_fixation_array(:,2)==group_subjects(subj_ix),:); 
        
        % gets all relevant trials
        subj_trials = unique(subj_data(:,4));
        
        % go over trials
        for trial_ix=1:length(subj_trials)
            
            % gets the type of display (efficient/inefficient)
            stim_ind = unique(subj_data(subj_data(:,4)==subj_trials(trial_ix),3)); 
            
            % gets the onsets and offsets of the interval
            interval_onset = display_interval_times_in_ms(stim_ind,interval);
            interval_offset = display_interval_times_in_ms(stim_ind,interval+1);
            
            % gets the fixations within the interval
            fixations = subj_data(subj_data(:,4)==subj_trials(trial_ix) & ...
                                  subj_data(:,11)>interval_onset &        ...
                                  subj_data(:,12)<interval_offset &       ...
                                  subj_data(:,12)>subj_data(:,11)+minimal_time_duration, [6 7 8 9]); % more than 50ms fixation

            % calculate the radius around each fixation in the interval and
            % increase the probability in the map accordingly
            for fixation_ix=1:size(fixations,1)
                c=round(fixations(fixation_ix,[1 2]))+1;
                curr_fixation_map = zeros(size(interval_group_fixation_map));
                curr_fixation_map(c(2),c(1)) = 1;
                radius_fixation = bwdist(curr_fixation_map);
                indices_fixation = radius_fixation >= RADIUS;
                indices_fixation = indices_fixation~=1;
                interval_group_fixation_map = interval_group_fixation_map + indices_fixation;
            end
            
            % increase the counter for probability purposes
            interval_group_fixation_prob_counter = interval_group_fixation_prob_counter +1;
        end
        
        % adds the probability to a structure with the group probability maps for calculating significance 
        % this is not needed for the figure
        eval(['group' num2str(group) '_interval_map(subj_ix,:,:) = interval_group_fixation_map/subject_interval_group_fixation_prob_counter;']);
    end   
    
    % calculates the probability map for the figure
    interval_group_fixation_map = interval_group_fixation_map/interval_group_fixation_prob_counter;
    
    % sets all relevant propoerties for the figure (background, size, etc.)
    eval(['bkgnd_fig = I' num2str(interval) ';']);
    subplot(1,3,group);
    imagesc([1 1620], [1 1000], bkgnd_fig, [0 1]); % aligning figure according to calibration area
    hold on
    im = imagesc([0 1920],[0 1200],interval_group_fixation_map);
    colormap([1 1 1]);
    im.AlphaData = 1-interval_group_fixation_map;
end

% calculating significant different between the maps
[h,p_to_fdr,ci,stats_multi]=ttest2(group1_interval_map,group2_interval_map,'tail','left');

% correct for multiple comparisons using FDR
p_to_fdr=squeeze(p_to_fdr);
[h_fdr]=fdr_bh(p_to_fdr,sig_level);

% plots the difference as the far right map
subplot(1,3,3);

% sets all the parameters and prints the difference map
eval(['bkgnd_fig = I' num2str(interval) ';']);
imagesc([1 1620], [1 1000], bkgnd_fig, [0 1]); % aligning figure according to calibration area
hold on
im = imagesc([0 1920],[0 1200],h_fdr);
colormap([1 1 1]);
im.AlphaData = 1-h_fdr;
ts_all_pixels = squeeze(stats_multi.tstat);
ts_sig_pixels = abs(ts_all_pixels(h_fdr==1));
disp(['minimum t: ' num2str(min(ts_sig_pixels))]);

% saves figure
print(f,'ProbabilityMaps.eps','-depsc');
print(f,'ProbabilityMaps.png','-dpng');