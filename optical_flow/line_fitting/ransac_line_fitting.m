
function [finalFits] = ransac_line_fitting(im)


    % Init containers
%     lines = []; corners = []; lineClusterIdxs = [];    
    finalFits = [];


    % Compile all coordinates of prominent wall cells
    [yvals, xvals] = find(im);
    pts = horzcat(xvals, yvals);
%     pointCount = size(xvals, 1);
%     ogridCenter = size(im) ./ 2;
        
    %lets start ransac PARAMETERS:
    ransacIterations = 200; % 1000;
    ransacSampleCount = 2;
    ransacInlierDist = 4;
    outerLoopThreshold = 10;
    minPointsToFit = 30;
%     maxLineCluster = 2;
%     minHallwayAnlgeDisparity = 20;  % in degrees
%     parallelLineMaxThreshold = 25;  % in degrees
%     maxCornerDistanceFromCenter = 200;

    
    %%%%%%%%%%%% RANSAC LINE FITTING %%%%%%%%%%%%%%%  
    while size(pts, 1) > outerLoopThreshold 
        chosenInliers = []; 
        mostInliers = 0;

        % while there are more than x points in image or number of inliers in best
        %       model is less than some certain threshold.
        for itr = 1:ransacIterations
            pointCount = size(pts, 1);

            % Choose samples to fit line to
            samples = zeros(size(ransacSampleCount, 2), 2);
            chosenIdxs = []; chosen = 0;
            for sampleIdx = 1:ransacSampleCount

                chosen = int16(rand(1)*pointCount);
                while ismember(chosen, chosenIdxs) || chosen == 0
                    chosen = int16(rand(1)*pointCount);
                end
                chosenIdxs(end + 1) = chosen;
                samples(sampleIdx, :) = pts(chosen, :);
            end

            % Count inliers
            inliers = [];
            for ptIdx = 1:size(pts, 1)
                pt = pts(ptIdx, :);
                if pt_line_dist(pt, samples(1, :), samples(2, :)) < ransacInlierDist
                    inliers(end+1) = ptIdx;
                end
            end

            % Store better fitting
            if size(inliers, 2) > mostInliers
                mostInliers = size(inliers, 2);
                chosenInliers = inliers;
            end

        end

        if mostInliers < minPointsToFit
            break;
        end

        % Fit line to inliers     
        finalFits(end + 1, :) = polyfit(pts(chosenInliers, 1), pts(chosenInliers, 2), 1);

        % Remove inliers point cloud
        pts(chosenInliers, :) = [];   
    end
    
%     assert(size(finalFits, 2) > 0, "Could not find any walls in the occupancy grid!")
%     
%     % Cluster lines into groups that are 
%     % exponentiatedSlopes = real(log(rad2deg(finalFits(:, 1))));
%     angle = atan(finalFits(:, 1));
%     % lineClusterIdxs = kmeans(exponentiatedSlopes,maxLineCluster );     
%     Z = linkage(abs(angle) ,'average','chebychev');
%     lineClusterIdxs = cluster(Z,'maxclust',maxLineCluster);
% 
%     
%     
%     %%%%%%%%%%%% LINE FILTERING %%%%%%%%%%%%%%%    
%  	uniqueClusters = unique(lineClusterIdxs);
%     
%     % Within each cluster, if there are more than three line fits, remove
%     % outlier lines by filtering slopes with high angle difference
% %     for cidx = 1:size(uniqueClusters)
% %         clusterIdxs = find(lineClusterIdxs == uniqueClusters(cidx));
% %         discardIdxs = [];
% %         if size(clusterIdxs, 1) > 2
% %             meanAngle = mean(angle(clusterIdxs));
% %             angleStd = std(angle(clusterIdxs));
% %             for subcidx = clusterIdxs.'
% %                 angleDisparity = rad2deg(abs(meanAngle - angle(subcidx)));
% % 
% %                 if angleDisparity >  (rad2deg(angleStd)/2)%parallelLineMaxThreshold
% %                     discardIdxs(end+1) = subcidx;
% %                 end
% %             end
% %             angle(discardIdxs) = [];
% %             lineClusterIdxs(discardIdxs) = [];
% %             finalFits(discardIdxs, :) = [];
% %         end
% %     end
%     
%     % Clump clusters with similar average anlges
%     % assert( size(uniqueClusters , 1)  == 2, 'The code currently expects two clusters');
%     % NOTICE: to do this for more than two hallways, check all conbinations
%     if size(uniqueClusters , 1)  == 2
%         for cidx = 2:size(uniqueClusters)
% 
%             grp1 = angle(find(lineClusterIdxs == uniqueClusters(cidx-1)));
%             grp2 = angle(find(lineClusterIdxs == uniqueClusters(cidx)));
% 
%             angleDisparity = rad2deg(abs(grp2(1,:) - grp1(1,:)));
% 
%             if angleDisparity < minHallwayAnlgeDisparity
%                 lineClusterIdxs(find( ... 
%                     lineClusterIdxs == uniqueClusters(cidx-1))) =...
%                     uniqueClusters(cidx);
%             end 
%         end
%     end
%     
%     
%     %%%%%%%%%%%% SETTING RESULTS %%%%%%%%%%%%%%%   
%     lines = finalFits;
%     corners  = find_line_intersections(finalFits,lineClusterIdxs);
% 
%     
%     %%%%%%%%%%%% CORNER FILTERING %%%%%%%%%%%%%%%   
%     % Remove corners that are far from image center 
%     for cidx = 1:size(corners, 1) 
%        if sqrt(sum((corners(cidx) - ogridCenter).^2))...
%                > maxCornerDistanceFromCenter
%            corners(cidx) = [];
%        end
%     end
%     
%     
%     
% 
%     
%     
% 
%     %%%%%%%%%%%% VISUALIZING %%%%%%%%%%%%%%%  
%     if 1 == 1
%         plot_ref = []; corner_ref = [];
%         figure;
%         scatter(xvals, yvals); hold on 
%         
%         title('Wall Line Fitting And Corner Detection')
%         % Set limits
%         minxval = min(xvals); maxxval = max(xvals);
%         minyval = min(yvals); maxyval = max(yvals);
% 
%         % plot lines onto the scatter graph
%         for pidx = 1:size(finalFits,1) 
%             p = finalFits(pidx, :);
%             x1 = linspace(minxval,maxxval);
%             y1 = polyval(p,x1);
% 
%             remove = find(y1 < minyval-50 | y1 > maxyval+50);   
%             x1(remove) = []; y1(remove) = [];
% 
%             plot_ref = plot(x1, y1,'.-', 'Color', 'r'); hold on 
%         end
% 
%         % display line intersections
%         if size(corners, 1) > 0
%             corner_ref = scatter(corners(:, 1), corners(:, 2),  ...
%                 'o', 'MarkerFaceColor', 'g');
%         end
%         
%         legend([plot_ref, corner_ref], {'Wall Line Fits', 'Corner Points'})
%         pbaspect([1 1 1])
%         axis([20, 180, 60, 180])
%     end
    
end