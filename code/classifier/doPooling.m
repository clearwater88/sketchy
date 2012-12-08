function [res] = doPooling(ims, pooling, poolingMode)
% featurePatches 4D; [nPatchX, nPatchY, C, nEx]
% res: each row is an example

    res = [];
    for (i=1:size(pooling,1))
        [temp] = poolSpatialFeatures(ims, poolingMode, pooling(i,:));
        res = cat(2,res,temp);
    end
end

function [res] = poolSpatialFeatures(ims, poolingMode, nPools)

    [nX,nY,C,nEx] = size(ims);
    [startX, startY, lenStride] = getSpatialGrid([nX,nY],nPools);
        
    res= zeros(nEx,C*size(startX,1)*size(startY,1));
    marker = 1;
    for (i=1:size(startX,1))
        for(j=1:size(startY,1))
            feat = ims(startX(i):startX(i)+lenStride(1)-1, ...
                       startY(j):startY(j)+lenStride(2)-1,...
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

function [startX, startY, lenStride] = getSpatialGrid(patchDims,nPools)

    
    lenStride = floor(patchDims./nPools);
    
    startX = lenStride(1)*[0:nPools(1)-1]' + 1;
    startY = lenStride(2)*[0:nPools(2)-1]' + 1;
    
    len1Offset = floor((patchDims(1) - (startX(end) + lenStride(1) - 1))/2);
    len2Offset = floor((patchDims(2) - (startY(end) + lenStride(2) - 1))/2);
    
    % Centre grid
    startX = startX + len1Offset;
    startY = startY + len2Offset;
end

