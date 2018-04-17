% This scrip assumes that all the images are of the same size


dataDir = fullfile('..','data');

% imFileNames = {'uttower_right.jpg'; 'uttower_left.jpg'};
imFileNames = {'pier/1.jpg'; 'pier/2.jpg'; 'pier/3.jpg'};
% imFileNames = {'hill/1.jpg'; 'hill/2.jpg'; 'hill/3.jpg'};
% imFileNames = {'ledge/1.jpg'; 'ledge/2.jpg'; 'ledge/3.jpg'};

coloredIm = {}; 
for idx = 1: size(imFileNames, 1)
    imFileName = imFileNames{idx};
    coloredIm{idx, 1} = imread(fullfile(dataDir, imFileName));
end

while size(coloredIm, 1) > 1
    % Get sift features 
    siftArray = get_array_sifts(coloredIm);
    
    % Get info on best pair to stitch and the required transformation
    [imPair, trans, inlierpoints1, inlierpoints2] = ...
        best_stitch_pair(siftArray);
    eyeTrans = projective2d(eye(3));
    
%     % Show matching points in the images for the report
%     figure;
%     showMatchedFeatures(coloredIm{imPair(1)},coloredIm{imPair(2)}, ...
%         inlierpoints1,inlierpoints2, 'montage');
    
    % Calculate residual
    residual = calculate_residual(inlierpoints1, trans, ...
        inlierpoints2, eyeTrans);
    
    % Print matched pair and residual
    fprintf('Pair1: %f\n', imPair(1))
    fprintf('Pair2: %f\n', imPair(2))
    fprintf('Residual: %f\n', residual)
    fprintf('Inlier Count: %f\n', size(inlierpoints1, 1))
    
    % Translate and stitch best pair
    panorama = stitch_pair(coloredIm{imPair(1)}, trans,...
        coloredIm{imPair(2)}, eyeTrans);
    
    % Remove the images that were stitched and add current panorama
    coloredIm{imPair(1), :} = panorama;
    coloredIm(imPair(2), :) = [];

    % Show stitched images
    figure, imshow(panorama), hold on
end