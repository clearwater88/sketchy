startup;
nTrials = 5;
params.nIm = 40;
params.svmCross = 0;
params.crossType = 1; % cross-val on acuracy
params.svmKern = 0; %0=dot, 1=intersect
params.sameClass = 0;
params.classTrain = [0,2,3,4];
params.classTest = [0,2,3,4]; % only used if sameClass == 0
params.poolMode = 1; %0=mean,1=max,2=sum
params.pooling = [1,1;2,2;4,4];

classifierFile = 'kern0feat5_trial_';
for (t=1:5) 
    load(['feats_poolingLevs3_poolMode1_feat5_cltrain29_cltest29_numIm40_trial',int2str(t)], ...
          'trainFeat','testFeat','trainLabels','testLabels');
      
    [model, probEstimates, classMap] = ...
              classifySVM(params, trainFeat, testFeat, trainLabels, testLabels);
    [multiClass,confuse,allWinners,tp,fp] = getPerform(probEstimates, testLabels, classMap);
    
    save([classifierFile, int2str(t)],...
            'params','probEstimates','classMap', ...
            'multiClass','confuse','allWinners', ...
            'tp','fp', 'trainLabels','testLabels', '-v7.3');
      
end