

% Add paths
addpath('feature_matching');


% Declare globals
global features_s
global cam_p

% Declare structs
features_s = struct( 'x', [], 'y', [], ...  % 
    'descriptor', {} ... % Sift not rotation invariant
);

cam_p = struct(...
    'alpha', 0, ...  % camera angle with ground-plane
    'H', 1, ... % height of camera in meters
    'im_height_pxls', 1080, ... % Vertical image width in pixels
    'im_width_pxls', 1920, ... % Vertical image width in pixels
    'VFOV', 0.261799, ... % in radians
    'f', 27, ... % in meters
    'pxl_size', 1.4 * 10e-6 ...   % pixel size is 1.4 µm 
);
im_scaler = 0.25;

vidReader = VideoReader('data/approaching_dropoff.mp4');
% vidReader = VideoReader('data/street.mp4');
% vidReader = VideoReader('data/sweetwaters.mp4');
% vidReader = VideoReader('data/sweetwaters_wall.mp4');
opticFlow = opticalFlowLK('NoiseThreshold',0.0009);

prev_frameRGB = [];
prev_flow = [];
hyp = [];

while hasFrame(vidReader)
    frameRGB = readFrame(vidReader);
    frameRGB = imresize(frameRGB, im_scaler);
    frameGray = rgb2gray(frameRGB);
  
    frameGray = imgaussfilt(frameGray, 2);
    flow = estimateFlow(opticFlow,frameGray); 
    
%     figure(1)
%     imshow(frameRGB)
%     imshow(zeros(size(frameRGB)))
%     hold on
%         plot(flow,'DecimationFactor',[5 5],'ScaleFactor',10)
%     hold off 

    
    
    if size(prev_frameRGB) ~= 0 
        [trans, inlierpoints1, inlierpoints2] = ...
            get_transform(prev_frameRGB, frameRGB);
    end
    prev_frameRGB = frameRGB;
    
    
    
    
    
    
% Attempting to project the points as though they were on the groundplane
% Finding the disparity between the original and the prjection i
% TODO: Shift the points to the camera coordinate system before
% propagating.

    
    if size(prev_flow) ~= 0 
        % Get all points with non zero magnitude flow
        [r, c] = find(prev_flow.Magnitude);
        
        % Filter out all points above camera height
        c_crop = c(r < cam_p.im_height_pxls*im_scaler*0.6);
        r_crop = r(r < cam_p.im_height_pxls*im_scaler*0.6);
        
        % Get linear indexces
        linearidxs = sub2ind(size(prev_flow.Magnitude), r_crop, c_crop); 
        
        
        
        
        
        %%%%% Create empty room model and threashold disperity%%%%
        
%         expfloweps = 0.15;
        expectedVy = 0.5;  %0.35;
        
        deltaflow = abs(flow.Vy(linearidxs)) - expectedVy;
        
        hypothesis(1:size(frameGray, 1),1:size(frameGray, 2)) = 0.5;
        hypothesis(linearidxs) = hypothesis(linearidxs) + (deltaflow*0.45);
        
        figure(10);
        imshow(hypothesis);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


        
        % Increase certainty       
        eps = 0.001;
        certainty_rate = 1;  %0.04;
        
        curr_hyp  = ordfilt2(hypothesis,9,ones(3,3));
        
        
        
        curr_hyp(curr_hyp > 0.5+eps) = 1;
        curr_hyp(curr_hyp < 0.5-eps) = -0.5;  %-1;
        curr_hyp(abs(curr_hyp)~=1) = 0;  % 0;
        
        
        if size(hyp, 1) ~= 0
            hyp = imwarp(hyp,trans, 'FillValues', 0.5);
            hyp = hyp(1:size(curr_hyp,1),1:size(curr_hyp,2));
            hyp = hyp + curr_hyp.*certainty_rate;
        else
            hyp = ones(size(curr_hyp)).*0.5;            
            hyp = hyp(1:size(curr_hyp,1),1:size(curr_hyp,2));
            hyp = hyp + curr_hyp.*certainty_rate;
        end
        
        disp_hyp = hyp;  % hyp(1:2:end, 1:2:end);
        
        disp_min = min(min(disp_hyp));
        disp_max = max(max(disp_hyp));
        
        if disp_min < 0
%             disp_hyp = disp_hyp + abs(disp_min);
              disp_hyp(disp_hyp < 0) = 0;
        end
        
        % This will allow for a clear display of the results. 
        if disp_max > 1  
            disp_factor = disp_max - disp_min;
            disp_hyp = disp_hyp ./ disp_factor;
        end
        
        
        figure(123)
        imshow(ordfilt2(disp_hyp, 25, ones(5, 5)))
     

    end
    prev_flow = flow;
    
end
