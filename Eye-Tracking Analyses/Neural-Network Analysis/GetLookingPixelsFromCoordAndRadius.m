function indices_fixation=GetLookingPixelsFromCoordAndRadius(fixation_coord, curr_frame, RADIUS)
% GetLookingPixelsFromCoordAndRadius Creates a frame with a gaze location
% and returns all the pixels around the gaze location within a given radius
%
%% Syntax
% indices_fixation=GetLookingPixelsFromCoordAndRadius(fixation_coord, curr_frame, RADIUS)
%
%% Description
% GetLookingPixelsFromCoordAndRadius Creates a frame with a gaze location
% and returns all the pixels around the gaze location within a given radius
%
% Required input arguments.
% fixation_coord: gaze location during the fixation.
% curr_frame: current frame with the gaze location (mainly for size purposes).
% RADIUS: the radius of pixel around the fixation location.
%
% Outputs.
% indices_fixation: indices of all the pixels in the frame that are
% adjacent to the fixation location
%%

% calculates the gaze location
c=round(fixation_coord)+1;

% sets boundried according to the size of the current frame
if (c(1)<=0)
    c(1)=1;
end
if (c(2)<=0)
    c(2)=1;
end
if (c(1)>size(curr_frame,2))
    c(1)=size(curr_frame,2);
end
if (c(2)>size(curr_frame,1))
    c(2)=size(curr_frame,1);
end

% sets a fixation map aronud the gaze location
curr_fixation_map = zeros(size(curr_frame));

% mark pixel of gaze location
curr_fixation_map(c(2),c(1)) = 1;

% gets all pixels within the radius size
radius_fixation = bwdist(curr_fixation_map);

% gets all pixels that are not within the radius size
indices_fixation = radius_fixation >= RADIUS;

% marks all the pixels within the radius
indices_fixation = indices_fixation~=1;

end