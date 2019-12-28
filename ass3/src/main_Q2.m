clc
clear

img_name = '../input_imgs/Q2/1.jpg';
img = imread(img_name);

[digits_set] = digit_segment(img);

[M, sze] = size(digits_set);

for i = 1:M
	digit = digits_set(i, :);
    digit = reshape(digit, sqrt(length(digit)), sqrt(length(digit)));
    imshow(digit, []);
    imwrite(digit, sprintf('../result_imgs/Q2/1_%02d.jpg', i));
end

%%
img_name = '../input_imgs/Q2/2.bmp';
img = imread(img_name);

[digits_set] = digit_segment(img);

[M, sze] = size(digits_set);

for i = 1:M
	digit = digits_set(i, :);
    digit = reshape(digit, sqrt(length(digit)), sqrt(length(digit)));
    imshow(digit, []);
    imwrite(digit, sprintf('../result_imgs/Q2/2_%02d.jpg', i));
end

%%
img_name = '../input_imgs/Q2/3.bmp';
img = imread(img_name);

[digits_set] = digit_segment(img);

[M, sze] = size(digits_set);

for i = 1:M
	digit = digits_set(i, :);
    digit = reshape(digit, sqrt(length(digit)), sqrt(length(digit)));
    imshow(digit, []);
    imwrite(digit, sprintf('../result_imgs/Q2/3_%02d.jpg', i));
end