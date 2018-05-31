function [trans, inlierpoints1, inlierpoints2] = get_transform(im1,im2)
    % TODO: coppy what is in feature_displacement into this and have it
    % return the transform. 
    
    % Use that transform to propagate the data from the optical transform
    % and update hypotheses in the regions of the image.

    
    
    
    
    % TODO: review geometric transform estimation
    %       - SVD for transform estimation
    %       - Ransac for evaluation of transform
    %   equation for transform estimation is 

    coloredIm{1, 1} = im1;
    coloredIm{2, 1} = im2;

    % Get sift features 
%     disp("Getting sift features: "); tic;
    siftArray = get_array_sifts(coloredIm);
%     toc
    
    % Match pair of images using estimateGeometricTransform
    %   -> uses SVD & MSAC to choose a best transform
    % Get tansform and inliers of each sift set
%     disp("Getting Transform: "); tic;
    [trans, inlierpoints1, inlierpoints2] = match_pair(siftArray);
%     toc
    
% %     TEMP
%     figure(99);
%     showMatchedFeatures(coloredIm{2, 1}, coloredIm{1, 1}, ...
%     inlierpoints2, inlierpoints1);
end

