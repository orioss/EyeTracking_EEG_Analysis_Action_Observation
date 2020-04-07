function frame_index_in_fixations = FindFrameTimeIndex(current_frame_time, fixation_time_array)
% FindFrameTimeIndex gets a timing of the frame and a list of fixation
% times and checks which fixation is relevant to the frame
%
%% Syntax
% time_index = FindFrameTimeIndex(current_frame_time, fixation_time_array)
%
%% Description
% FindFrameTimeIndex finds the relevant fixation for a given frame. The
% function goes over all fixation times and checks to which fixation it is relevant
% by checking whether the timing of the current frame is within the
% fixation onset and offset
%
% Required Input.
% current_frame_time: timing of the frame to check
% fixation_time_array: array with all fixation times
%
% Output.
% frame_index_in_fixation: Gets which fixation is relevant to the current
% frame

% initialize th relevant fixation index
frame_index_in_fixations = length(fixation_time_array);

% go over all fixations
for i=1:length(fixation_time_array)-1
    
    % checks if the timing of the fixation is within the time period
    % between fixation onset and fixation offset
    if (current_frame_time>fixation_time_array(i) & current_frame_time<fixation_time_array(i+1))
        
        % if so - returns the relevant index in the fixation array
        frame_index_in_fixations = i;
        continue;
    end
end