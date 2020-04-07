function [looking_matrices, looking_times]=ConstructSaccadeFixationsMatrices(looking_data,RADIUS)
% ConstructSaccadeFixationsMatrices creates a 3D matrix that includes all
% the pixels maps with the relevant gaze locations
%
%% Syntax
% [looking_matrices, looking_times]=ConstructSaccadeFixationsMatrices(looking_data,RADIUS)
%
%% Description
% ConstructSaccadeFixationsMatrices gets a data array that contains the
% fixation data and a radius of pixels around the fixation. It returns a
% set of binary matrices that includes the pixels with the gaze location
%
% Required input arguments.
% looking_data: data about the fixations - time of fixation and gaze location.
% RADIUS: the radius of pixel around the fixation location.
%
% Outputs.
% looking_matrices: a binary mXnXf matrix (n is the screen width, m is the screen
% hight, f represents the fixation number). 1 represents the gaze locations for each fixation
% looking times: array representing the times of each fixations (length if
% the number of fixations f
%%

% sets the size of the map according to the screen resolution
screen_map = zeros(1200,1920);

% initialize the looking times array
    looking_times = [];
    
% sets a counter for the matrix number (represent the number of fixation)
trial_matrices_counter = 1;

% go over all fixations in the data
for i=1:size(looking_data,1)
    
    % gets the gaze location in the fixation
    looking_array = looking_data(i,:);
    
    % gets the times of fixations
    looking_times = [looking_times looking_array(1:2)];
    
    % creates a matrix, according to the screen size with the radius around
    % the fixation location
    looking_matrix =GetLookingPixelsFromCoordAndRadius(looking_array(3:4), screen_map, RADIUS);
    
    % adds the fixation matrix to the output sturcture
    looking_matrices(:,:,trial_matrices_counter) = looking_matrix;
    
    % increase the matrix counter for next fixation
    trial_matrices_counter = trial_matrices_counter + 1;
end