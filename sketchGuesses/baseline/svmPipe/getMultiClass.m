function [multiClass, allWinners] = getMultiClass(svmProbEstimates, labels, classMap)
    % svmProbEstimates: numEx x Models of prob estimates
    % labels: numEx x 1 labels for each of the training points. Identifiers, not
    %         sequential
    % classMap: maps svmProbEstimates(:,m) into correct label identifier
    
    multiClass = 0;
    tot = 0;
    for (i=1:size(svmProbEstimates,1))
        tot = tot + 1;
        [val, winner] = max(svmProbEstimates(i,:));
        winner = classMap(winner); %ReMap
        allWinners(i,1) = winner;
        if (winner == labels(i))
            multiClass = multiClass + 1;
        end

    end
    multiClass = multiClass/tot;
end