% connected_component.m contains the implementation of the main routine for Question 1 in Assignment 2. 
% This function search for all connected component on the input image. It should output the total number of
% connected components, number of pixels in each connected component and
% display the largest connected component. Note that you are not allow to
% use the bwlabel/bwlabeln/bwconncomp matlab built-in function in this
% question.

function L_CC = connected_component(IM)
    % Convert it to binary image (0,1)
    BW = im2bw(IM);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% TODO_1: Search for all connected component with connectivity equals
	% to 8 and output the result to the command window in following format:
    % There are total {number of regions} region(s) :
    % Region 1, no. of pixels = {number of pixels}
    % Region 2, no. of pixels = {number of pixels}
    % ...
    
    B = true(3, 3); % structure element
    CCs = {}; % cell array for storing region image & no. of pixels
    
    % iterate for each cc
    remain = BW;
    while any(any(remain))
                
        A = false(size(BW));
        prevPixelNum = 0;
        
        % set first point
        firstPt = find(remain);
        firstPt = firstPt(1);
        A(firstPt) = true;
        
        % iterate until no changes
        while nnz(A) ~= prevPixelNum
            prevPixelNum = nnz(A);
            A = and(imdilate(A, B), remain);
        end
        
        CCs{end+1, 1} = A;
        CCs{end, 2} = nnz(A);
        remain = xor(remain, A);
    end

    % print result
    fprintf('There are total %d region(s):\n', size(CCs, 1))
    for i = 1:size(CCs, 1)
        fprintf('Region %d, no. of pixels = %d\n', i, CCs{i, 2})
    end
    fprintf('\n')

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% TODO_2: Find the largest connected component in binary format (0,1).
	% L_CC = ??
    
    if ~isempty(CCs)
        [~, maxInd] = max([CCs{:,2}]);
        L_CC = CCs{maxInd,1};
    else
        L_CC = false(size(BW));
    end
    
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    figure;
    subplot(121);imshow(BW);title('Input image');
    subplot(122);imshow(L_CC);title('Largest connected component');

end

