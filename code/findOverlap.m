function [percentOverlap] = findOverlap(imStack,bbNeg,imSize)
    areasStack = sum(sum(imStack,1),2);
    
    imNeg = zeros(imSize);
    imNeg(bbNeg(1):bbNeg(3),bbNeg(2):bbNeg(4)) = 1;
    areaImNeg = sum(imNeg(:));
    
    areaInt = double(bsxfun(@and,imStack,imNeg));
    areaInt = sum(sum(areaInt,1),2);
    percentOverlap = 2*areaInt./(areasStack+areaImNeg);

end

