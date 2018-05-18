

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

while hasFrame(vidReader)
    tic; % timeit
    
    frameRGB = readFrame(vidReader);
    frameRGB = imresize(frameRGB, im_scaler);
    frameGray = rgb2gray(frameRGB);
    
    
    frameGray = imgaussfilt(frameGray, 3);
  
    flow = estimateFlow(opticFlow,frameGray); 
    
    figure(1)
%     imshow(frameRGB)
    imshow(zeros(size(frameRGB)))
    hold on
        plot(flow,'DecimationFactor',[5 5],'ScaleFactor',10)
    hold off 

    
    
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

        % Testing the use of differentiating flow    
        mags = flow.Magnitude;
        mags = imgaussfilt(mags, 2);
        mags(mags < 0.01) = NaN;
        mags = fillmissing(mags, 'nearest');
        % mags = imgaussfilt(mags, 1);
        mags = medfilt2(mags, [10, 10]);

        % mags = ordfilt2(mags,9,ones(3,3));
        % mags = imgaussfilt(mags);
        % mags = ordfilt2(mags,9,ones(7,7));



        % for i = 1:50
        %     mags = medfilt2(mags);
        %     mags = ordfilt2(mags,9,ones(3,3));
        % end



        % % Fill any unavailable data
        % for i = 1:size(mags,1)
        %     for j = 1:size(mags,2)
        %         n = 0;
        %         while mags(i, j + n) == 0
        %             if (j + n) < (size(mags, 2) - 1)
        %                 n = n + 1;
        %             else
        %                 break;
        %             end
        %         end
        %         while mags(i, j + n) == 0
        %             if (j + n) > 1
        %                 n = min(0, n - 1);
        %             else
        %                 break;
        %             end
        %         end
        %         mags(i, j) = mags(i, j + n);
        %     end
        % end

        % mags = conv2(mags, ones(5,5));
        % mags = ordfilt2(mags, 5, ones(3,3));
        % mags = ordfilt2(mags, 5, ones(3,3));

        % mags = imgaussfilt(mags, 2);
        % mags = edge(mags, 'Canny', [], 5);

        % mags = ordfilt2(mags, 11*11, ones(11,11));
        % mags = imgaussfilt(mags, 3);
        % mags = imgaussfilt(mags, 1);
        % mags = ordfilt2(mags, 25, ones(5,5));
        % mags = imgaussfilt(mags, 2);


        % mags = edge(mags, 'Sobel', [], 'horizontal');
        % mags = edge(mags, 'log', 0.018, 2);
        mags = edge(mags, 'log', [], 2);


        % dy = [-1 -1 -1; 0 0 0; 1 1 1]; % Derivative masks
        % mags  = conv2(mags, dy, 'same');
        % % mags = imgaussfilt(mags, 2);


        % TODO: Work on bayesian below 
        prev = bayesian_hyp(prev, mags, trans);





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
    prev_flow = flow;
    
    

toc; % timeit

end
