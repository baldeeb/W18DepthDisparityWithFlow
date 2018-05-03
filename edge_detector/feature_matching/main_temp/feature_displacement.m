% TODO: review geometric transform estimation
%       - SVD for transform estimation
%       - Ransac for evaluation of transform
%   equation for transform estimation is 

dataDir = fullfile('data');
imFileNames = {'elevator_1.png'; 'elevator_2.png'};

assert(size(imFileNames,1) == 2, 'Expecting 2 image names to match.');

coloredIm = {}; 

% Load image pair to a list
for idx = 1: size(imFileNames, 1)
    imFileName = imFileNames{idx};
    coloredIm{idx, 1} = imread(fullfile(dataDir, imFileName));
end


% Get sift features 
siftArray = get_array_sifts(coloredIm);
    

% Match pair of images using estimateGeometricTransform
%   -> uses SVD & MSAC to choose a best transform
% Get tansform and inliers of each sift set
[trans, inlierpoints1, inlierpoints2] = match_pair(siftArray);
eyeTrans = projective2d(eye(3));

figure;
showMatchedFeatures(coloredIm{2, 1}, coloredIm{1, 1}, ...
    inlierpoints2, inlierpoints1);