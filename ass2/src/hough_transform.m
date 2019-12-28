function [img_marked, corners] = hough_transform(img)

% Implement the Hough transform to detect the target A4 paper
% Input parameter:
% .    img - original input image
% .    (You can add other input parameters if you need. If you have added
% .    other input parameters, please state for what reasons in the PDF file)
% Output parameter:
% .    img_marked - image with marked sides and corners detected by Hough transform
% .    corners - the 4 corners of the target A4 paper

% Remember to print the line functions and the corner points in the command window

% constant
lineNum = 4;
cornerNum = 4;
rhoRes = 2; % rho interval
thetaRes = pi/90; % theta interval
maxImgLength = 500; % for scaling

[h, w, ~] = size(img);

% preprocess & scaling
imgGray = rgb2gray(img);
imgGray = mat2gray(imgGray);
scale = maxImgLength/max([h w]); % scale to improve speed
imgGray = imresize(imgGray, scale);

% filter
imgEdge = edgefilter(imgGray);

% hough transform
[H, rhoScale, thetaScale] = getHoughAccumulator(imgEdge, rhoRes, thetaRes);
[rhos, thetas] = getNLines(imgEdge, H, lineNum, rhoScale, thetaScale);

% unscale
rhos = rhos/scale;

% output
corners = getCorners(rhos, thetas, cornerNum, [h w]);
img_marked = houghDraw(rhos, thetas, corners, img);

% print result
for i = 1:numel(rhos)
    fprintf('function of the line %d is: %f * x + %f * y = %f\n', ...
        i, cos(thetas(i)), sin(thetas(i)), rhos(i))
end
fprintf('intersection points are: ')
for i = 1:size(corners, 1)
    fprintf('(%f, %f) ', corners(i,1), corners(i,2))
end
fprintf('\n\n')

end

function imgEdge = edgefilter(img)
threshold = 0.02;  
hLaplacian = [1 1 1; 1 -8 1; 1 1 1];

imgSmooth = imgaussfilt(img, 1);
imgEdge = conv2(imgSmooth, hLaplacian, 'same');
imgEdge = imgEdge>threshold;
imgEdge = bwmorph(imgEdge, 'thin', Inf); % extract thinest edge
end

function [H, rhoScale, thetaScale] = getHoughAccumulator(imgEdge, rhoRes, thetaRes)
[h, w] = size(imgEdge);

% prepare
rhoScale = 0:rhoRes:ceil(sqrt(w^2 + h^2)); % rho will not be greater than sqrt(w^2 + h^2)
thetaScale = 0:thetaRes:2*pi - thetaRes; % [0, 360)
cosThetas = cos(thetaScale);
sinThetas = sin(thetaScale);
thetaInds = 1:numel(thetaScale);

Hsize = [numel(rhoScale) numel(thetaScale)];
H = zeros(Hsize);
edgePtInds = find(imgEdge); % indices of non-zero pixels

% compute rho & accumulate     
for i = 1:numel(edgePtInds)
    [y, x] = ind2sub([h w], edgePtInds(i));
    rhos = x*cosThetas + y*sinThetas;
    rhos = interp1(rhoScale, rhoScale, rhos, 'nearest'); % interpolate to nearest rho values, negative become NaN

    rhoInds = rhos/rhoRes + 1; % value to index
    HInds = rmmissing(sub2ind(Hsize, rhoInds, thetaInds)); % 2D index to 1D index, remove NaN
    
    H(HInds) = H(HInds) + 1;
end

end

function [X, Y] = getLinePoints(rho, theta, sze)
h = sze(1);
w = sze(2);

if sin(theta) == 0 % if vertical line
    Y = 1:h;
    X = (rho - Y*sin(theta))/cos(theta);
    invalid = isnan(X) | X < 1 | X > w;
else % otherwise
    X = 1:w;
    Y = (rho - X*cos(theta))/sin(theta);
    invalid = isnan(Y) | Y < 1 | Y > h;
end

% remove invalid coordinates
X(invalid) = [];
Y(invalid) = [];
end

function [isClose, overlayPercent] = isLineClose(rho1, theta1, rho2, theta2, sze, minOverlayPercent)
% determine if 2 lines are close to each other

dilateSize = 21;

[X1, Y1] = getLinePoints(rho1, theta1, sze);
[X2, Y2] = getLinePoints(rho2, theta2, sze);
X1 = round(X1);
Y1 = round(Y1);
X2 = round(X2);
Y2 = round(Y2);

% fill binary img A1 and A2 with the line points
A1 = false(sze);
A2 = false(sze);    
for i = 1:numel(X1)
    A1(Y1(i), X1(i)) = true;
end
for i = 1:numel(X2)
    A2(Y2(i), X2(i)) = true;
end

% dilate
B = ones(dilateSize);
A1 = imdilate(A1, B);
A2 = imdilate(A2, B);

