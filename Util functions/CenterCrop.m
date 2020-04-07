function video = CenterCrop(video,inputSize)
% CenterCrop Resize the size of a video according to a given inputSize
%
%% Syntax
% video = CenterCrop(video,inputSize)
%
%% Description
% CenterCrop is used to match the size of a video to a given input size.
% This is used to match the video to the input of the GoogleNet.
% The function crops the longest edges of a video and resizes it have size inputSize.
%
% Required Input.
% video: the videos to match
% inputSize: The target input size 
sz = size(video);

% in case video is landscape
if sz(1) < sz(2)
    
    idx = floor((sz(2) - sz(1))/2);
    video(:,1:(idx-1),:,:) = [];
    video(:,(sz(1)+1):end,:,:) = [];

% in case video is portrait
elseif sz(2) < sz(1)
    
    idx = floor((sz(1) - sz(2))/2);
    video(1:(idx-1),:,:,:) = [];
    video((sz(2)+1):end,:,:,:) = [];
end

video = imresize(video,inputSize(1:2));
