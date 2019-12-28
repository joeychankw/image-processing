function img_result = lowpass_filter(img_input,D0)

f = mat2gray(img_input);
F = fftshift(fft2(f));

%compute H
[h, w] = size(f);
[X, Y] = meshgrid(1:w, 1:h);
X = X-(w+1)/2;
Y = Y-(h+1)/2;
D = mat2gray(sqrt(X.^2 + Y.^2));
H = double(D<=D0);

G = H.*F;
g = real(ifft2(ifftshift(G)));
g(g>1) = 1;
g(g<0) = 0;
img_result = uint8(255 * g);

end

