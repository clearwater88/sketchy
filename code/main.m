startup;
nTrials = 2;

params.nIm = 5;
params.svmCross = 0;
params.crossType = 1; % cross-val on acuracy

params.svmKern = 1;
params.pooling = [1,1;2,2;4,4];
params.poolMode = 2;
params.sameClass = 1;
params.classTrain = [0,2];
params.classTest = [0,2]; % only used if sameClass == 0


for (t=1:nTrials)
    display(['On trial ', int2str(t)]);
    mainPartClassify(params,t);
end

params.svmKern = 0;
params.pooling = [1,1;2,2;4,4];
params.poolMode = 2;
params.sameClass = 1;
params.classTrain = [0,2];
params.classTest = [0,2]; % only used if sameClass == 0


for (t=1:nTrials)
    display(['On trial ', int2str(t)]);
    mainPartClassify(params,t);
end

%close all; plot(fp,tp,'b-o'); hold on; plot([0:0.01:1],[0:0.01:1],'r');