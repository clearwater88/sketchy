function res = getFeatures(parts,params)

    switch(params.featType)
        case 0
            gabors = gaborBank();
            doRectify = 0;
            
            display(['Gabor features, rectify: ', int2str(doRectify)]);
            res = getGaborResponses(gabors,parts,params.pooling,params.poolMode,doRectify);
        case 1
            gabors = gaborBank();
            doRectify = 1;
            
            display(['Gabor features, rectify: ', int2str(doRectify)]);
            res = getGaborResponses(gabors,parts,params.pooling,params.poolMode,doRectify);
        case 2
            summarizeLocal = 1;
            
            display(['Local feature, summarize local: ', int2str(summarizeLocal)]);
            res = getLocalPixelFeat(parts,params.pooling,params.poolMode,summarizeLocal);
        case 3
            summarizeLocal = 0;
            
            display(['Local feature, summarize local: ', int2str(summarizeLocal)]);
            res = getLocalPixelFeat(parts,params.pooling,params.poolMode,summarizeLocal);
        otherwise
            error('Bad feature type: %d', params.featType);
    end

end

