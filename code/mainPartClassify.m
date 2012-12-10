startup;

params.svmCross = 0;
params.crossType = 1; % cross-val on acuracy
params.svmKern = 1;
params.pooling = [1,1;2,2;4,4];
params.poolMode = 2;

gabors = gaborBank();
nGabors = size(gabors,3);

n = [0,2];
[partsPos,partsNeg] = extractExampleParts(n);

posFeat = getResponses(gabors,partsPos,params.pooling,params.poolMode);
negFeat = getResponses(gabors,partsNeg,params.pooling,params.poolMode);

%[trainFeat,testFeat,trainLabels,testLabels] = splitFeat(posFeat,negFeat);

% never seen classes
[trainFeat,testFeat,trainLabels,testLabels] = splitFeat(posFeat,negFeat);
trainFeat = [trainFeat;testFeat];
trainLabels = [trainLabels;testLabels];

n = [3,4];
[partsPos,partsNeg] = extractExampleParts(n);

posFeat2 = getResponses(gabors,partsPos,params.pooling,params.poolMode);
negFeat2 = getResponses(gabors,partsNeg,params.pooling,params.poolMode);

[trainFeat2,testFeat2,trainLabels2,testLabels2] = splitFeat(posFeat2,negFeat2);
testFeat = [trainFeat2;testFeat2];
testLabels = [trainLabels2;testLabels2];
% never seen classes

[model, probEstimates, classMap] = ...
          classifySVM(params, trainFeat, testFeat, trainLabels, testLabels);
[multiClass,confuse,allWinners,tp,fp] = getPerform(probEstimates, testLabels, classMap);