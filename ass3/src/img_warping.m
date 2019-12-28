function img_warp = img_warping(img, corners, n)

% Implement the image warping to transform the target A4 paper into the
% standard A4-size paper
% Input parameter:
% .    img - original input image
% .    corners - the 4 corners of the target A4 paper detected by the Hough transform
% .    (You can add other input parameters if you need. If you have added
% .    other input parameters, please state for what reasons in the PDF file)
% .    n - determine the size of the result image
% Output parameter:
% .    img_warp - the standard A4-size target paper obtained by image warping

img = double(img);

corners = orderCorners(corners); % make corners in the order of left top, right top, right bottom, left bottom
[targetCorners, imgWarpSze] = getTargetCorners(corners, n); % target points to map to

H = homography(corners, targetCorners); % compute the transformation matrix

img_warp = imwarpCustom(H, img, imgWarpSze); % apply transformation

img_warp = uint8(img_warp);
end

function dist = euclid(v1, v2) % per row distance
dist = sum((v1 - v2).^2, 2);
end

function [closestPoint, closestInd] = closest(targetPoint, points)
dist = euclid(points, repmat(targetPoint, size(points, 1), 1));
[~, closestInd] = min(dist);
closestPoint = points(closestInd,:);
end

function [cornersOrdered] = orderCorners(corners)
[A, closestInd] = closest([0 0], corners);
corners(closestInd,:) = [];

% check z-direction of cross product
A = [A 0];
for i = 1:3
    B = [corners(i,:) 0];
    for j = 1:3
        if j == i continue, end
        C = [corners(j,:) 0];
        M = cross(B-A, C-A);
        if M(3) < 0 continue, end
        for k = 1:3
            if k == i || k == j continue, end
            D = [corners(k,:) 0];
            M = cross(C-A, D-A);
            if M(3) > 0
                cornersOrdered = [A; B; C; D];
                cornersOrdered = cornersOrdered(:,1:2);
                return
            end
        end
    end
end
end

function [targetCorners, imgWarpSze] = getTargetCorners(corners, n)
if isHorizontal(corners)
    h = 210 * n;
    w = 297 * n;
else
    w = 210 * n;
    h = 297 * n;
end
targetCorners = [0 0; w 0; w h; 0 h];
imgWarpSze = [h w];
end

function bool = isHorizontal(corners)
distHorizontal = euclid(mean(corners([1 4],:)), mean(corners([2 3],:)));
distVertical = euclid(mean(corners([1 2],:)), mean(corners([4 3],:)));
bool = logical(distHorizontal >= distVertical);
end

function H = homography(p1, p2)
n = size(p1, 1);
x1 = p1(:,1);
x2 = p2(:,1);
y1 = p1(:,2);
y2 = p2(:,2);

Ax = [-x1 -y1 -ones(n, 1) zeros(n, 3) x1.*x2 y1.*x2 x2];
Ay = [zeros(n, 3) -x1 -y1 -ones(n, 1) x1.*y2 y1.*y2 y2];
A = [Ax; Ay];

[~, ~, V] = svd(A);

H = reshape(V(:, end), 3, 3)';
H = H/H(end);
end

function imgWarp = imwarpCustom(H, img, imgWarpSze)
imgWarp = zeros(imgWarpSze);
channel = size(img, 3);
for i = 1:channel
    imgWarp(:,:,i) = imwarpGray(H, img(:,:,i), imgWarpSze);
end
end

function imgWarp = imwarpGray(H, img, imgWarpSze)
hWarp = imgWarpSze(1);
wWarp = imgWarpSze(2);

% inverse warp
[XWarp, YWarp] = meshgrid(1:wWarp, 1:hWarp);
[X, Y] = transformPoints(inv(H), XWarp, YWarp);

% bilinear
imgWarp = bilinearCustom(img, X, Y);
end

function [X2, Y2] = transformPoints(H, X1, Y1)
[h, w, ~] = size(X1);

p1 = [X1(:) Y1(:) ones(h*w, 1)];
p2 = p1 * H';
p2 = p2./repmat(p2(:,3), 1, 3);

X2 = reshape(p2(:,1), h, w);
Y2 = reshape(p2(:,2), h, w);
end

function A2 = bilinearCustom(A1, X, Y)
intX = floor(X);
intY = floor(Y);
ratioX = X - intX;
ratioY = Y - intY;
intX = uint32(intX);
intY = uint32(intY);

f00 = getValues(A1, intX, intY); % left top pixels
f01 = getValues(A1, intX, intY+1); % left bottom pixels
f10 = getValues(A1, intX+1, intY); % right top pixels
f11 = getValues(A1, intX+1, intY+1); % right bottom pixels

A2 = (1-ratioX) .* (f00 .* (1-ratioY) + f01 .* ratioY) + ...
            ratioX .* (f10 .* (1-ratioY) + f11 .* ratioY);
end

function values = getValues(A, X, Y)
[h, w, ~] = size(A);
isvalid = (X >= 1 & X <= w & Y >= 1 & Y <= h);

inds = sub2indCustom([h w], X, Y);

values = zeros(size(X));
values(isvalid) = A(inds(isvalid));
values(~isvalid) = 0;
end

function inds = sub2indCustom(sze, X, Y)
row = sze(1);
inds = (X-1)*row + Y + 1;
end
