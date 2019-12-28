function img = constrast_equal(img, alpha, tau)
img = img ./ mean( abs(img).^alpha , 'all')^(1/alpha); % equation (5)
img = img ./ mean( min(abs(img), tau).^alpha , 'all')^(1/alpha); % equation (6)
img = tau * tanh(img / tau);
end