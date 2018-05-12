function [pts3D] = get_pts3D(pts2D, cam_p)

pts3D = cam_p.H .* [pts2D(:, 1)./pts2D(:, 2), ...
    ones(size(pts2D, 1), 1), ...
    abs(ones(size(pts2D, 1), 1)./pts2D(:, 2))];



ground_norm = [0, 1, 0];  % non-homogeneous coordinates




end

