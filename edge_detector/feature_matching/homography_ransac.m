function [outputArg1,outputArg2] = homography_ransac(points1, points2)
%HOMOGRAPHY_RANSAC Summary of this function goes here
%   Detailed explanation goes here


max_itr = 80000;
max_dist = 1.25;

inlier_idxs

itr = 0;    
while itr < max_itr 
    % Choose 4 random indexes in the list or points
    
    % Get homography from the four points
    
    % Apply homography to the points1 
    
    % Use dist2 to get distances between translated points and originals
    
    % Get diagonal (diag) of the dists and get indexes of those that have
    % values less than max_dist
    
    % 
    
    
end

outputArg1 = inputArg1;
outputArg2 = inputArg2;
end

