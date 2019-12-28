% hough_transform_syn contains the implementation of main routine for Question
% 2 in Assignment 2. This function uses circular Hough Transform to detect circles
% in a binary image. Given that the radius of the circles is 50 pixels. Note
% that you are not allow to use the imfindcircles matlab built-in function
% in this question.

function hough_transform_syn(IM)

    % Convert the input image to the binary image
    img = im2bw(IM);
    % Display the input image
    figure;
    imshow(img);title('Input image');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % TODO_1: Find the edge of the image
    % imgBW = ??
    imgBW = edge(img);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    figure;    
    imshow(imgBW);title('Edge');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % TODO_2: Perform the circular Hough Transform. Given that the radius
    % of the circles is 50 pixels. Create a varible 'Accumulator' to store
    % the bin counts.
    % Accumulator = ??
    
    radius = 50;
    [h, w, ~] = size(imgBW);
    
    thetaRes = pi/90;
    thetaScale = 0:thetaRes:2*pi - thetaRes;
    cosThetas = cos(thetaScale);
    sinThetas = sin(thetaScale);
    
    Accumulator = zeros(h, w);
    edgePtInds = find(imgBW);

    for i = 1:numel(edgePtInds)
        [y, x] = ind2sub([h, w], edgePtInds(i));
        
        a = round(x - radius * cosThetas);
        b = round(y - radius * sinThetas);
        invalid = a < 1 | a > w | b < 1 | b > h;
        a(invalid) = [];
        b(invalid) = [];
        
        for aInd = 1:numel(a)
            Accumulator(b(aInd), a(aInd)) = Accumulator(b(aInd), a(aInd)) + 1;
        end    
    end
       
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %Visualize the Accumulator cells
    figure;
    imagesc(Accumulator);title('Accumulator cells');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % TODO_3: Search for the highest count cell in 'Accumulator' and store the
    % x,y-coordinate in two separate arrays. Note that there should be 2 sets of x and
    % y-coordinate, ie: x_cir = [{value1};{value2}] , y_cir = [{value1};{value2}]
    % x_cir = ??
    % y_cir = ??
    [~, maxInds] = maxk(Accumulator(:), 2);
    [y_cir, x_cir] = ind2sub([h w], maxInds);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Plot the results using red line
    figure;
    imshow(imgBW);title('Locate the circles');
    hold on;
    plot(x_cir(:),y_cir(:),'x','LineWidth',2,'Color','red');
    radlist = repmat(50,1,length(x_cir));
    viscircles([x_cir(:) y_cir(:)], radlist(:),'EdgeColor','r');
    
