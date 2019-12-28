function [digits_set] = digit_segment(img)

% Implement the digit segmentation
% img: input image
% digits_set: a matrix that stores the segmented digits. The number of rows
%            equal to the number of digits in the iuput image. Each digit 
%            is stored in each row. Please make sure the segmented digit is a square
%            image before expand it into a row vector.

imgEdge = edgeFilter(img);
rowRanges = segmentHorizontal(imgEdge);
boxes = segmentVertical(imgEdge, rowRanges);
% drawBoxes(imgEdge, boxes); %debug

CCs = bwconncomp(imgEdge > 0);
CCboxInds = mapCCsToBoxes(CCs, boxes);
digits_set = CCsToImgs(imgEdge, CCs, CCboxInds);

end

function drawBoxes(img, boxes)
figure,
imshow(img)
hold on
for i = 1:size(boxes,1)
    rectangle('Position', boxes(i,:), 'EdgeColor', 'g')
end
hold off
end

function imgEdge = edgeFilter(img)
img = rgb2gray(img);
img = mat2gray(img);

laplacian = [1 1 1; 1 -8 1; 1 1 1];
imgEdge = conv2(imgaussfilt(img), laplacian, 'same');
imgEdge = imgEdge .* (imgEdge > 0.3);
end

function hist = projectHistogram(imgEdge, dim)
hist = reshape(sum(imgEdge, dim), 1, []);
end

function hist2 = preprocessHistHorizontal(hist1)
hist2 = hist1;
hist2(hist2 < 3) = 0;
hist2 = medfilt1(hist2, uint32(numel(hist2)*0.05));
end

function hist2 = preprocessHistVertical(hist1)
hist2 = hist1;
hist2 = medfilt1(hist2, 5);
end

function ranges = segmentHorizontal(imgEdge)
hist = projectHistogram(imgEdge, 2);
hist = preprocessHistHorizontal(hist);

ranges = getNonZeroRanges(hist);
end

function boxes = segmentVertical(imgEdge, rowRanges)
boxes = [];
for i = 1:size(rowRanges,1)
    imgEdgeRow = imgEdge(rowRanges(i,1):rowRanges(i,2),:);
	hist = projectHistogram(imgEdgeRow, 1);
    hist = preprocessHistVertical(hist);

    peaks = getPeaks(hist);
    thresholds = getThresholds(hist, peaks);
    colRanges = thresToRanges(hist, thresholds, sum(hist)*0.05);

    boxes = [boxes; rangesToBoxes(colRanges, rowRanges(i,:))];
end
end

function peaks = getPeaks(hist)
histRegionMax = imextendedmax(hist, 7);
peakRanges = getNonZeroRanges(histRegionMax);
peaks = round(mean(peakRanges, 2))';
end

function thresholds = getThresholds(hist, peaks)
thresholds = zeros(1, numel(peaks)-1);
for i = 1:numel(peaks)-1
   thresholds(i) = estimateThreshold(hist(peaks(i):peaks(i+1))) + peaks(i) - 1;
end
end

function T = estimateThreshold(hist)
n = numel(hist);
T = round(n/2);
iter = 30;
for i = 1:iter
    mu1 = grayLevelMean(hist, 1:T);
    mu2 = grayLevelMean(hist, T+1:n);

    dT = (mu1 + mu2)/2 - T;
    T = round(T + dT);
    if dT < 1 break, end
end
end

function mu = grayLevelMean(hist, range)
mu = sum(range .* hist(range))/sum(hist(range));
end

function ranges = thresToRanges(hist, thresholds, minFrequency)
cuts = unique([1 thresholds numel(hist)]);
n = numel(cuts);

ranges = [];
for i = 1:n-1
    nonZeroRanges = getNonZeroRanges(hist(cuts(i):cuts(i+1))) + cuts(i) - 1;
    nonZeroRanges = removeSmallFrequency(hist, nonZeroRanges, minFrequency);
    ranges = [ranges; min(nonZeroRanges(:,1)) max(nonZeroRanges(:,2))];
end
end

