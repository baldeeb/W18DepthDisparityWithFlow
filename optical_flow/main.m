

% Add paths
addpath('feature_matching');


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
    'V', 1000, ... % Vertical image width in pixels
    'VFOV', 6 ... % in radians
);



% Match features in two consecutive images

% Calculate the disparity between the two

% Append to stats

% hypothesize,






vidReader = VideoReader('approaching_dropoff.mp4');

opticFlow = opticalFlowLK('NoiseThreshold',0.0009);
% opticFlow = opticalFlowHS;
prev_frameRGB = [];

while hasFrame(vidReader)
    frameRGB = readFrame(vidReader);
    frameRGB = imresize(frameRGB, 0.25);
    frameGray = rgb2gray(frameRGB);
  
    flow = estimateFlow(opticFlow,frameGray); 
    
    figure(1)
%     imshow(zeros(size(frameRGB)))
    imshow(frameRGB)
    hold on
        plot(flow,'DecimationFactor',[5 5],'ScaleFactor',10)
    hold off 
    
    figure(2)
    imshow(zeros(size(frameRGB)))
    hold on
        plot(flow,'DecimationFactor',[5 5],'ScaleFactor',10)
    hold off 
    
    
    
    figure(3)
    conv_mags = conv2(flow.Magnitude, ones(4, 4), 'full');
    imshow(conv_mags./mean(mean(conv_mags)))
    
    
    
%     if size(prev_frameRGB) ~= 0 
%         [trans, inlierpoints1, inlierpoints2] = ...
%             get_transform(prev_frameRGB, frameRGB);
%     end
%     prev_frameRGB = frameRGB;
    
end
