

% Add paths
addpath('feature_matching');
addpath('line_fitting');

% % Declare globals
% global features_s
% global cam_p
% 
% % Declare structs
% features_s = struct( 'x', [], 'y', [], ...  % 
%     'descriptor', {} ... % Sift not rotation invariant
% );
% 
% cam_p = struct(...
%     'alpha', 0, ...  % camera angle with ground-plane
%     'H', 1, ... % height of camera in meters
%     'im_height_pxls', 1080, ... % Vertical image width in pixels
%     'im_width_pxls', 1920, ... % Vertical image width in pixels
%     'VFOV', 0.261799, ... % in radians
%     'f', 27, ... % in meters
%     'pxl_size', 1.4 * 10e-6 ...   % pixel size is 1.4 µm 
% );


im_scaler = 0.2;

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
    
        
    frameGray = imgaussfilt(frameGray, 3);
  
    flow = estimateFlow(opticFlow,frameGray); 
    
    figure(1111)
    imshow(frameRGB)

    figure(1)
%     imshow(frameRGB)
    imshow(zeros(size(frameRGB)))
    hold on
        plot(flow,'DecimationFactor',[5 5],'ScaleFactor',10)
    hold off 

    
    
    if size(prev_frameRGB) ~= 0 
        [trans, inlierpoints1, inlierpoints2] = ...
            get_transform(prev_frameRGB, frameRGB);
        prev_flow = flow;  % Substitute with a flag
    end

    
    if size(prev_flow) ~= 0 

        % Testing the use of differentiating flow    
        mags = flow.Magnitude;
        
%         mags(mags == 0) = NaN;
%         mags = fillmissing(mags, 'nearest');
       
        mags = medfilt2(mags, [10, 10]);
        mags = imgaussfilt(mags, 2);
         % mags = imgaussfilt(mags, 1);

     
        % mags = edge(mags, 'Sobel', [], 'horizontal');
        % mags = edge(mags, 'log', 0.018, 2);
        mags_edges = edge(mags, 'log', [], 2);

        prev = bayesian_hyp(prev, mags_edges, trans);


        %     disp_min = min(min(mags));
        % 
        %     if disp_min < 0
        %         mags = mags - disp_min;
        %     end
        % 
        %     % This will allow for a clear display of the results. 
        %     disp_max = max(max(mags));
        %     if disp_max > 1  
        %         mags = mags ./ disp_max;
        %     end



        figure(123)
        imshow(mags);



        % %ATTEMPTING TO FIT STRAIGHT LINES TO THE EDGES. 
        % imshow(imresize(mags, 0.5, 'nearest'));
        % 
        % fits = ransac_line_fitting(imresize(mags, 0.2, 'nearest'));
        % [x, y] = find(mags); 
        % % coeffs = polyfit(x, y, 1);
        % 
        % for coeffs = fits.'
        %     % Get fitted values
        %     fittedX = linspace(min(x), max(x), 600);
        %     fittedY = polyval(coeffs.', fittedX);
        %     % Plot the fitted line
        %     hold on;
        %     plot(fittedX, fittedY, 'r-', 'LineWidth', 3);
        % end
        % 
        % 
        
        
        
    end
    
    prev_frameRGB = frameRGB;
    
    
disp("Full runtime");
toc; % timeit

end
