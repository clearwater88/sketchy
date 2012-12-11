function [multiClass,confuse,allWinners,tp,fp] = mainPartClassify(params,trialNum)

    saveFile = toString(params,trialNum);

    [partsPos,partsNeg] = extractExampleParts(params.classTrain,params.nIm);

    posFeat = getFeatures(partsPos,params);
    negFeat = getFeatures(partsNeg,params);

    if (params.sameClass)
        [trainFeat,testFeat,trainLabels,testLabels] = splitFeat(posFeat,negFeat);
    else
        %%% never seen classes %%%
        [trainFeat,testFeat,trainLabels,testLabels] = splitFeat(posFeat,negFeat);
        trainFeat = [trainFeat;testFeat];
        trainLabels = [trainLabels;testLabels];

        [partsPos2,partsNeg2] = extractExampleParts(params.classTest,params.nIm);

        posFeat2 = getFeatures(partsPos2,params);
        negFeat2 = getFeatures(partsNeg2,params);

        [trainFeat2,testFeat2,trainLabels2,testLabels2] = splitFeat(posFeat2,negFeat2);
        testFeat = [trainFeat2;testFeat2];
        testLabels = [trainLabels2;testLabels2];
        %%% never seen classes %%%
    end

    [model, probEstimates, classMap] = ...
              classifySVM(params, trainFeat, testFeat, trainLabels, testLabels);
    [multiClass,confuse,allWinners,tp,fp] = getPerform(probEstimates, testLabels, classMap);
    save(['res',saveFile],'params','probEstimates','classMap', ...
                          'multiClass','confuse','allWinners', ...
                          'tp','fp', 'testLabels', '-v7.3');
end