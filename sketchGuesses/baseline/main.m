function main(nTrials)
    startup;
    
    histFolder = 'histsGuesses_hard/';
    classifierParams = initClassifierParams();

    for (t=1:nTrials)
        data = loadData(histFolder);
        [trainData,testData,trainLabels,testLabels] = splitData(data);
        
        sFile = ['allGuesses_hard_trial', int2str(t)];
        
        KTrain{1} = getKmat(classifierParams,trainData,trainData);
        KTest{1} = getKmat(classifierParams,testData,trainData);
        [model, probEstimates, predictLabels, classMap] = ...
            classifySVM(classifierParams, trainLabels, testLabels, KTrain, KTest, 1);
        [multiClass, allWinners] = getMultiClass(probEstimates, testLabels, classMap);
        save(sFile, 'probEstimates', 'predictLabels', 'classMap','multiClass','allWinners', 'trainLabels','testLabels');
    end
end

function data = loadData(histFolder)
    files = dir(histFolder);

    data=[];
    for (i=1:numel(files))
        name = files(i).name;
        if (numel(name) < 5) continue; end;
        
        if(strcmp(name(1:12), 'merged_mHist') == 1)
           data{end+1} = readBOWFeat([histFolder,name]);
        end
        
    end
    
end

function [trainData,testData,trainLabels,testLabels] = splitData(data)

    pre = 10000;

    trainData = [];
    testData= [];
    trainLabels = zeros(pre,1);
    testLabels = zeros(pre,1);
    
    ctTrain = 1;
    ctTest = 1;
    for (n=1:numel(data))
        display(['Loading class: ', int2str(n)]);
        nTrain = floor(size(data{n},1)/2);
        nTest = size(data{n},1)-nTrain;
        
        inds = randperm(size(data{n},1));
        
        if (ctTrain==1)
           nFeat = size( data{n},2);
           trainData = zeros(pre,nFeat);
           testData = zeros(pre,nFeat);
        end
        trainData(ctTrain:ctTrain+nTrain-1,:) = data{n}(inds(1:nTrain),:);
        trainLabels(ctTrain:ctTrain+nTrain-1) = n*ones(nTrain,1);
        ctTrain = ctTrain + nTrain;
        
        testData(ctTest:ctTest+nTest-1,:) = data{n}(inds(nTrain+1:end),:);
        testLabels(ctTest:ctTest+nTest-1) = n*ones(nTest,1);
        ctTest = ctTest + nTest;
        
    end
    
    trainData(ctTrain:end,:) = [];
    testData(ctTest:end,:) = [];
    
    trainLabels(ctTrain:end) = [];
    testLabels(ctTest:end) = [];
end