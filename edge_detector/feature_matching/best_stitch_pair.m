function [bestPair, bestTrans, bestInlierPts1, bestInlierPts2]...
    = best_stitch_pair(siftArray)
%BEST_STITCH_PAIR2 Takes in a list of matrices of sift vectors for
%   different images and returns the transform for mapping the images and
%   the inliers of each 
%   Detailed explanation goes here

combos = nchoosek(1:size(siftArray, 1),2);
max_inlier = 0; bestPair = [];
bestInlierPts1 = []; bestInlierPts2 = []; bestTrans = [];

% Tuning params
ransacPointCount = 200;
MaxNumTrials = 80000;
Confidence = 99;
MaxDistance = 1.25;

for idx = 1:size(combos)
    pair = combos(idx, :);
    
    sift_dists = dist2(siftArray{pair(1), 1}, siftArray{pair(2), 1});

    [~, sorted_idxs] = sort(sift_dists(:));
    [selected_sift1, selected_sift2] = ind2sub(size(sift_dists), sorted_idxs);

    colf1 = siftArray{pair(1), 2}; rowf1 = siftArray{pair(1), 3};
    colf2 = siftArray{pair(2), 2}; rowf2 = siftArray{pair(2), 3};
    
    select_coords1 = uint16([colf1(selected_sift1), rowf1(selected_sift1)]);
    select_coords2 = uint16([colf2(selected_sift2), rowf2(selected_sift2)]);
    
    [trans, inlierpoints1, inlierpoints2] = estimateGeometricTransform(...
        select_coords1(1:ransacPointCount, :), ...
        select_coords2(1:ransacPointCount, :), ...
        'projective', ...   
        'MaxNumTrials', MaxNumTrials, ...
        'Confidence', Confidence, ...
        'MaxDistance', MaxDistance);

    if max_inlier < size(inlierpoints1)
        max_inlier = size(inlierpoints1);
        bestPair = pair;
        bestInlierPts1 = inlierpoints1; 
        bestInlierPts2 = inlierpoints2; 
        bestTrans = trans;
    end
    
end

end

