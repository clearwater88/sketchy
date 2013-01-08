function [strFeat,strClassify] = toString(params,trialNum)

    Ctrain = 0;
    for (c=1:numel(params.classTrain))
        Ctrain = Ctrain+2^params.classTrain(c);
    end
    if (params.sameClass == 0)
        Ctest = 0;
        for (c=1:numel(params.classTest))
            Ctest = Ctest+2^params.classTest(c);
        end
    else
        Ctest = Ctrain;
    end

    strFeat = sprintf('poolingLevs%d_poolMode%d_feat%d_numIm%d_trial%d', ...
                      size(params.pooling,1), params.poolMode, ...
                      params.featType,params.nIm,trialNum);
                  
    strClassify = sprintf(' kern%d_sameClass%d_cltrain%d_cltest%d_', params.svmKern, params.sameClass, Ctrain,Ctest);
end

