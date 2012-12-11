startup;
nTrials = 5;

params.nIm = 40;
params.svmCross = 0;
params.crossType = 1; % cross-val on acuracy

params.svmKern = 1; %0=dot, 1=intersect

params.sameClass = 1;
params.classTrain = [0,2,3,4];
params.classTest = [0,2,3,4]; % only used if sameClass == 0

params.poolMode = 1; %0=mean,1=max,2=sum
params.pooling = [1,1;2,2;4,4];

% 0 = gabors, do not split pos/neg features
% 1 = gabors, split pos/neg features
% 2 = 3x3 local descriptor, summarize locally
% 3 = 3x3 local descriptor, say if pixels have specific neighbours
% 4 = basically gradient
params.featType = 3;
for (t=1:nTrials)
    display(['On trial ', int2str(t)]);
    [multiClass(t,1),confuse(:,:,t),~,tp(t,:),fp(t,:)] = mainPartClassify(params,t);
end

params.featType = 2;
for (t=1:nTrials)
    display(['On trial ', int2str(t)]);
    [multiClass(t,1),confuse(:,:,t),~,tp(t,:),fp(t,:)] = mainPartClassify(params,t);
end

params.poolMode = 0;
params.featType = 3;
for (t=1:nTrials)
    display(['On trial ', int2str(t)]);
    [multiClass(t,1),confuse(:,:,t),~,tp(t,:),fp(t,:)] = mainPartClassify(params,t);
end

params.featType = 2;
for (t=1:nTrials)
    display(['On trial ', int2str(t)]);
    [multiClass(t,1),confuse(:,:,t),~,tp(t,:),fp(t,:)] = mainPartClassify(params,t);
end