function img_result = high_freq_emphasis(img_input, a, b)

g = lowpass_filter(img_input, 0.05);
img_result = (a + b)*img_input - b*g;

end