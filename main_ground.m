% Notice:
% 
% This code is very much a draft. It should run properly but does not have 
% an updated version of the hypothesis grid and thus produces different 
% results and displays them differently. 
% 
% The intention was to test a model of a perfect room and how the flow 
% produced compares to that expected in an ideal situation. Assumptions 
% about being straight forward with constant velocity were maid but the code
% for projecting points to 3D had bugs. 











% Add paths
addpath('feature_matching');


% Declare globals
global features_s
global cam_p

% Declare structs
features_s = struct( 'x', [], 'y', [], ...  % 
    'descriptor', {} ... % Sift not rotation invariant
);

% % Define params
% cam_p = struct(...
%     'alpha', 0, ...  % camera angle with ground-plane
%     'H', 1, ... % height of camera in meters
%     'im_height_pxls', 270, ... % Vertical image width in pixels
%     'im_width_pxls', 480, ... % Vertical image width in pixels
%     'VFOV', 0.261799, ... % in radians  https://www.pcworld.com/article/3204445/android/google-pixel-2-features-specs-faq.html 
%     'f', 0.027 ... % in meters
% );
% 
% cam_p.VFOV = cam_p.im_height_pxls / (2*cam_p.f);



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
%     hold on
%         plot(flow,'DecimationFactor',[5 5],'ScaleFactor',10)
%     hold off 
%     
%     figure(2)
%     imshow(zeros(size(frameRGB)))
%     hold on
%         plot(flow,'DecimationFactor',[5 5],'ScaleFactor',10)
%     hold off 
%     
%     
%     
%     figure(3)
%     conv_mags = conv2(flow.Magnitude, ones(4, 4), 'full');
%     imshow(conv_mags./mean(mean(conv_mags)))
%     
    
    
    
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
        c_crop = c(r > cam_p.im_height_pxls*im_scaler*0.4);
        r_crop = r(r > cam_p.im_height_pxls*im_scaler*0.4);
        
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
%         % Split to segments above    
%         z = (cam_p.H*cam_p.im_height_pxls)./ ...
%             (((2.*(r./im_scaler)) - cam_p.im_height_pxls)*tan(cam_p.VFOV/2));
        
%         % Consider only values of points below im center
%         z(r  < (cam_p.im_height_pxls*im_scaler*0.8)) = 1;
%         z =  z.*27;

        points = [r_crop, c_crop, z] ;



% 
%         upscaled_r = ((r_crop));% ./ im_scaler) ).*cam_p.pxl_size;
%         upscaled_c = ((c_crop));% ./ im_scaler) ).*cam_p.pxl_size;
%     
%         points = get_pts3D([upscaled_r, upscaled_c], cam_p);
% 
%         figure(1000);
%         pbaspect([1 1 1]);
%         scatter3(points(:, 1), points(:, 2), points(:, 3));
% 
%         
        
        
        
        
        
        

        % Propagate 3d points
        propagate = points * eye(3) + [0, 0, 1];
     
        % Project 3d points onto the 2d image plane
        proj2d = propagate(:, 1:2) ./ propagate(:,3); % disregarding f for now
%         proj2d = cam_p.f .* propagate(:, 1:2) ./ propagate(:,3); 

%         proj2d = proj2d + [cam_p.im_height_pxls*im_scaler/2, cam_p.im_width_pxls*im_scaler/2];


%         % Display the propagation of features in an empty room model
%         figure(4);
%         scatter(c_crop, -r_crop, '.');
%         hold on     
%             scatter(proj2d(:, 2), -proj2d(:, 1), '.');
%         hold off
%         
        expectedflow = sqrt((r_crop - proj2d(:, 1)).^2 + (c_crop - proj2d(:, 2)).^2);
        expectedVy = (r_crop - proj2d(:, 1));
        expectedVx = (c_crop - proj2d(:, 2));    

        
        deltaflow = flow.Vy(linearidxs) - expectedVy;
        deltaflow = deltaflow./ abs(max(max(deltaflow)));
        
        hypothesis(1:size(frameGray, 1),1:size(frameGray, 2)) = 0.5;
        hypothesis(linearidxs) = hypothesis(linearidxs) + (sign(deltaflow)*0.45);
%         
%         hypothesis(hypothesis>0.55) = 1;
%         hypothesis(hypothesis<0.45) = 0;
        
        hypothesis(1:170,:) = 0.5;
        figure(10);
        imshow(hypothesis);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%         %%%%%%%%%%%% Substitue for room model %%%%%%%%%%%%%%%%%
%         % Notes average of the lower pixels does not seem to be reliable.
%        
%         
%         mean_Vx = flow.Vx(200:end, 100:380);
%         mean_Vx = mean(mean_Vx(mean_Vx > 0));
%         mean_Vy = flow.Vy(200:end, 100:380);
%         mean_Vy = mean(mean_Vy(mean_Vy > 0));
% 
%         eps = 0.001;
%         
%         figure(4);
% 
%         Vy_range = 1:size(flow.Vy, 1);
%         
%         dispflow = flow.Vy - mean_Vy;
%         dispflow = dispflow + abs(min(min(dispflow)));
%         dispflow = dispflow ./ max(max(dispflow));
%         hypothesis = dispflow;
%         
% %         hypothesis(1:size(frameGray, 1),1:size(frameGray, 2)) = 0.66;
% %         hypothesis(flow.Vy==0) = 0;
% %         hypothesis((flow.Vy < target_Vy-eps)&(flow.Vy~=0)) = 0.33;
% %         hypothesis((flow.Vy > target_Vy+eps)&(flow.Vy~=0)) = 0.99;
%             
%         
%         imshow(hypothesis);
% %         scatter(c, -r, '.');
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


        
        % Increase certainty       
        eps = 0.001;
        certainty_rate = 0.04;
        
        c_hyp = imresize(hypothesis, 0.5, 'bilinear');
        c_hyp(c_hyp > 0.5+eps) = 1;
        c_hyp(c_hyp < 0.5-eps) = -1;
        c_hyp(abs(c_hyp)~=1) = 0;
        
        
        if size(hyp, 1) ~= 0
            hyp = imwarp(hyp,trans, 'FillValues', 0.5);
            hyp = hyp(1:size(c_hyp,1),1:size(c_hyp,2));
            hyp = hyp + c_hyp.*certainty_rate;
        else
            hyp = ones(size(c_hyp)).*0.5;
        end

        if min(min(hyp)) < 0
            hyp = hyp + abs(min(min(hyp)));            
        end
%         hyp = hyp ./ max(max(hyp));
        
        
        figure(123)
        imshow(hyp)
        

    end
    prev_flow = flow;
    
end
