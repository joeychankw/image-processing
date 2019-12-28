function img_result = medfilt2d(img_input, f_size)

[h, w] = size(img_input);
f_size2 = floor(f_size/2);
med_ind = ceil(f_size^2/2);

img_result = uint8(zeros(h, w));
img_pad = zeros(h+f_size-1, w+f_size-1);
img_pad(1+f_size2:h+f_size2, 1+f_size2:w+f_size2) = img_input;

for i = 1:h
    for j = 1:w
        window = img_pad(i:i+f_size-1, j:j+f_size-1);
        window = sort(window(:));
        img_result(i, j) = window(med_ind);
    end
end

end