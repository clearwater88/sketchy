function main(nTrials,voteThresh,nTrainPerc,useTurkers,useTurkerLabels,nTurkSketches)
%main(1,2,0.4,1,1,10)
    startup;
        
    if(~exist('nTrainPerc','var'))
       nTrainPerc = 0.4; 
    end
    nTestPerc = 0.2;
    assert(nTrainPerc+nTestPerc <= 1);
    
    saveFolder = 'res_sketchesSet4_withPartials/';
    histFolder= 'codewords/';
    guessesFolder = 'sketchGuesses/';
    histHeader ='partials_mHist_all_';
    fileListHeader = 'fileListConvert_allPartial_';

    [~,~] = mkdir(saveFolder);
    
    classifierParams = initClassifierParams();

    params.useTurkers = useTurkers;
    params.useTurkerLabels = useTurkerLabels;
    params.nTrainPerc = nTrainPerc;
    params.nTestPerc = nTestPerc;
    params.voteThresh = voteThresh;
    params.nTurkSketches = nTurkSketches;
    
    for (t=1:nTrials)
        sFile = [saveFolder, ... 
                 'allGuesses-hard-thresh', int2str(voteThresh), ...
                 '-UseTurkers',int2str(useTurkers), ...
                 '-UseTurkerLabels', int2str(useTurkerLabels), ...
                 '-nTurkSketches', int2str(nTurkSketches), ...
                 '-trainPerc', int2str(floor(nTrainPerc*1000)), ...
                 '-testPerc', int2str(floor(nTestPerc*1000)), ...
                 '-trial', int2str(t)];
        
        if(exist([sFile,'.mat'],'file'))
            display(['File exists: ', sFile]);
            continue;
        end
        [trainData,trainLabels,testData,testLabels] = mainDivideSketches(histFolder,guessesFolder,histHeader,fileListHeader,params);
        
        KTrain{1} = getKmat(classifierParams,trainData,trainData);
        KTest{1} = getKmat(classifierParams,testData,trainData);
        [model, probEstimates, predictLabels, classMap] = ...
            classifySVM(classifierParams, trainLabels, testLabels, KTrain, KTest, 1);
        [multiClass, allWinners] = getMultiClass(probEstimates, testLabels, classMap);
        
        save(sFile, 'probEstimates', 'predictLabels', 'classMap','multiClass','allWinners', 'trainLabels','testLabels');
    end
end