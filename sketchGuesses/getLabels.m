function [res] = getLabels(guesses,dict,labels)

    res = cell(numel(guesses,1));

    for (i=1:numel(guesses))
        tempGuesses = guesses{i};
        
        temp = [];
        for (j=1:numel(tempGuesses))
            id = findStr(lower(tempGuesses{j}),dict);
            if (id == 0) continue; end;
            temp(end+1) = labels(id);
        end
       res{i} = temp;
    end
end

function res = findStr(str,dict)
    res = 0;
    for (i=1:numel(dict))
       if(strcmp(dict{i},str))
           res = i;
           return;
       end
    end
end



