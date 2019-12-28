function img_result = filter_spa(img_input, filter)

img_input = mat2gray(img_input);

%initialize
[h, w] = size(img_input);
f_size = size(filter, 1);
f_size2 = floor(f_size/2);

img_result = zeros(h, w);
img_pad = zeros(h + f_size - 1, w + f_size - 1);
img_pad(1+f_size2:h+f_size2, 1+f_size2:w+f_size2) = img_input;

%padding
img_pad(1:f_size2, :) = repmat(img_pad(1+f_size2, :), f_size2, 1);
img_pad(h+f_size2+1:end, :) = repmat(img_pad(h+f_size2, :), f_size2, 1);
img_pad(:, 1:f_size2) = repmat(img_pad(:, 1+f_size2), 1, f_size2);
img_pad(:, w+f_size2+1:end) = repmat(img_pad(:, w+f_size2), 1, f_size2);

%convolution
for e=1:numel(img_input)
    i = mod(e-1, h)+1;
    j = floor((e-1)/h)+1;
    img_result(i, j) = sum(sum(filter.*img_pad(i:i+f_size-1, j:j+f_size-1)));
end

img_result = uint8(255 * img_result);

end