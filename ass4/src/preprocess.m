function img = preprocess(img, gamma, sigma1, sigma2, alpha, tau)
img = mat2gray(img);

img = gamma_correction(img, gamma);
img = dog_filter(img, sigma1, sigma2, 3);
img = constrast_equal(img, alpha, tau);

img = (img + tau) / (2 * tau); % normalize to [0, 1]
end