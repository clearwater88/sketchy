folder = 'res_sketchesSet2_withPartials/';

file = 'allGuesses-hard-thresh%d-Turkers%d-trainPerc%d-trial%d';


nTrials = 10;
turkers = 1;

if(turkers)
    threshes = [1:16];
    accTurker = zeros(numel(threshes),nTrials);
    nTrainTurker = zeros(numel(threshes),nTrials);
    toTry=40;
    %toTry=400;
else
    toTry = [5:5:50];
    threshes = 0;
    
    acc = zeros(numel(toTry),nTrials);
    nTrain = zeros(numel(toTry),nTrials);

end



for (th=1:numel(threshes))
   for (n=1:numel(toTry))
      trainPerc = toTry(n); 
      for (t=1:nTrials)
          fUse = [folder,sprintf(file,threshes(th),turkers,trainPerc,t)];
          load(fUse,'multiClass','trainLabels');
          
          if(turkers)
              accTurker(th,t) = multiClass;
              nTrainTurker(th,t) = numel(trainLabels);
          else
            acc(n,t) = multiClass;
            nTrain(n,t) = numel(trainLabels);  
          end
      end
   end
    
end

%errorbar(mean(nTrain,2),mean(acc,2),std(acc,[],2),'b-.'); title('No turkers'); hold on; errorbar(mean(nTrainTurker,2),mean(accTurker,2),std(accTurker,[],2),'r-.'); title('With turkers');