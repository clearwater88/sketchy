nTrials = 10;
voteThreshTry = [6:-1:0];
nTrainPerc = 0.4;
useTurkers = 1;
useTurkerLabels = 1;
nTurkSketchesTry = [0:10];

for (i=1:numel(voteThreshTry))
    for(j=1:numel(nTurkSketchesTry))
        main(nTrials,voteThreshTry(i),nTrainPerc,useTurkers,useTurkerLabels,nTurkSketchesTry(j));
    end
end