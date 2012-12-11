function [str] = toString(params,trialNum)

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
    

    str = sprintf('kern%d_poolingLevs%d_poolMode%d_feat%d_cltrain%d_cltest%d_trial%d', ...
                   params.svmKern,size(params.pooling,1), params.poolMode, ...
                   params.featType,Ctrain,Ctest,trialNum);
               
end

