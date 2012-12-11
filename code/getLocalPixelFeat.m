function res = getLocalPixelFeat(parts,pooling,poolMode,summarizeLocal,shifts)

    if(summarizeLocal)
        nFeats = sum(prod(pooling,2)*2^9);
    else
        nFeats = sum(prod(pooling,2)*9);
    end
    nParts = numel(parts);
    
    res = zeros(nParts,nFeats);
    
    for (p=1:nParts)
        if (mod(p,5) == 0)
            display(['Extracting pixel feature on part: ', int2str(p), ' of ', int2str(nParts)]);
        end
        partUse = parts{p};
        window = meshgridRaster(1:size(partUse,1),1:size(partUse,2));
        temp = zeros([size(partUse),9]);

        for (i=1:size(shifts,1))
            temp(:,:,i) = nocircshift(partUse,shifts(i,:));
        end

        if (summarizeLocal)
            tempFeatCode = zeros(size(partUse));
            for (i=1:9)
                tempFeatCode = 2*tempFeatCode+temp(:,:,i);
            end
            tempFeatCode = tempFeatCode+1; % for matlab indexing
        
            tempFeat = zeros([size(partUse),2^9]);
            tempFeat = tempFeat(:);
            tempFeat(sub2ind([size(partUse),2^9],window(:,1),window(:,2),tempFeatCode(:))) = 1;
            tempFeat = reshape(tempFeat,[size(partUse),2^9]);
        
            res(p,:) = doPooling(tempFeat,pooling,poolMode);
        else
            res(p,:) = doPooling(temp,pooling,poolMode);
        end
    end
end