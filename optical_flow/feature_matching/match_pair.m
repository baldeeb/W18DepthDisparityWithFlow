function [trans, inlierpoints1, inlierpoints2] = match_pair(siftArray)
    
% Tuning params
ransacPointCount = 100;  % 200;
MaxNumTrials = 5000;  % 80000;
Confidence = 99;
MaxDistance = 1.25;

% Compile 2D distance matrix for comparing features
sift_dists = dist2(siftArray{1, 1}, siftArray{2, 1});

% Obtain elements that are most similar
[~, sorted_idxs] = sort(sift_dists(:));
[selected_sift1, selected_sift2] = ind2sub(size(sift_dists), sorted_idxs);

colf1 = siftArray{1, 2}; rowf1 = siftArray{1, 3};
colf2 = siftArray{2, 2}; rowf2 = siftArray{2, 3};

select_coords1 = uint16([colf1(selected_sift1), rowf1(selected_sift1)]);
select_coords2 = uint16([colf2(selected_sift2), rowf2(selected_sift2)]);

% Get the relative transform
[trans, inlierpoints1, inlierpoints2] = estimateGeometricTransform(...
    select_coords1(1:ransacPointCount, :), ...
    select_coords2(1:ransacPointCount, :), ...
    'projective', ...   
    'MaxNumTrials', MaxNumTrials, ...
    'Confidence', Confidence, ...
    'MaxDistance', MaxDistance);

end

