function confuse = getConfuse(allWinners, trueLabels)
    numClasses = numel(unique(trueLabels));
    
    confuse = zeros(numClasses, numClasses);
    for (i=1:size(allWinners,1))
       winner = allWinners(i);
       trueWinner = trueLabels(i);
       confuse(winner, trueWinner) = confuse(winner,trueWinner) + 1;
    end
    
end

