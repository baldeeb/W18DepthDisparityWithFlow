function [X] = get_homography(points1,points2)
%GET_HOMOGRAPHY Summary of this function goes here
%   Detailed explanation goes here

% Reference: https://math.stackexchange.com/questions/494238/how-to-compute-homography-matrix-h-from-corresponding-points-2d-2d-planar-homog

points1NegHomo = -[points1, ones(size(points1, 1), 1)];
points1NegHomoWthZeros = [points1NegHomo, zeros(size(points1, 1), 3)];
first3cols = [points1NegHomoWthZeros; points1NegHomoWthZeros];
first3cols(1:2:8) = [zeros(size(points1, 1), 3), points1NegHomo];

last3cols = [points1, ones(size(points1, 1), 1)] .* ...
    [points2(:), points2(:), points2(:)];

A = [first3cols, last3cols];

[~, ~, V] = svd(A);

X = V(:, end);

end

