function h = hog_norm_hist(block, n, filter, dir_edges)

x_grad = conv2(block, filter, 'same');
y_grad = conv2(block, filter', 'same');

angles = atan2(y_grad,x_grad);
mags = sqrt(y_grad.^2+x_grad.^2);

[N,B] = histc(reshape(angles,[n^2 1]), dir_edges);

h = zeros(length(dir_edges)-1,1);

mags = reshape(mags,[n^2 1]);

for b = 1:length(h)
    h(b) = sum(mags(B==b));
end

h(b) = h(b) + sum(mags(B==(b+1)));

h = h./max(h);
