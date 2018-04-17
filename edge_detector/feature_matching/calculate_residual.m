function [residual] = calculate_residual(points1, trans1, points2, trans2)
%CALCULATE_RESIDUAL Assuming the matched points are in order 
%   Detailed explanation goes here

    points11 = transformPointsForward(trans1, double(points1));
    points22 = transformPointsForward(trans2, double(points2));

    residual = trace(dist2(points11, points22)) / ...
        size(squeeze(points1), 1);

%     difference = points22 - points11;
%     difference = difference .^ 2;
%     sumOfDifference = sqrt(sum(difference, 2));
%     residual = sum(sumOfDifference(:))/size(squeeze(sumOfDifference), 1);
    
end

