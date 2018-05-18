function [dist] = pt_line_dist(pt, v1, v2)
% https://www.mathworks.com/matlabcentral/answers/95608-is-there-a-function-in-matlab-that-calculates-the-shortest-distance-from-a-point-to-a-line
a = v1 - v2; a = [a, 0];
b = pt - v2; b = [b, 0];
dist = norm(cross(a,b)) / norm(a);   
end

