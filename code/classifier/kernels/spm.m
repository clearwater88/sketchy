function [res] = spm(x1, x2, numFeatures, params)
% Evaluate a spatial pyramid kernel

    counter = 1;
    inter = [];
    weight = [];
    
    pooling = params.pooling;
    pDims = params.pDims;
    for (i=1:size(pooling,1))
    	[temp,counter] = processLevel(x1,x2,counter,numFeatures,pooling(i,:));
        weightUse = sqrt(prod(pooling(i,:)));
        
        inter = cat(3,inter,temp);
        weight = cat(1,weight,weightUse);
    end
    
    numLevels = size(weight,1);
    weight = weight/max(weight);
    
    % Use simplifcation in paper
    res = weight(1)*inter(:,:,1);
    for (ll=2:numLevels)
        res = res + (weight(ll)/2)*(inter(:,:,ll)); % Weight is 2/(L-ll)
    end
end

function [res,counter] = processLevel(x1,x2,counter,numFeatures, pDims)
        numPatchesLevel = prod(pDims);
        res = histInter(x1(:,counter:counter + numPatchesLevel*numFeatures-1), ...
                        x2(:,counter:counter + numPatchesLevel*numFeatures-1));
        counter = counter + numPatchesLevel*numFeatures;
end

