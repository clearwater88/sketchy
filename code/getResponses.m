function res = getResponses(gabors,ims,pooling,poolMode)

    nGabors = size(gabors,3);

    nFeat = 2*sum(prod(pooling,2)*nGabors);
    res = zeros(numel(ims),nFeat);
    for (i=1:numel(ims))
        clear temp;
        display(['On image ', int2str(i), ' of ', int2str(numel(ims))]);
        for (j=1:nGabors)
            imFilt = conv2(ims{i},gabors(:,:,j),'same');
            if (~exist('temp','var'))
                temp = zeros([size(ims{i}),nGabors]);
            end
            temp(:,:,j) = imFilt;
        end
        tempPosRect = doPooling(abs(temp).*(temp>0),pooling,poolMode);
        tempNegRect = doPooling(abs(temp).*(temp<0),pooling,poolMode);
        res(i,:) = [tempPosRect,tempNegRect];
    end
    
end