function ranges = removeSmallFrequency(hist, ranges, minFrequency)
n = size(ranges,1);
frequencies = zeros(1,n);
for i = 1:n
    frequencies(i) = sum(hist(ranges(i,1):ranges(i,2)));
end
ranges(frequencies<minFrequency,:) = [];
end

function boxes = rangesToBoxes(xranges, yrange)
x = xranges(:,1);
y = repmat(yrange(1), numel(x), 1);
w = xranges(:,2) - x + 1;
h = repmat(yrange(2), numel(x), 1) - y + 1;

boxes = [x y w h];
end

function ranges = getNonZeroRanges(hist)
n = numel(hist);
rows = 1;
ranges = [1 n];

histBW = hist > 0;
for i = 1:n-1
    if ~histBW(i) && histBW(i+1) % 01
        ranges(rows,:) = [i+1 n];
    end
    if histBW(i) && ~histBW(i+1) %10
        ranges(rows,2) = i;
        rows = rows + 1;
    end
end
end

function CCboxInds = mapCCsToBoxes(CCs, boxes)
n = CCs.NumObjects;
CCboxInds = zeros(1, n);
pixelsInBox = zeros(1, n);
for i = 1:n
    for j = 1:size(boxes,1)
        pixelsInBoxCurr = countPixels(CCs.PixelIdxList{i}, boxes(j,:), CCs.ImageSize);
        if pixelsInBoxCurr > pixelsInBox(i) && pixelsInBoxCurr/numel(CCs.PixelIdxList{i}) >= 0.3
            CCboxInds(i) = j;
            break
        end
    end
end
end

function pixelNum = countPixels(pixelList, box, imgSze)
[x1, y1, x2, y2] = boxToRange(box);
[Y, X] = ind2sub(imgSze, pixelList);
pixelNum = sum(X >= x1 & X <= x2 & Y >= y1 & Y <= y2);
end

function [x1, y1, x2, y2] = boxToRange(box)
x1 = box(1);
y1 = box(2);
x2 = x1 + box(3) - 1;
y2 = y1 + box(4) - 1;
end

function imgSet = CCsToImgs(imgEdge, CCs, CCboxInds)
boxInds = getValidBoxInds(CCboxInds);
imgNum = numel(boxInds);
imgCells = cell(1, imgNum);
imgSze = zeros(imgNum, 2);

% convert pixel list to image
for i = 1:imgNum
    pixelList = extractList(CCs.PixelIdxList, find(CCboxInds == boxInds(i)));
    [imgCells{i}, imgSze(i,:)] = pixelToImg(imgEdge, pixelList);
end

% pad and reshape
imgSzeSq = max(max(imgSze));
imgSet = zeros(imgNum, imgSzeSq * imgSzeSq);
for i = 1:imgNum
    squareImg = padImg(imgCells{i}, [imgSzeSq imgSzeSq]);
    imgSet(i,:) = squareImg(:)';
end

end

function boxInds = getValidBoxInds(CCboxInds)
boxInds = unique(CCboxInds, 'sorted');
boxInds(boxInds<=0) = [];
end

function pixelListMerged = extractList(pixelList, listInds)
pixelListMerged = [];
for i = 1:numel(listInds)
    pixelListMerged = [pixelListMerged; pixelList{listInds(i)}];
end
end

function [img2, imgSze] = pixelToImg(img1, pixelList)
[Y, X] = ind2sub(size(img1), pixelList);

x1 = min(X);
y1 = min(Y);
x2 = max(X);
y2 = max(Y);
Xnew = X - x1 + 1;
Ynew = Y - y1 + 1;

w = x2 - x1 + 1;
h = y2 - y1 + 1;
imgSze = [h w];

img2 = zeros(h, w);
for i = 1:numel(pixelList)
    img2(Ynew(i),Xnew(i)) = img1(pixelList(i));
end
end

function imgPad = padImg(img, targetSze)
imgPad = zeros(targetSze);

[h1, w1, ~] = size(img);
h2 = targetSze(1);
w2 = targetSze(2);

ystart = floor((h2 - h1)/2) + 1;
xstart = floor((w2 - w1)/2) + 1;

imgPad(ystart:ystart+h1-1,xstart:xstart+w1-1) = img;
end