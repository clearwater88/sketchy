
pooling = [1,1;2,2;4,4];
poolMode = 2;
gabors = gaborBank();
nGabors = size(gabors,3);

partsPos = {};
partsNeg = {};
for (n=0:4)
    if (n==1) continue; end;
    
    [partsPosTemp,partsNegTemp] = extractExampleParts(n);
    partsPos = cat(1,partsPos,partsPosTemp);
    partsNeg = cat(1,partsNeg,partsNegTemp);
end

tic
posFeat = getResponses(gabors,partsPos,pooling,poolMode);
toc
tic
negFeat = getResponses(gabors,partsNeg,pooling,poolMode);
toc


% make same
%negFeatUse = negFeat(1:size(posFeat,1),:);
negFeatUse = negFeat;

nPosTrain = floor(size(posFeat,1)/2);
posTrain = posFeat(1:nPosTrain,:);
posTest = posFeat(nPosTrain+1:end,:);

nNegTrain = floor(size(negFeatUse,1)/2);
negTrain = negFeatUse(1:nNegTrain,:);
negTest = negFeatUse(nNegTrain+1:end,:);

trainFeat = [posTrain;negTrain];
testFeat = [posTest;negTest];

trainLabels = [ones(size(posTrain,1),1);2*ones(size(negTrain,1),1)];
testLabels = [ones(size(posTest,1),1);2*ones(size(negTest,1),1)];

params.svmCross = 0;
params.crossType = 1; % cross-val on acuracy
params.svmKern = 1;

[model, probEstimates, classMap] = ...
          classifySVM(params, trainFeat, testFeat, trainLabels, testLabels);
[multiClass,confuse,allWinners,tp,fp] = getPerform(probEstimates, testLabels, classMap);