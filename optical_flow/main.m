




% Declare globals
global features_s
global cam_params

% Declare structs
features_s = struct( 'x', [], 'y', [], ...  % 
    'descriptor', {} ... % Sift not rotation invariant
);

% Define params
cam_params = struct(...
    'alpha', 0, ...  % camera angle with ground-plane
    'height', 1, ... % height of camera in meters
    'V', 235, ... % Vertical image width in pixels
    'VFOV', 6 ... % in radians
);



% Match features in two consecutive images

% Calculate the disparity between the two

% Append to stats

% hypothesize,