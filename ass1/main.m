clc
clear
%%

img = imread('lena.png');
img = rgb2gray(img);

%% --------------- Task 1: Linear Spatial Filtering --------------- 
averaging_mask = ones(3, 3)/9;
prewittX_mask = [-ones(3, 1) zeros(3, 1) ones(3, 1)];
prewittY_mask = prewittX_mask.';
laplacian_mask = [0 -1 0; -1 4 -1; 0 -1 0];

ave_result = filter_spa(img, averaging_mask);
prewittX_result = filter_spa(img, prewittX_mask);
prewittY_result = filter_spa(img, prewittY_mask);
laplacian_result = filter_spa(img, laplacian_mask);

subplot(221), imshow(ave_result), title('Averaging')
subplot(222), imshow(prewittX_result), title('Prewitt X')
subplot(223), imshow(prewittY_result), title('Prewitt Y')
subplot(224), imshow(laplacian_result), title('Laplacian')

%%  --------------- Task 2: Non-linear Spatial Filtering  --------------- 

% add gaussian noises to the original input image
img_gau = add_gaussian_noise(img, 0, 0.03);

% add salt-and-pepper noises to the original input image
img_sp = add_salt_pepper_noise(img, 0.3);

size = 3;

gau_result = medfilt2d(img_gau, size);
sp_result = medfilt2d(img_sp, size);

figure,
subplot(221), imshow(img_gau), title('Image with Gaussian Noises')
subplot(222), imshow(img_sp), title('Image with Salt-and-Pepper Noises')
subplot(223), imshow(gau_result), title('Median Filter with Gaussian Noises')
subplot(224), imshow(sp_result), title('Median Filter with Salt-and-Pepper Noises')

%% ---------- Task 3: Filtering in the Frequency Domain -----------
lowpass_imag_1 = lowpass_filter(img, 0.05);
lowpass_imag_2 = lowpass_filter(img, 0.5);

figure,
subplot(121), imshow(lowpass_imag_1, []), title('Lowpass Filter (0.05)')
subplot(122), imshow(lowpass_imag_2, []), title('Lowpass Filter (0.5)')

%% ---------- Task 4: High-Frequency Emphasis -----------
high_fre_result = high_freq_emphasis(img, 0.3, 0.7);

figure,
subplot(121), imshow(img), title('Before High-Frequency Emphasis')
subplot(122), imshow(abs(high_fre_result), []), title('After High-Frequency Emphasis')