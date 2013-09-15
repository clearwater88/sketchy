function main(nTrials,voteThresh,nTrainPerc,useTurkers)
    startup;
        
    if(~exist('nTrainPerc','var'))
       nTrainPerc = 0.4; 
    end
    nTestPerc = 0.1;
    assert(nTrainPerc+nTestPerc <= 1);
    
    saveFolder = 'res_sketchesSet3_withPartials/';
    histFolder= 'codewords/';
    guessesFolder = 'sketchGuesses/';
    histHeader ='partials_mHist_all_';
    fileListHeader = 'fileListConvert_allPartial_';

    [~,~] = mkdir(saveFolder);
    
    classifierParams = initClassifierParams();

    for (t=1:nTrials)
        sFile = [saveFolder, ... 
                 'allGuesses-hard-thresh', int2str(voteThresh), ...
                 '-Turkers',int2str(useTurkers), ...
                 '-trainPerc', int2str(floor(nTrainPerc*1000)), ...
                 '-trial', int2str(t)];
        
        [trainData,trainLabels,testData,testLabels] = mainDivideSketches(histFolder,guessesFolder,useTurkers,voteThresh,nTrainPerc,nTestPerc,histHeader,fileListHeader);
        
        KTrain{1} = getKmat(classifierParams,trainData,trainData);
        KTest{1} = getKmat(classifierParams,testData,trainData);
        [model, probEstimates, predictLabels, classMap] = ...
            classifySVM(classifierParams, trainLabels, testLabels, KTrain, KTest, 1);
        [multiClass, allWinners] = getMultiClass(probEstimates, testLabels, classMap);
        
        save(sFile, 'probEstimates', 'predictLabels', 'classMap','multiClass','allWinners', 'trainLabels','testLabels');
    end
end