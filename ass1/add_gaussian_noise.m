function noisy_image = add_gaussian_noise(img_input, g_mean, g_std)

noisy_image = mat2gray(img_input) + g_std*randn(size(img_input)) + g_mean;
noisy_image(noisy_image<0) = 0;
noisy_image(noisy_image>1) = 1;
noisy_image = uint8(255 * noisy_image);

end

