function mainPartClassify(params,trialNum)

    gabors = gaborBank();
    nGabors = size(gabors,3);

    saveFile = toString(params,trialNum);

    [partsPos,partsNeg] = extractExampleParts(params.classTrain,params.nIm);

    posFeat = getResponses(gabors,partsPos,params.pooling,params.poolMode);
    negFeat = getResponses(gabors,partsNeg,params.pooling,params.poolMode);

    if (params.sameClass)
        [trainFeat,testFeat,trainLabels,testLabels] = splitFeat(posFeat,negFeat);
    else
        %%% never seen classes %%%
        [trainFeat,testFeat,trainLabels,testLabels] = splitFeat(posFeat,negFeat);
        trainFeat = [trainFeat;testFeat];
        trainLabels = [trainLabels;testLabels];

        [partsPos2,partsNeg2] = extractExampleParts(params.classTest,params.nIm);

        posFeat2 = getResponses(gabors,partsPos2,params.pooling,params.poolMode);
        negFeat2 = getResponses(gabors,partsNeg2,params.pooling,params.poolMode);

        [trainFeat2,testFeat2,trainLabels2,testLabels2] = splitFeat(posFeat2,negFeat2);
        testFeat = [trainFeat2;testFeat2];
        testLabels = [trainLabels2;testLabels2];
        %%% never seen classes %%%
    end

    [model, probEstimates, classMap] = ...
              classifySVM(params, trainFeat, testFeat, trainLabels, testLabels);
    [multiClass,confuse,allWinners,tp,fp] = getPerform(probEstimates, testLabels, classMap);
    save(['res',saveFile],'probEstimates','classMap','multiClass','confuse','allWinners','tp','fp', 'testLabels', '-v7.3');
end