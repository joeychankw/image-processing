clc
clear

%%
% Question 1
% connected_component.m contains the implementation of the main routine for Question 1 in Assignment 2. 
% This function search for all connected component on the input image. It should output the total number of
% connected components, number of pixels in each connected component and
% display the largest connected component. Note that you are not allow to
% use the bwlabel/bwlabeln/bwconncomp matlab built-in function in this
% question.

IM = imread('../input_imgs/Q1/cc_image.jpg');
L_CC = connected_component(IM);

%%
% Question 2
% hough_transform_syn contains the implementation of main routine for Question
% 2 in Assignment 2. This function uses circular Hough Transform to detect circles
% in a binary image. Given that the radius of the circles is 50 pixels. Note
% that you are not allow to use the imfindcircles matlab built-in function
% in this question.

IM = imread('../input_imgs/Q2/hough_image.jpg');
hough_transform_syn(IM);

%%
% Question 3
% img - original input image
% img_marked - image with marked sides and corners detected by Hough transform
% corners - the 4 corners of the target A4 paper

inputs = [1,2,3,4,5,6];
for i = 1:length(inputs)
    img_name = ['../input_imgs/Q3/', num2str(inputs(i)), '.JPG'];
    img = imread(img_name);
    [img_marked, corners] = hough_transform(img);
    figure, 
    subplot(121),imshow(img);
    subplot(122),imshow(img_marked);
end