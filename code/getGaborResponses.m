function res = getGaborResponses(gabors,parts,pooling,poolMode,doRectify)
    % res: #parts x nFeat, nFeat = nGabors*nPooling
    nGabors = size(gabors,3);

    nFeat = sum(prod(pooling,2)*nGabors);
    if (doRectify)
        nFeat = 2*nFeat;
    end
    
    res = zeros(numel(parts),nFeat);
    nParts = numel(parts);
    
    for (i=1:nParts)
        clear temp;
        if (mod(i,10) == 0)
            display(['On part ', int2str(i), ' of ', int2str(numel(parts))]);
        end
        for (j=1:nGabors)
            imFilt = conv2(parts{i},gabors(:,:,j),'same');
            if (~exist('temp','var'))
                temp = zeros([size(parts{i}),nGabors]);
            end
            temp(:,:,j) = imFilt;
        end
        if (doRectify)
            tempPosRect = doPooling(abs(temp).*(temp>0),pooling,poolMode);
            tempNegRect = doPooling(abs(temp).*(temp<0),pooling,poolMode);
            res(i,:) = [tempPosRect,tempNegRect];
        else
            res(i,:) = doPooling(temp,pooling,poolMode);
        end
    end
    
end

