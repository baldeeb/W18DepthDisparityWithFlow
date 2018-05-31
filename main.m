

% Add paths
addpath('feature_matching');

im_scaler = 0.25;

% vidReader = VideoReader('data/approaching_dropoff.mp4');
% vidReader = VideoReader('data/street.mp4');
% vidReader = VideoReader('data/sweetwaters.mp4');
vidReader = VideoReader('data/sweetwaters_wall.mp4');

opticFlow = opticalFlowLK('NoiseThreshold',0.00009);  % 0.009

prev_frameRGB = [];
prev_flow = [];
hyp = [];prev = [];
trans = eye(3);

while hasFrame(vidReader)
    tic; % timeit
    
    frameRGB = readFrame(vidReader);
    frameRGB = imresize(frameRGB, im_scaler);
    frameGray = rgb2gray(frameRGB);

    % Reduce sharpness to improved flow calculation
    frameGray = imgaussfilt(frameGray, 3);
    
    % Get Lucas-Kanade optical flow
    flow = estimateFlow(opticFlow,frameGray); 
    
    figure(1)
    imshow(frameRGB)

%     figure(2)
% %     imshow(frameRGB)
%     imshow(zeros(size(frameRGB)))
%     hold on
%         plot(flow,'DecimationFactor',[5 5],'ScaleFactor',10)
%     hold off 

    
    % Get transform starting third frame
    if size(prev_frameRGB) ~= 0 
        [trans, inlierpoints1, inlierpoints2] = ...
            get_transform(prev_frameRGB, frameRGB);
        prev_flow = flow;  % Substitute with a flag
    end

    
    if size(prev_flow) ~= 0 

        % Testing the use of differentiating flow    
        mags = flow.Magnitude;
        
        % Spread Flow over featureless regions 
%         mags(mags == 0) = NaN;
%         mags = fillmissing(mags, 'nearest');
       
        mags = medfilt2(mags, [10, 10]);
        mags = imgaussfilt(mags, 2);

     
        % mags = edge(mags, 'Sobel', [], 'horizontal');
        % mags = edge(mags, 'log', 0.018, 2);
        mags_edges = edge(mags, 'log', [], 2);

        prev = bayesian_hyp(prev, mags_edges, trans);

        figure(3)
        imshow(mags)
        
    end
    
    prev_frameRGB = frameRGB;
    
    
disp("Full runtime");
toc; % timeit

end
