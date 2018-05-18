function [new] = bayesian_hyp(prev, curr, trans)
    
   % Increase certainty       
    certainty_rate = 1;  %0.04;
    decay_rate = 0.75;

    curr  = ordfilt2(curr,9,ones(3,3));

    if size(prev, 1) ~= 0
        % Transform current image to fit current frame.
        new = imwarp(prev,trans, 'FillValues', 0);
        
        % Discard unwanted readings.
        new = new(1:size(curr,1),1:size(curr,2));
        
        % Find pixels that are still seen as edges in the new observation.
        edge_pixels = find(new);
        
        % Decay changed observations.
        decay_pixels = setdiff(find(curr), edge_pixels);
        new(decay_pixels) = new(decay_pixels) - decay_rate; 
        
        % Increase certainty of edges that are re-occuring.
        new = new + curr.*certainty_rate;
    else
        % Initialize hypothesis.
        new = zeros(size(curr));            
        new = new + curr.*certainty_rate;
    end

    
    % Display results. 
    disp_hyp = new; 
    disp_min = min(min(disp_hyp));
    if disp_min < 0
        disp_hyp = disp_hyp - disp_min;
    end
    % This will allow for a clear display of the results. 
    disp_max = max(max(disp_hyp));
    if disp_max > 1  
        disp_hyp = disp_hyp ./ disp_max;
    end
    figure(333)
    imshow(ordfilt2(disp_hyp, 25, ones(5, 5)))
end



function [result] =  edge2type(edge_im, flow_im)
% The passed image is one with ones where there is an expected edge.

    % Find all edges
    [edge_pixels] = find(edge_im);
    
    % Build mask to convolve
    mask = ...
    [...
         1  1  1  1; ...
         1  1  1  1; ...
         1  1  1  1; ...
         1  1  1  1; ...
         0  0  0  0; ...
        -1 -1 -1 -1; ...
        -1 -1 -1 -1; ...
        -1 -1 -1 -1; ...
        -1 -1 -1 -1  ...
    ];

    conv_im = conv2(flow_im, mask);
end
% find all non zero values. 

% Convolve a rectangle over the full image. The rectangle has to be
% positive form below and negative from above 

% find the values at the edges found earlier. 

% if positive and greater than a threshold or lower than the negative of
% that threshold then it is either a drop or an overhang.