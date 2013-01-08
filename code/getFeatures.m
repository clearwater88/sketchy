function res = getFeatures(parts,params)

    switch(params.featType)
        case 0
            gabors = gaborBank();
            gabors = reshape(gabors,[size(gabors,1), ...
                                     size(gabors,2), ...
                                     numel(gabors)/(size(gabors,1)*size(gabors,2))]);
            
            doRectify = 0;
            
            display(['Gabor features, rectify: ', int2str(doRectify)]);
            res = getGaborResponses(gabors,parts,params.pooling,params.poolMode,doRectify);
        case 1
            gabors = gaborBank();
            gabors = reshape(gabors,[size(gabors,1), ...
                                     size(gabors,2), ...
                                     numel(gabors)/(size(gabors,1)*size(gabors,2))]);
            doRectify = 1;
            
            display(['Gabor features, rectify: ', int2str(doRectify)]);
            res = getGaborResponses(gabors,parts,params.pooling,params.poolMode,doRectify);
        case 2
            summarizeLocal = 1;
            [y,x]=meshgrid(-1:1,-1:1);
            shifts = [y(:),x(:)];
            
            display(['Local feature, summarize local: ', int2str(summarizeLocal)]);
            res = getLocalPixelFeat(parts,params.pooling,params.poolMode,summarizeLocal,shifts);
        case 3
            summarizeLocal = 0;
            [y,x]=meshgrid(-1:1,-1:1);
            shifts = [y(:),x(:)];
            
            display(['Local feature, summarize local: ', int2str(summarizeLocal)]);
            res = getLocalPixelFeat(parts,params.pooling,params.poolMode,summarizeLocal,shifts);
        case 4
            summarizeLocal = 1;
            shifts = [-1,-1;-1,1;1,-1;1,1];
            
            display([': ', int2str(summarizeLocal)]);
            res = getLocalPixelFeat(parts,params.pooling,params.poolMode,summarizeLocal,shifts);
        case 5
            gabors = gaborBank();
            doRectify = 0;
            
            nPsi = size(gabors,3);
            nLambda = size(gabors,4);
            nTheta = size(gabors,5);

            res = zeros([numel(parts),nTheta*sum(prod(params.pooling,2)),nPsi*nLambda]);
            
            display(['Gabor features complex cell, rectify: ', int2str(doRectify)]);
            for (i=1:nPsi)
                for (j=1:nLambda)
                    display(['On psi/lambda: ' , int2str(i),'/',int2str(j)]);
                    gaborsUse = reshape(gabors(:,:,i,j,:), ...
                        [size(gabors,1), size(gabors,2), ...
                        nTheta]);
                    res(:,:,(i-1)*nLambda+j) = getGaborResponses(gaborsUse,parts,params.pooling,params.poolMode,doRectify);
                end
            end
            switch(params.poolMode)
                case 0
                    res = mean(res,3);
                case 1
                    res = max(res,[],3);
                case 2
                    res = sum(res,3);
                otherwise
                    error(['Unrecognized poolingMode: ', int2str(params.poolingMode)]);
            end
        case 6
            gabors = gaborBank();
            doRectify = 1;
            
            nPsi = size(gabors,3);
            nLambda = size(gabors,4);
            nTheta = size(gabors,5);

            res = zeros([numel(parts),2*nTheta*sum(prod(params.pooling,2)),nPsi*nLambda]);
            
            display(['Gabor features complex cell, rectify: ', int2str(doRectify)]);
            for (i=1:nPsi)
                for (j=1:nLambda)
                    display(['On psi/lambda: ' , int2str(i),'/',int2str(j)]);
                    gaborsUse = reshape(gabors(:,:,i,j,:), ...
                        [size(gabors,1), size(gabors,2), ...
                        nTheta]);
                    res(:,:,(i-1)*nLambda+j) = getGaborResponses(gaborsUse,parts,params.pooling,params.poolMode,doRectify);
                end
            end
            switch(params.poolMode)
                case 0
                    res = mean(res,3);
                case 1
                    res = max(res,[],3);
                case 2
                    res = sum(res,3);
                otherwise
                    error(['Unrecognized poolingMode: ', int2str(params.poolingMode)]);
            end
        otherwise
            error('Bad feature type: %d', params.featType);
        
    end

end

