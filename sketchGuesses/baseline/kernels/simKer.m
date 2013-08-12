function [KTrainAll, KTestAll] = simKer()
    nEx = 50;
    nDim = 6;
    
    trainClassInds = [1:nEx]';
    testClassInds = [1:nEx]';
    
    x = rand(nDim,nEx); % columns are the data
    y = rand(nDim,nEx);
    
    KTrainAll = zeros(nEx,nEx);
    for (x1=1:nEx)
        for (x2=1:nEx)
            KTrainAll(x1,x2) = calcK(x(:,x1), x(:,x2));
        end
    end

    KTestAll = zeros(nEx,nEx);
    for (x1=1:nEx)
        for (x2=1:nEx)
            KTestAll(x1,x2) = calcK(y(:,x1), x(:,x2));
        end
    end
    
    params = initParams(1);
    classMap = unique(trainClassInds);
    
    display('Starting');
    params.svmCross = 0;
    
    for (m=1:size(classMap,1))
        [model{m}, probEstimates(:,m), predictLabels(:,m)] = ...
            doClassifySVM(classMap(m), KTrainAll, KTestAll, trainClassInds, testClassInds, params);
    end
    [multiClass, allWinners] = getMultiClass(probEstimates, testClassInds, classMap);
    multiClass
    
end

