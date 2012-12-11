function [bbAllCrop] = cropBB(im,bbAll)
    bbAllCrop = zeros(size(bbAll));
    for (p=1:size(bbAll,1))
        partTemp = im(bbAll(p,1):bbAll(p,3),bbAll(p,2):bbAll(p,4));
        bbAllCrop(p,1) = find(sum(partTemp,2) > 0,1,'first') + bbAll(p,1)-1;
        bbAllCrop(p,3) = find(sum(partTemp,2) > 0,1,'last') + bbAll(p,1)-1;

        bbAllCrop(p,2) = find(sum(partTemp,1) > 0,1,'first') + bbAll(p,2)-1;
        bbAllCrop(p,4) = find(sum(partTemp,1) > 0,1,'last') + bbAll(p,2)-1;
    end
