

vidReader = VideoReader('approaching_dropoff.mp4');

opticFlow = opticalFlowLK('NoiseThreshold',0.0009);

while hasFrame(vidReader)
    frameRGB = readFrame(vidReader);
    frameGray = rgb2gray(frameRGB);
  
    flow = estimateFlow(opticFlow,frameGray); 

    imshow(zeros(size(frameRGB)))
    hold on
        plot(flow,'DecimationFactor',[5 5],'ScaleFactor',15)
    hold off 

end



% Brainsotrming: 
% 
% If I can get the velocity in the x and y directions. then I can predict
% the groundplace optical flow velocity based on the 2D vertical position
% of the pixels. 
% Those with significantly higher or lower flow than that predicted would
% be considered obstacles or precipise.