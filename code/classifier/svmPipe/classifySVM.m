function [model, probEstimates, classMap] = ...
          classifySVM(params, trainFeaturesAll, testFeaturesAll, trainLabels, testLabels)

    classMap = unique(trainLabels);    
    for (m=1:size(classMap,1))
        classUse = classMap(m);
        [model{m}, probEstimates(:,m)] = ...
            doClassifySVM(classUse, trainFeaturesAll, testFeaturesAll, trainLabels, testLabels, params);
        display(['Class ', int2str(m)]);
    end
end