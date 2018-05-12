

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

vidReader = VideoReader('approaching_dropoff.mp4');
% vidReader = VideoReader('street.mp4');
% vidReader = VideoReader('sweetwaters.mp4');
% vidReader = VideoReader('sweetwaters_wall.mp4');
opticFlow = opticalFlowLK('NoiseThreshold',0.009);

prev_frameRGB = [];
prev_flow = [];
hyp = [];

while hasFrame(vidReader)
    frameRGB = readFrame(vidReader);
    frameRGB = imresize(frameRGB, im_scaler);
    frameGray = rgb2gray(frameRGB);
  
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
% %         NOTES: 
% %           was working before 
% %           algorithm change or param change caused this to fail

        % Find z considering points to belong to ground plane
        upscaled_r = (r_crop ./ im_scaler).*cam_p.pxl_size;
        f = (cam_p.im_height_pxls*cam_p.pxl_size) ./ (tan(cam_p.VFOV/2));
        tan_beta = ((upscaled_r - (cam_p.im_height_pxls*cam_p.pxl_size)/2)) ./ f;
        z = cam_p.H ./ tan_beta;
        z = z.* 10e-6;


        points = [r_crop, c_crop, z] ;
        
        
        
        

        % Propagate 3d points
        propagate = points * eye(3) + [0, 0, 1];
     
        % Project 3d points onto the 2d image plane
        proj2d = propagate(:, 1:2) ./ propagate(:,3); % disregarding f for now
%         proj2d = cam_p.f .* propagate(:, 1:2) ./ propagate(:,3); 

%         proj2d = proj2d + [cam_p.im_height_pxls*im_scaler/2, cam_p.im_width_pxls*im_scaler/2];


        % Display the propagation of features in an empty room model
%         figure(4);
%         scatter(c_crop, -r_crop, '.');
%         hold on     
%             scatter(proj2d(:, 2), -proj2d(:, 1), '.');
%         hold off
        
%         expectedflow = sqrt((r_crop - proj2d(:, 1)).^2 + (c_crop - proj2d(:, 2)).^2);
%         expectedVy = (r_crop - proj2d(:, 1));
%         expectedVx = (c_crop - proj2d(:, 2));    
%         
        
        expfloweps = 0.15;
        expectedVy = 0.35;
        
        deltaflow = abs(flow.Vy(linearidxs)) - expectedVy;
%         deltaflow = deltaflow./ abs(max(max(deltaflow)));
        
        hypothesis(1:size(frameGray, 1),1:size(frameGray, 2)) = 0.5;
        hypothesis(linearidxs) = hypothesis(linearidxs) + (deltaflow*0.45);
%         
%         hypothesis(hypothesis>0.55) = 1;
%         hypothesis(hypothesis<0.45) = 0;
        
        figure(10);
        imshow(hypothesis);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


        
        % Increase certainty       
        eps = 0.001;
        certainty_rate = 0.04;
        
        curr_hyp = imresize(hypothesis, 0.6, 'bilinear');
        curr_hyp(curr_hyp > 0.5+eps) = 1;
        curr_hyp(curr_hyp < 0.5-eps) = 0;  %-1;
        curr_hyp(abs(curr_hyp)~=1) = 0;
        
        
        if size(hyp, 1) ~= 0
            hyp = imwarp(hyp,trans, 'FillValues', 0.5);
            hyp = hyp(1:size(curr_hyp,1),1:size(curr_hyp,2));
            hyp = hyp + curr_hyp.*certainty_rate;
        else
            hyp = ones(size(curr_hyp)).*0.5;            
            hyp = hyp(1:size(curr_hyp,1),1:size(curr_hyp,2));
            hyp = hyp + curr_hyp.*certainty_rate;
        end

        if min(min(hyp)) < 0
            disp_hyp = hyp + abs(min(min(hyp)));            
        else 
            disp_hyp = hyp;
        end
%         hyp = hyp ./ max(max(hyp));
        
        
        figure(123)
        imshow(disp_hyp)
%         

    end
    prev_flow = flow;
    
end