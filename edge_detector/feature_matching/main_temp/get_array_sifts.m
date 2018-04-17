function [siftArray] = get_array_sifts(coloredIms)
%GET_SIFT_LISTS Takes in a cell array of images
%   The function produces and returns a cell array of sift features of the
%   passed images in addtion to the column and row of each feature. 

    % Sift tuning
    radius_desc = 5; % sqrt(2) * sigma;
    enlarge_factor = 1.5;
    
    % Harris featurs tuning
    sigma = 1.7; thresh = 1100; radius = 2; disp = 0;

    siftArray = {};
    
    for idx = 1 : size(coloredIms, 1)
        colorIm = coloredIms{idx};
        grayIm = double(rgb2gray(colorIm));

        % Get features 
        [~, rowf, colf] = harris(grayIm, sigma, thresh, radius, disp);
        fcount = size(rowf);

        circles = [colf, rowf, ones(fcount).*radius_desc];
        siftArray{idx, 1} = find_sift(grayIm, circles, enlarge_factor);
        siftArray{idx, 2} = colf;
        siftArray{idx, 3} = rowf;
        
    end

end

