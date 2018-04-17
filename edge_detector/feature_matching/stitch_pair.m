function [panorama] = stitch_pair(im1, trans1, im2, trans2)
%STITCH_PAIR transfroms two images, stitches them, and returns a resultant
%   single image. 
%   Detailed explanation goes here

[xlim(1,:), ylim(1,:)] = outputLimits(trans1, [1 size(im1, 2)], [1 size(im1, 1)]);
[xlim(2,:), ylim(2,:)] = outputLimits(trans2, [1 size(im2, 2)], [1 size(im2, 1)]);
 
% Find the minimum and maximum output limits
xMin = min([1; xlim(:)]);
xMax = max([size(im1, 2); size(im2, 2); xlim(:)]);

yMin = min([1; ylim(:)]);
yMax = max([size(im1, 1); size(im2, 1); ylim(:)]);

% Width and height of panorama.
width  = round(xMax - xMin);
height = round(yMax - yMin);

blender = vision.AlphaBlender('Operation', 'Binary mask', ...
    'MaskSource', 'Input port');

% Create a 2-D spatial reference object defining the size of the panorama.
xLimits = [xMin xMax];
yLimits = [yMin yMax];
panoramaView = imref2d([height width], xLimits, yLimits);

% Transform I into the panorama.
warpedImage1 = imwarp(im1, trans1, 'OutputView', panoramaView);
warpedImage2 = imwarp(im2, trans2, 'OutputView', panoramaView);

% Generate a binary mask.
mask1 = imwarp(true(size(im1,1),size(im1,2)), trans1, ...
    'OutputView', panoramaView);
mask2 = imwarp(true(size(im2,1),size(im2,2)), trans2,...
    'OutputView', panoramaView);


% Initialize the "empty" panorama.
panorama = zeros([height width 3], 'like', im1);

% Overlay the warpedImage onto the panorama.
panorama = step(blender, panorama, warpedImage1, mask1);
panorama = step(blender, panorama, warpedImage2, mask2);
end

