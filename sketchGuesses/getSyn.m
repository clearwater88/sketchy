function [res] = getSyn(guesses)

    res = zeros(numel(guesses),1);
    load('temp');
    for (i=i:numel(guesses))
        display(sprintf('%d/%d',i,numel(guesses)));
        res(i) = str2num(input(['answer: ', guesses{i}, '\n'],'s'));
        save('temp');
    end

end

