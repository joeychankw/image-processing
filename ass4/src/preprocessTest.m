% preprocess parameters
ppParam.gamma = 0.25;
ppParam.sigma1 = 0.3;
ppParam.sigma2 = 2;
ppParam.alpha = 0.03;
ppParam.tau = 13;

% load dataset
load YaleB_32x32.mat fea gnd;
dataset = fea;
labels = gnd;

persons = 1;
faces = 1:8:64;


for i = persons
    dataInd = find(labels==i);
   
    % show original image
    figure,
    hold on
    for j = 1:numel(faces)
        img = reshape(dataset(dataInd(faces(j)),:), imgSze);
        subplot(2,4,j)
        imshow(mat2gray(img))
    end
    hold off
    
    % show after preprocess
    figure,
    hold on
    for j = 1:numel(faces)
        img = reshape(dataset(dataInd(faces(j)),:), imgSze);
        subplot(2,4,j)
        imshow(mat2gray(preprocessSplitParam(img)))
    end
    hold off
end

function img = preprocessSplitParam(img)
global ppParam
img = preprocess(img, ppParam.gamma, ppParam.sigma1, ppParam.sigma2, ppParam.alpha, ppParam.tau);
end