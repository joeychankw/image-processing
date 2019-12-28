function noisy_image = add_salt_pepper_noise(img_input, p)

x = rand(size(img_input));

noisy_image = mat2gray(img_input);
noisy_image(find(x < p/2)) = 0;
noisy_image(find(x >= 1-p/2)) = 1;
noisy_image = uint8(255 * noisy_image);

end

