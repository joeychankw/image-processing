function dist = hammingDistanceBit(feature1, feature2, bits)
% Hamming distance for binary

xor = bitxor(feature1, feature2);
numOfOne = 0;

for i = 0:bits-1
    shiftedOne = 2^i;
    numOfOne = numOfOne + nnz(bitand(xor, shiftedOne));
end

dist = numOfOne;
end