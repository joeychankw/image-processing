function ltpImg = ltp(img, t, N, R, useUniform)
% img - 2D gray image
% t = threshold
% N = number of neighbors
% R = radius
% return image with 2 channels (upper ltp and lower ltp)

[h, w] = size(img);
[X, Y] = meshgrid(1:w, 1:h);
gc = img;
neighborDir = getNeighborDirections(N, R);

ltpUpper = zeros(h, w);
ltpLower = zeros(h, w);

% neighbor comparison
for i = 1:N
    neighborInds = getNeighborInds(X, Y, neighborDir(i,1), neighborDir(i,2), h, w);
    gp = img(neighborInds);
    
    ltpUpper(gp>=gc+t) = bitset(ltpUpper(gp>=gc+t), i); % set 1 in upper
    ltpLower(gp<=gc-t) = bitset(ltpLower(gp<=gc-t), i); % set 1 in lower
end

% rotate bit to minimum
ltpUpper = minBit(ltpUpper, N);
ltpLower = minBit(ltpLower, N);

% uniform pattern
if useUniform
    ltpUpper = uniform(ltpUpper, N);
    ltpLower = uniform(ltpLower, N);
end

ltpImg = cat(3, ltpUpper, ltpLower);
end

function neighborInds = getNeighborInds(X, Y, x, y, h, w)

neighborX = X + x;
neighborY = Y + y;
invalid = neighborX < 1 | neighborX > w | neighborY < 1 | neighborY > h;
neighborX(invalid) = X(invalid);
neighborY(invalid) = Y(invalid);

neighborInds = sub2ind([h w], neighborY, neighborX);
end

function neighborDir = getNeighborDirections(N, R)
% return [x1 y1; x2 y2; ...; xN yN];

x0 = R; % inital direction
y0 = 0; % inital direction
angles = (0:N-1) * (360/N);

% rotate
X = x0 * cosd(angles) - y0 * sind(angles);
Y = x0 * sind(angles) + y0 * cosd(angles);

neighborDir = round([X; Y]');
end

function lbpMin = minBit(lbp, bits)

lbpMin = lbp;
lbpRotate = lbpMin;

for i = 1:bits-1
    leftmost = bitand(lbpRotate, 1) * 2^(bits-1);
    lbpRotate = bitor(bitshift(lbpRotate, -1), leftmost);
    
    lbpMin(lbpMin>lbpRotate) = lbpRotate(lbpMin>lbpRotate);
end
end

function lbpUniform = uniform(lbp, N)

lbpUniform = -ones(size(lbp));

for i = 0:N
    pattern = 2^i - 1;
    lbpUniform(lbp==pattern) = i;
end

lbpUniform(lbpUniform==-1) = N + 1;
end