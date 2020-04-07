function PrepareLookingVideosForCNN(AOI_event_array)
% PrepareLookingVideosForCNN creates "looking videos" from fixations data (received
% from SMI BeGaze program) and prepares them as inputs to the CNN
% classifier
%
%% Syntax
% PrepareLookingVideosForCNN(AOI_event_array)
%
%% Description
% PrepareLookingVideosForCNN creates the data structure that will be used for the
% CNN analysis. The function gets data that includes all the fixations, the
% gaze locations and the timing of each fixation. It creates a "looking
% video" and saves it as an array for input to the CNN classifier. The data
% is saved at the individual level (the classification analysis is at the
% individual level
%
% Required Input.
% AOI_event_array:  MATLAB array containing all the data about
% fixations, given from SMI BeGaze

% gets the display information (conditions, actors, etc.)
[display_details_in_num, display_names, display_interval_times_in_ms] = GetESCDisplayMap();

% loads the video_readers structure that contains video reader to each
% display
load('video_readers');

% sets the size of the radius around gaze location in each fram
RADIUS=75;

% Creates a folder that will contain subjects' input to the classifier
mkdir('DataForCNN');
for group=1:2
    
    % gets the list of subjects in the group
    group_subjects = unique(AOI_event_array(AOI_event_array(:,1)==group-1,2));
    
    % go over all subjects
    for subj_ix=1:length(group_subjects)
        
        % gets the subject data from the input data
        subj_data = AOI_event_array(AOI_event_array(:,2)==group_subjects(subj_ix),:); 
        
        % gets the trial numbers 
        subj_trials = unique(subj_data(:,4));
                
        % go over all trials 
        for trial_ix=1:length(subj_trials)
            
            % gets information about trial (display, actor, etc.) to use in
            % the classification as a label to the trial
            stim_ind = unique(subj_data(subj_data(:,4)==subj_trials(trial_ix),3)); 
            trial_cond = unique(subj_data(subj_data(:,4)==subj_trials(trial_ix),5)); 
            presenter = unique(subj_data(subj_data(:,4)==subj_trials(trial_ix),6)); 
            
            % gets the relevant video reader according to the type of display
            trial_video_reader = video_readers.(['v' num2str(stim_ind)]);
            
            % gets the fixation data for the trial
            sub_looking_data = subj_data(subj_data(:,4)==subj_trials(trial_ix),8:end); 
            
            % construct a structure that includes the gaze location (according
            % to a given radius) for each fixation and gets the timing of
            % each fixation
            [looking_matrices, looking_times]=ConstructSaccadeFixationsMatrices(sub_looking_data,RADIUS);
            
            % go over the display, frame by frame and creates a looking
            % video for the trial
            trial_video_reader.CurrentTime=0;
            trial_video_reader.readFrame();    
            frame_counter=1;
            while (trial_video_reader.hasFrame)
                
                % gets the timing of the frame in the video
                frame_time = trial_video_reader.CurrentTime*1000;
                
                % checks which fixation is relevant to the frame
                index_of_frame_in_fixations = FindFrameTimeIndex(frame_time, looking_times);
                
                % reads the current video frame
                frame_image = imresize(trial_video_reader.readFrame(),[1200 1920]);
                
                % if the frame is after any fixation data - skip
                if (index_of_frame_in_fixations>size(looking_matrices,3))
                    continue;
                end
                
                % gets the relevant matrix (that includes the gaze location) for the frame
                looking_image = squeeze(looking_matrices(:,:,index_of_frame_in_fixations));
                
                % gets the colors data of the original frame 
                looking_frame_image_x=frame_image(:,:,1);
                looking_frame_image_y=frame_image(:,:,2);
                looking_frame_image_z=frame_image(:,:,3);
                
                % make all the pixels that are not within the gaze location
                % (and its radius) - black
                looking_frame_image_x(looking_image==0)=0;
                looking_frame_image_y(looking_image==0)=0;
                looking_frame_image_z(looking_image==0)=0;
                
                % make all the pixels within the gaze location radius
                % identical to the orignal frame
                looking_frame_image_new(:,:,1)=looking_frame_image_x;
                looking_frame_image_new(:,:,2)=looking_frame_image_y;
                looking_frame_image_new(:,:,3)=looking_frame_image_z;
                
                % write the new looking video frame to the input to the classifier
                trial_data_for_CNN{frame_counter} = looking_frame_image_new;
                
                frame_counter=frame_counter+1;
            end 
            
            % saves the input to the classifier for the specific subject
            % and specific trial
            save(fullfile('F:\ESC_CNN',['group_' num2str(group) '_subj_' num2str(subj_ix) '_trial_' num2str(subj_trials(trial_ix)) '.mat']),'trial_data_for_CNN','trial_cond','presenter','stim_ind');
        end
     end   
end

