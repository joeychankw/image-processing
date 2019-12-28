function img = dog_filter(img, sigma1, sigma2, windowSze)
g1 = fspecial('gaussian', windowSze, sigma1);
g2 = fspecial('gaussian', windowSze, sigma2);
dog = g2 - g1;

img = imfilter(img, dog, 'replicate');
end