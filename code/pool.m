function [res] = pool(feat,poolingMode)
    switch(poolingMode)
        case 0
            res = mean(mean(feat,1),2);
        case 1
            res = max(max(feat,[],1),[],2);
        case 2
            res = sum(sum(feat,1),2);
        otherwise
            error(['Unrecognized poolingMode: ', int2str(poolingMode)]);
    end
end

