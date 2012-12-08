function [res] = sampMulti(probs,nSamp)
    cumProbs = cumsum(probs);
    samps = rand(nSamp,1);
    
    res = zeros(nSamp,1);
    for (i=1:nSamp)
       res(i) = find(cumProbs > samps(i),1,'first'); 
    end
end

