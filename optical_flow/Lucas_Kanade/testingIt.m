
% dataDir = fullfile('data');
% imFileNames = {'elevator_1.png'; 'elevator_2.png'};



vidReader = VideoReader('approaching_dropoff.mp4');

opticFlow = opticalFlowLK('NoiseThreshold',0.0009);

while hasFrame(vidReader)
    frameRGB = readFrame(vidReader);
    frameGray = rgb2gray(frameRGB);
  
    flow = estimateFlow(opticFlow,frameGray); 

    imshow(frameRGB) 
    hold on
    plot(flow,'DecimationFactor',[5 5],'ScaleFactor',10)
    hold off 
end