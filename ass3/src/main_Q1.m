clc
clear

% Assignment 2
% img - original input image
% img_marked - image with marked sides and corners detected by Hough transform
% corners - the 4 corners of the target A4 paper
% img_warp - the standard A4-size target paper obtained by image warping
% n - determine the size of the result image

% define the n by yourself
n = 3;

% Manually detemine the corner points for six input images
Corners(:,:,1) = [650.5 570.5; 3770.5 486.5; 674.5 2718.5; 3782.5 2762.5];
Corners(:,:,2) = [1526.5 310.5; 3414.5 202.5; 1554.5 2838.5; 3438.5 2922.5];
Corners(:,:,3) = [494.5 806.5; 3358.5 174.5; 874.5 2798.5; 3798.5 2282.5];
Corners(:,:,4) = [550.5 702.5; 3554.5 386.5; 710.5 2942.5; 3926.5 2550.5];
Corners(:,:,5) = [934.5 146.5; 3850.5 890.5; 390.5 2170.5; 3302.5 2990.5];
Corners(:,:,6) = [354.5 1110.5; 2982.5 54.5; 1074.5 2918.5; 3702.5 1978.5];
    
inputs = [1,2,3,4,5,6];
for i = 1:length(inputs)
    img_name = ['../input_imgs/Q1/', num2str(inputs(i)), '.JPG'];
    img = imread(img_name);
    % Run your Hough transform of Assignment 2 Q3 to obtain the corners.
    % You can also find the corners manually. If so, please change the following code accrodingly
    % [img_marked, corners] = hough_transform(img);
    % corners = Corners(:,:,i);
    [img_marked, corners] = markCorners(img);
    img_warp = img_warping(img, corners, n);
    figure,
    subplot(131),imshow(img);
    subplot(132),imshow(img_marked);
    subplot(133),imshow(img_warp);
end

%% helper
function [img_marked, corners] = markCorners(img)
corners = [];

figure,
imshow(img);
title('Please pick the 4 corners');
hold on
for i = 1:4
    [x, y] = ginput(1);
    plot(x, y, 'r*', 'LineWidth', 2, 'MarkerSize', 10);
    corners = [corners; x y];
end
hold off

img_marked = frame2im(getframe());
end