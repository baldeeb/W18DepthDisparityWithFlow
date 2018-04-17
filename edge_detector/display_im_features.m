addpath('code');


% This scrip assumes that all the images are of the same size


dataDir = fullfile('');

im = imread('1_arc_away.png');
im = rgb2gray(im);

points = detectHarrisFeatures(im);

[f, vpts] = extractFeatures(im, points);

disp(f);