overlayPercent = sum(and(A1, A2), 'all')/sum(or(A1, A2), 'all');
isClose = (overlayPercent >= minOverlayPercent);
end

function isCloseAny = isLineCloseAny(rho, theta, rhos, thetas, sze, minOverlayPercent)
% determine if the line is close to any given lines

isCloseAny = false;
for k = 1:numel(rhos)
    [isClose, ~] = isLineClose(rho, theta, rhos(k), thetas(k), sze, minOverlayPercent);
    if isClose
        isCloseAny = true;
        break
    end
end
end

function Hweights = getHoughWeights(imgEdge, H, rhoScale, thetaScale)
% use (#line points lie on white pixel)/(#total line points) as weight

dilateSize = 3;
imgEdge = imdilate(imgEdge, ones(dilateSize)); % make edge thicker

inds = find(H); % find non-zero
[rhoInds, thetaInds] = ind2sub(size(H), inds);

Hweights = zeros(size(H));

% iterate each rho & theta with non-zero vote
for i = 1:numel(inds)

    rho = rhoScale(rhoInds(i));
    theta = thetaScale(thetaInds(i));
    
    [X, Y] = getLinePoints(rho, theta, size(imgEdge));
    X = round(X);
    Y = round(Y);
    
    % accumulate #line points lie on white pixels in imgEdge
    pointNum = numel(X);
    matchedPointNum = 0;
    for p = 1:pointNum
        if imgEdge(Y(p),X(p)) > 0
            matchedPointNum = matchedPointNum + 1;
        end
    end
    
    Hweights(rhoInds(i), thetaInds(i)) = matchedPointNum/pointNum;
end

end

function [rhos, thetas] = getNLines(imgEdge, H, N, rhoScale, thetaScale)

threshold = 100;
isCloseFactor = 0.5;

% preprocess
H(H<threshold) = 0; % threshold
H = imregionalmax(H) .* H; % only keep regional max

% apply weights for better priority
Hweights = getHoughWeights(imgEdge, H, rhoScale, thetaScale);
Hweighted = H.*Hweights;

rhos = [];
thetas = [];

[~, sortedInds] = sort(Hweighted(:),'descend');
N = min(N, nnz(Hweighted));
n = 0;
% store the first N prioritized lines that are not close to each other
for i = 1:nnz(Hweighted)
    if n >= N break, end

    [rhoInd, thetaInd] = ind2sub(size(H), sortedInds(i));
    rhoCurr = rhoScale(rhoInd);
    thetaCurr = thetaScale(thetaInd);
    
    % compare the current line with the previous lines then store
    if ~isLineCloseAny(rhoCurr, thetaCurr, rhos, thetas, size(imgEdge), isCloseFactor)
        rhos(1,end+1) = rhoCurr;
        thetas(1,end+1) = thetaCurr;
        n = n + 1;
    end
end

end

function [x, y] = getIntersect(rho1, theta1, rho2, theta2)
% find the intersection point of 2 lines

% rho = cos(theta)*x + sin(theta)*y --> ax + by + c = 0
a1 = cos(theta1);
b1 = sin(theta1);
c1 = -rho1;
a2 = cos(theta2);
b2 = sin(theta2);
c2 = -rho2;

if a2 == 0 || b1 == 0
    s = b1/b2;
    x = (s*c2 - c1)/(a1 - s*a2);
    y = (-a2*x - c2)/b2;
else
    s = a1/a2;
    y = (s*c2 - c1)/(b1 - s*b2);
    x = (-b2*y - c2)/a2;
end
end

function corners = getCorners(rhos, thetas, cornerNum, sze)
lineNum = numel(rhos);
h = sze(1);
w = sze(2);
corners = [];

for i = 2:lineNum
    for j = 1:i-1
        if size(corners, 1) >= cornerNum break, end
        
        % get intersection point for each 2 line
        [x, y] = getIntersect(rhos(i), thetas(i), rhos(j), thetas(j));
        % store if corner coordinate is valid
        isvalid = x >= 1 & x <= w & y >= 1 & y <= h;
        if isvalid
            corners(end+1, 1) = x;
            corners(end, 2) = y;
        end
    end
end

end

function img_marked = houghDraw(rhos, thetas, corners, img)

lineNum = numel(rhos);
[h, w, ~] = size(img);

f = figure('visible', 'off');
imshow(img)
set(0, 'CurrentFigure', f)
hold on

% draw lines
for i = 1:lineNum
    [Xi, Yi] = getLinePoints(rhos(i), thetas(i), [h w]);
    plot(Xi, Yi, 'LineWidth', 5)
end
% plot corners
plot(corners(:,1), corners(:,2), 'w.', 'MarkerSize', 50)

img_marked = frame2im(getframe(f));
hold off
close(f);

end
