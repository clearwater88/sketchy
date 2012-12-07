function res = getSimpleResponses(gabors,ims)

    nGabors = size(gabors,3);
    res = zeros(numel(ims),nGabors);
    for (i=1:numel(ims))
        clear temp;
        
        for (j=1:nGabors)
            imFilt = conv2(ims{i},gabors(:,:,j),'same');
            if (~exist('temp','var'))
                temp = zeros([size(ims{i}),nGabors]);
            end
            temp(:,:,i) = imFilt;
        end
    end
end

