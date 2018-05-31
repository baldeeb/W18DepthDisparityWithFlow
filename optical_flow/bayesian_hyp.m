function [new] = bayesian_hyp(prev, curr, trans)
    
   % Increase certainty       
    certainty_rate = 1;  %0.04;
    decay_prev_rate = 0.5;
    top_probability_limit = 10;  % 225;

    curr  = ordfilt2(curr,9,ones(3,3));

    if size(prev, 1) ~= 0
        % Transform current image to fit current frame.
        new = imwarp(prev,trans, 'FillValues', 0);
        
        % Discard unwanted readings.
        new = new(1:size(curr,1),1:size(curr,2));
        
        % Find pixels that are still seen as edges in the new observation.
        edge_pixels = find(new);
        
        % Decay changed observations.
        decay_pixels = setdiff(edge_pixels, find(curr));
        new(decay_pixels) = max(new(decay_pixels) - decay_prev_rate, 0); 

        % Increase certainty of edges that are re-occuring.
        new = new + curr.*certainty_rate;
        new(new > top_probability_limit) = top_probability_limit;
        
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
