%% parameters
global ppParam
global ltpParam
global distParam

subsetToTest = 1:5;
% preprocess parameters
ppParam.gamma = 0.25;
ppParam.sigma1 = 0.3;
ppParam.sigma2 = 2;
ppParam.alpha = 0.03;
ppParam.tau = 13;
% ltp parameters
ltpParam.t = 0.07;
ltpParam.N = 8;
ltpParam.R = 2;
ltpParam.useUniform = false;
% distance paramters
distParam.bitNum = ltpParam.N;

%% load dataset
[testSet, testLabels, testSubsetLabels, classSet, classLabels, imgSze] = loadYaleB();
classNum = length(classLabels);
testNum = length(testLabels);

%% main

% process each class
classFeatures = cell(1, classNum);
for i = 1:classNum
    classImg = reshape(classSet(i,:), imgSze);
    classFeatures{i} = processChain(classImg);
end

% test each subset
labels = cell(1, max(testSubsetLabels));
for s = subsetToTest
    fprintf("test subset %d...\n", s);
    
    % extract subset
    [subSet, subLabel, subSetNum] = getSubSet(testSet, testLabels, testSubsetLabels, s);

    % test each image
    for i = 1:subSetNum
        if mod(i, 100) == 0 fprintf("image %d/%d...\n", i, subSetNum); end

        % process image
        img = reshape(subSet(i,:), imgSze);
        feature = processChain(img);
        
        % classify
        dists = zeros(1,classNum);
        for j = 1:classNum
            dists(j) = distance(feature, classFeatures{j});
        end
        [~, minInd] = min(dists);
        
        % store result
        labels{s}(i,1) = subLabel(i); % true label
        labels{s}(i,2) = classLabels(minInd); % estimated label
    end
end

%% print result
recognitionTotal = 0;
for s = subsetToTest
    recognitionNum = nnz(labels{s}(:,1)==labels{s}(:,2));
    recognitionRate = 100 * recognitionNum / size(labels{s}, 1);
    fprintf("recognition rates (%%) of subet %d is {%f%%}\n", s, recognitionRate);

    recognitionTotal = recognitionTotal + recognitionNum;
end
recognitionRate = 100 * recognitionTotal / testNum;
fprintf("Overall recognition rates (%%) on Extended Yale-B is {%f%%}\n", recognitionRate);

%% helper
function feature = processChain(img)
global ppParam
global ltpParam

img = preprocess(img, ppParam.gamma, ppParam.sigma1, ppParam.sigma2, ppParam.alpha, ppParam.tau);
feature = ltp(img, ltpParam.t, ltpParam.N, ltpParam.R, ltpParam.useUniform);
end

function dist = distance(feature1, feature2)
global distParam
dist = hammingDistanceBit(feature1, feature2, distParam.bitNum);
end

function [subSet, subLabel, subSetNum] = getSubSet(testSet, testLabels, testSubsetLabels, s)
subSet = testSet(testSubsetLabels==s,:);
subLabel = testLabels(testSubsetLabels==s);
subSetNum = size(subSet, 1);
end
