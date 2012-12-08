function [res] = doPooling(ims, pooling, poolingMode)
% featurePatches 4D; [nY, nX, C, nEx]
% res: each row is an example

    res = [];
    for (i=1:size(pooling,1))
        [temp] = poolSpatialFeatures(ims, poolingMode, pooling(i,:));
        res = cat(2,res,temp);
    end
end

function [res] = poolSpatialFeatures(ims, poolingMode, nPools)

    [nY,nX,C,nEx] = size(ims);
    [startY, startX, lenStride] = getSpatialGrid([nY,nX],nPools);
        
    res= zeros(nEx,C*size(startY,1)*size(startX,1));
    marker = 1;
    for (i=1:size(startY,1))
        for(j=1:size(startX,1))
            feat = ims(startY(i):startY(i)+lenStride(1)-1, ...
                       startX(j):startX(j)+lenStride(2)-1,...
                       :,:);
            switch(poolingMode)
                case 0 
                    feat = mean(mean(feat,1),2);
                case 1
                    feat = max(max(feat,[],1),[],2);
                case 2
                    feat = sum(sum(feat,1),2);
                otherwise
                    error(['Unrecognized poolingMode: ', int2str(poolingMode)]);
            end
            feat = reshape(feat, [C,nEx]);
            res(:,marker:marker+C-1) = feat';
            marker = marker+C;
        end
    end
end

function [startY, startX, lenStride] = getSpatialGrid(patchDims,nPools)

    
    lenStride = floor(patchDims./nPools);
    
    startY = lenStride(1)*[0:nPools(1)-1]' + 1;
    startX = lenStride(2)*[0:nPools(2)-1]' + 1;
    
    len1Offset = floor((patchDims(1) - (startY(end) + lenStride(1) - 1))/2);
    len2Offset = floor((patchDims(2) - (startX(end) + lenStride(2) - 1))/2);
    
    % Centre grid
    startY = startY + len1Offset;
    startX = startX + len2Offset;
end

