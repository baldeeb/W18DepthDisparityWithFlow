function blobs = detectBlobsScaleImage(im)
% DETECTBLOBS detects blobs in an image
%   BLOBS = DETECTBLOBSCALEIMAGE(IM, PARAM) detects multi-scale blobs in IM.
%   The method uses the Laplacian of Gaussian filter to find blobs across
%   scale space. This version of the code scales the image and keeps the
%   filter same for speed. 
% 
% Input:
%   IM - input image
%
% Ouput:
%   BLOBS - n x 4 array with blob in each row in (x, y, radius, score)
%
% This code is part of:
%
%   CMPSCI 670: Computer Vision, Fall 2014
%   University of Massachusetts, Amherst
%   Instructor: Subhransu Maji
%
%   Homework 3: Blob detector

% Make image grayscale and double
g_im = rgb2gray(im);
dg_im = im2double(g_im);

% Useful values
height = size(dg_im, 1);
width = size(dg_im, 2);


% Constants & Tuning params 
n = 7;   % Number of levels. 
size_scaler = 1.4; 
base_sigma = 1.6 ; % Consistent with previous method 
sigma = 1;  %base_sigma * size_scaler;
filter_size = ceil(3 * sigma)*2 + 1;

% Instantiate valiables
blobs = [];
radii = zeros(n);
scaleSpace = zeros(size(im,1), size(im,2), n);
AbsMaxScaleSpace = zeros(size(im,1), size(im,2), n);

% Instantiate filter
filter = fspecial('log',filter_size, sigma) .* (sigma)^2;

for l = 1:n
    
    % Scale image
    inv_im_scaler = base_sigma*(size_scaler ^ l);
    scaled_im = imresize(dg_im, 1/inv_im_scaler);

    % Set radius
    radii(l) = inv_im_scaler * sqrt(2);    
    s = floor(2*radii(l));  % size of the side of the abs max filter
    if mod(s, 2) == 0; s = s + 1; end
    if s < 3; s = 3; end
    
    % Apply Laplacian of Gaussian
    filtered_im = conv2(scaled_im, filter, 'same'); 
    filtered_im = imresize(filtered_im, inv_im_scaler);
    scaleSpace(:, :, l)  = filtered_im(1:height, 1: width);
    
    % Spread local maximum    % NOTE: ordfilt2 is faster than colfilt.
    FilteredAbsMax = ordfilt2(abs(scaleSpace(:, :, l)), s^2, ones(s,s)); 
    
    % clear borders
    b = floor((2*floor(radii(l))+1)/2);
    FilteredAbsMax(1:b, :) = 0;
    FilteredAbsMax(height-b:height, :) = 0;
    FilteredAbsMax(:, 1:b) = 0;
    FilteredAbsMax(:, width-b:width) = 0;
 
    AbsMaxScaleSpace(:, :, l) = FilteredAbsMax; 
end
                            
LFAbsoluteScaleS = zeros(size(AbsMaxScaleSpace));
if mod(floor(n/2), 2) == 0
    nl = floor(n/2) + 1;
else
    nl = floor(n/2);
end
for i = 1:size(AbsMaxScaleSpace, 1)
    absSpace = reshape(AbsMaxScaleSpace(i, :, :), width, n);
    LFAbsoluteScaleS(i, :, :) = colfilt(absSpace, [1, ceil(3)], 'sliding', @max);
end

LFAScaleS = zeros(size(LFAbsoluteScaleS));
for i = 1:n
    s = LFAbsoluteScaleS(:, :, i);
    s(abs(scaleSpace(:, :, i)) ~= s) = 0;
    LFAScaleS(:, :, i) = s;
end

upper_bound = 0.02 ;

for l = 1:n
    % Keep only absolute max of points across layers. 
    layer = LFAScaleS(:, :, l);
%     layer(LFAScaleS(:, :, l) == 0) = 0;
    
    % Thresholding
    layer(layer < upper_bound) = 0;
    
    % Find the points and append Blobs
    [row, col] = find(layer ~= 0);
    score = layer(layer ~= 0);
    radius_col = repmat(radii(l), size(row));

    blobs = [blobs; cat(2, col, row, radius_col, abs(score))]; 

end

% size(blobs)