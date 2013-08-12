function [model, probEstimates, predictLabels, classMap, fMax] = ...
          classifySVM(params, trainClassInds, testClassInds, KTrain, KTest, mix)
    %input:
        % features{f}: [N,T] cell matrix, where N= number of features, for 
        %              feature type f, for T images   
        % classInds: 1D vector of class labels (identifiers, do not have to be sequential)

    assert(size(KTrain,2) == size(KTest,2));
    useMix = exist('mix', 'var');
    
    if (useMix)
        KTrainAll = 0;
        KTestAll = 0;
    
        assert(sum(mix) == 1);
        assert(numel(mix) == size(KTrain,2));
    end

    for (f=1:size(KTrain,2))
        if (useMix)
            KTrainAll = KTrainAll + mix(f)*KTrain{f};
            KTestAll = KTestAll + mix(f)*KTest{f};
        else
            KTrainAll{f} = KTrain{f};
            KTestAll{f} = KTest{f};
        end
    
    end
    if(useMix)
        KTrainAllUse{1} = KTrainAll;
        KTestAllUse{1} = KTestAll;
        
        KTrainAll = KTrainAllUse;
        KTestAll = KTestAllUse;
    end
    
    classMap = unique(trainClassInds);
    for (m=1:size(classMap,1))
        display(['Classifying for class: ', int2str(m), '/', int2str(size(classMap,1))]);
        classUse = classMap(m);
        [model{m}, probEstimates(:,m), predictLabels(:,m), fMax(:,m)] = ...
            doClassifySVM(classMap(m), KTrainAll, KTestAll, trainClassInds, testClassInds, params);
    end
end

