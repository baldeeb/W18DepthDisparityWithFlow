function [y, z] = get_feature_depth(f, params)

% Takes in a feature struct (needs the position of a feature) and the
% camera parameters
% Returns the y distance of feature from camera, and z representing the
% depth of a feature.

% TODO: UNUSED

beta = arctan(((2*f.x - params.V) / params.V) * tan(params.VFOV/2));
y = params.H / tan(params.alpha + beta);
z = params.H * cos(beta) / sin(params.alpha + beta);

end
