function img = gamma_correction(img, gamma)
if gamma == 0
    img = log(img + 1);
else
    img = img.^gamma;
end
end