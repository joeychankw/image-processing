function [testSet, testLabels, testSubsetLabels, classSet, classLabels, imgSze] = loadYaleB()
% load
load YaleB_32x32.mat fea gnd;
dataset = fea;
labels = gnd;

% extract neutral face to class set
classSet = [];
classLabels = [];
for label = 1:max(labels)
    ind = find(labels==label, 1, 'first');
    
    classSet(end+1,:) = dataset(ind,:);
    classLabels(end+1,:) = label;
    
    dataset(ind,:) = [];
    labels(ind,:) = [];
end

% remaining to test set
testSet = dataset;
testLabels = labels;

% subset
subset = [2 3 5 1 3 1 1 1 2 2 2 2 3 3 3 3 4 3 3 4 4 4 4 4 4 5 5 5 5 5 5 5 5 5 1 1 1 1 2 2 2 3 2 3 3 4 3 3 4 4 4 4 4 4 5 5 5 5 5 5 5 5 5];
subset11 = [2 3 5 1 3 1 1 1 2 2 2 2 3 3 3 3 4 3 3 4 4 4 4 4 4 5 5 5 5 5 5 5 1 1 1 1 2 2 2 3 2 3 3 4 3 3 4 4 4 4 5 5 5 5 5 5 5 5 5];
subset12 = [2 3 5 1 3 1 1 1 2 2 2 2 3 3 3 3 4 3 3 4 4 4 4 4 4 5 5 5 5 5 5 5 1 1 1 1 2 2 2 3 2 3 3 4 3 3 4 4 4 4 5 5 5 5 5 5 5 5];
subset13 = subset11;
subset14 = [2 3 5 1 3 1 1 1 2 2 2 2 3 3 3 3 4 3 3 4 4 4 4 4 4 5 5 5 5 5 5 5 5 5 1 1 1 1 2 2 2 3 2 3 4 3 3 4 4 4 4 4 4 5 5 5 5 5 5 5 5 5];
subset15 = [2 3 5 1 3 1 1 1 2 2 2 2 3 3 3 3 4 3 3 4 4 4 4 4 4 5 5 5 5 5 5 5 5 1 1 1 2 2 2 3 2 3 3 4 3 3 4 4 4 4 4 4 5 5 5 5 5 5 5 5 5];
subset16 = [2 3 5 1 3 1 1 1 2 2 2 2 3 3 3 3 4 3 3 4 4 4 4 4 4 5 5 5 5 5 5 5 5 5 1 1 1 2 2 2 3 2 3 3 4 3 3 4 4 4 4 4 4 5 5 5 5 5 5 5 5 5];
subset17 = subset16;
testSubsetLabels = [repmat(subset, 1, 10) subset11 subset12 subset13 subset14 subset15 subset16 subset17 repmat(subset, 1, 21)]';

% image size
imgSze = [32 32];
end