im = imread('1_arc_away.png');
im = rgb2gray(im);
im = imgaussfilt(im, 1.3);

[~, threshold] = edge(im, 'approxcanny');
fudgeFactor  = 1.5;

% [im_edge, threshold] = edge(im, 'approxcanny', threshold * fudgeFactor );
[im_edge, threshold] = edge(im, 'approxcanny' );

imshow(im_edge);


% TODO: potetially
% - compare observed edges with depth image gradiants
% - For significant edges that appear to be in both depth and real image,
% track that section of the image and evaluate the edge displacement 