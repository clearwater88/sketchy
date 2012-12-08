function [multiClass,confuse,allWinners,tp,fp] = getPerform(svmProbEstimates, trueLabels, classMap)
    % confuse: winner, trueWinner
    
    numClasses = numel(unique(trueLabels));
    [~,allWinners] = max(svmProbEstimates,[],2);
    allWinners = classMap(allWinners); % Remap to right label numbers
    
    confuse = zeros(numClasses, numClasses);
    for (i=1:size(allWinners,1))
       winner = find(classMap == allWinners(i));
       trueWinner = find(classMap == trueLabels(i));
       confuse(winner, trueWinner) = confuse(winner,trueWinner) + 1;
    end
    multiClass = mean(diag(bsxfun(@rdivide, confuse, sum(confuse,1))));
    
    [tp,fp] = getROC(svmProbEstimates,trueLabels,classMap);
end

function [tp,fp] = getROC(svmProbEstimates,trueLabels,classMap)
    t = 1:-0.01:0.01;
    posClass = find(classMap==1);
    for (i=1:numel(t))
        pos = svmProbEstimates(:,posClass) > t(i);
        tp(i) = sum((pos==1).*(trueLabels==1))/(sum(trueLabels==1));
        fp(i) = sum((pos==1).*(trueLabels==2))/(sum(trueLabels==2));      
    end
end