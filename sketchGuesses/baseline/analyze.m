resFolder = 'res_sketchesSet4_withPartials/';
resStr= 'allGuesses-hard-thresh%d-UseTurkers1-UseTurkerLabels0-nTurkSketches%d-trainPerc400-testPerc200-trial%d';

threshTry = [6:-1:1];
nTry = [0:10];
trials = [1:10];

acc = zeros(numel(threshTry),numel(nTry),numel(trials));
nTrain = zeros(numel(threshTry),numel(nTry),numel(trials)); 

for (th=1:numel(threshTry))
    for (n=1:numel(nTry))
        for (t=1:numel(trials))
            file = sprintf([resFolder,resStr],threshTry(th),nTry(n),trials(t));
            file
            load(file, 'multiClass', 'trainLabels');
            acc(th,n,t) = multiClass;
            nTrain(th,n,t) = numel(trainLabels);        
        end
    end
end

accMean = mean(acc,3);
accStd = std(acc,[],3);
nTrainMean = mean(nTrain,3);
nTrainStd = std(nTrain,[],3);

figure(2);
for (i=1:6)
    subplot(2,3,i);
    %errorbar(nTrainMean(i,:),accMean(i,:),accStd(i,:),'b.');
    errorbar(nTry,accMean(i,:),accStd(i,:),'b.');
    title(['Voting Threshold: ', int2str(threshTry(i))]);    
    xlabel('Number of Turker-labeled sketches used per class');
    ylabel('Recognition rate');
    axis([-0.5 10.5 0.58 0.65]);
end