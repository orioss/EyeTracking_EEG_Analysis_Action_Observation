function CreateVideoReaders()
% CreateVideoReaders Creates video readers for each one of our displays 
%
%% Syntax
% CreateVideoReaders()
%
%% Description
% CreateVideoReaders creates a structure - video_readers with video readers
% to all the displays. The video readers needs to be created in advance
% because the MATLAB code runs in HPC and saves a lot of time 

% gets information about the displays
[display_details_in_num, display_names, display_interval_times_in_ms] = GetESCDisplayMap();

% initialize the struct variable
video_readers = struct;

% initialize the folder that contains all the displays
video_folder = 'Videos';

% go over each display
for d_ix=1:size(display_details_in_num,1)
    
    % creates a video reader for the display. This script must run BEFORE
    % running the CNN analysis and it must match the location of the videos
    eval(['video_readers.v' num2str(d_ix) ' = VideoReader(fullfile(' video_folder ',''' display_names{d_ix} '.avi''));']);
end

% Saves the video_readers to the same folder of the CNN analysis script
save('video_readers.mat','video_readers');

end