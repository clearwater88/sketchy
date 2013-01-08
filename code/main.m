startup;
nTrials = 5;

params.nIm = 40;
params.svmCross = 0;
params.crossType = 1; % cross-val on acuracy

params.svmKern = 1; %0=dot, 1=intersect

params.sameClass = 0;
params.classTrain = [0,2,3];
params.classTest = [4]; % only used if sameClass == 0

params.poolMode = 0; %0=mean,1=max,2=sum
params.pooling = [1,1;2,2;4,4];

% 0 = gabors, do not split pos/neg features
% 1 = gabors, split pos/neg features
% 2 = 3x3 local descriptor, summarize locally
% 3 = 3x3 local descriptor, say if pixels have specific neighbours
% 4 = basically gradient
% 5 = complex cell (pool over phase, scale), do no split pos/neg features
% 6 = complex cell (pool over phase, scale), split pos/neg features

ftTry = [1,6];
for (ft=1:numel(ftTry))
    params.featType = ftTry(ft);
    for (t=1:nTrials)
        display(['On trial ', int2str(t)]);
        [multiClass(t,1),confuse(:,:,t),~,tp(t,:),fp(t,:)] = mainPartClassify(params,t);
    end
end

params.svmKern = 0; %0=dot, 1=intersect
for (ft=1:numel(ftTry))
    params.featType = ftTry(ft);
    for (t=1:nTrials)
        display(['On trial ', int2str(t)]);
        [multiClass(t,1),confuse(:,:,t),~,tp(t,:),fp(t,:)] = mainPartClassify(params,t);
    end
end

%close all; plot(fp,tp,'b-o'); hold on; plot([0:0.01:1],[0:0.01:1],'r');