function [multiClass,confuse,allWinners,tp,fp] = mainPartClassify(params,trialNum)

    [featFile,classifyPart] = toString(params,trialNum);
    featFile = ['feats_',featFile];
    classifierFile = ['res_',classifyPart,featFile];

    if (exist([classifierFile,'.mat'],'file'))
        display(['File ', classifierFile, ' exists. Loading']);
        load(classifierFile,'multiClass','confuse','allWinners','tp','fp');
        return;
    end

    [posFeat,negFeat] = getPartFeatures(params.classTrain,params,trialNum,featFile);
    
    if(params.sameClass)
        [trainFeat,testFeat,trainLabels,testLabels] = splitFeat(posFeat,negFeat);
    else
        [trainFeat,testFeat,trainLabels,testLabels] = splitFeat(posFeat,negFeat);
        trainFeat = [trainFeat;testFeat]; clear posFeat; clear negFeat;
        trainLabels = [trainLabels;testLabels];

        [posFeat,negFeat] = getPartFeatures(params.classTest,params,trialNum,featFile);
        [trainFeat2,testFeat2,trainLabels2,testLabels2] = splitFeat(posFeat,negFeat);
        testFeat = [trainFeat2;testFeat2]; clear posFeat; clear negFeat;
        testLabels = [trainLabels2;testLabels2];
    end

    [model, probEstimates, classMap] = ...
              classifySVM(params, trainFeat, testFeat, trainLabels, testLabels);
    [multiClass,confuse,allWinners,tp,fp] = getPerform(probEstimates, testLabels, classMap);
    
    save(classifierFile, ...
            'params','probEstimates','classMap', ...
            'multiClass','confuse','allWinners', ...
            'tp','fp', 'trainLabels','testLabels', '-v7.3');
end