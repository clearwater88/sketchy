function [res] = getCleanGuesses(guesses,dict,labels)
    res = [];
    for (j=1:numel(guesses))
        id = findStr(lower(guesses{j}),dict);
        if (id == 0) continue; end;
        res(end+1) = labels(id);
    end
end



