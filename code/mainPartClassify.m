function [multiClass,confuse,allWinners,tp,fp] = mainPartClassify(params,trialNum)

    [featFile,classifyPart] = toString(params,trialNum);
    featFile = ['feats_',featFile];
            
    %somewhat pointless, since we still need to pool during feature
    %extraction
    if(~exist([featFile,'.mat'],'file'))
        display(['Feature file does not exist. Computing...']);

        [partsPos,partsNeg,imsUse] = extractExampleParts(params.classTrain,params.nIm,trialNum);

        posFeat = getFeatures(partsPos,params);
        negFeat = getFeatures(partsNeg,params);

        if (params.sameClass)
            [trainFeat,testFeat,trainLabels,testLabels] = splitFeat(posFeat,negFeat);
            imsUse2= 0; %avoid matlab erroring out
        else
            %%% never seen classes %%%
            [trainFeat,testFeat,trainLabels,testLabels] = splitFeat(posFeat,negFeat);
            trainFeat = [trainFeat;testFeat];
            trainLabels = [trainLabels;testLabels];

            [partsPos2,partsNeg2,imsUse2] = extractExampleParts(params.classTest,params.nIm,trialNum);

            posFeat2 = getFeatures(partsPos2,params);
            negFeat2 = getFeatures(partsNeg2,params);

            [trainFeat2,testFeat2,trainLabels2,testLabels2] = splitFeat(posFeat2,negFeat2);
            testFeat = [trainFeat2;testFeat2];
            testLabels = [trainLabels2;testLabels2];
            %%% never seen classes %%%
        end
        
        save(featFile,'params','trainFeat','testFeat','trainLabels','testLabels','imsUse','imsUse2');
    else
        display(['Feature file exists. Loading...']);
        load(featFile);
    end

    [model, probEstimates, classMap] = ...
              classifySVM(params, trainFeat, testFeat, trainLabels, testLabels);
    [multiClass,confuse,allWinners,tp,fp] = getPerform(probEstimates, testLabels, classMap);
    
    save(['res_',classifyPart,featFile], ...
            'params','probEstimates','classMap', ...
            'multiClass','confuse','allWinners', ...
            'tp','fp', 'testLabels', '-v7.3');
end