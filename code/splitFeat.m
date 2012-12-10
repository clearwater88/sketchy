function [trainFeat,testFeat,trainLabels,testLabels] = splitFeat(posFeat,negFeat)
    nPosTrain = floor(size(posFeat,1)/2);
    posTrain = posFeat(1:nPosTrain,:);
    posTest = posFeat(nPosTrain+1:end,:);

    nNegTrain = floor(size(negFeat,1)/2);
    negTrain = negFeat(1:nNegTrain,:);
    negTest = negFeat(nNegTrain+1:end,:);

    trainFeat = [posTrain;negTrain];
    testFeat = [posTest;negTest];

    trainLabels = [ones(size(posTrain,1),1);2*ones(size(negTrain,1),1)];
    testLabels = [ones(size(posTest,1),1);2*ones(size(negTest,1),1)];
end