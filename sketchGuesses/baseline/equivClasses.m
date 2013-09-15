function [res,resLin,labels] = equivClasses(cls,strs)

    nClasses = 18;
    res = cell(nClasses,1);

    for (i=1:numel(strs))
        if(cls(i) == 0) continue; end;
        temp = res{cls(i)};
        temp{end+1} = strs{i};
        res{cls(i)} = temp;
    end

    resLin = {};
    labels = [];
    for (i=1:numel(res))
       for (j=1:numel(res{i}))
           resLin{end+1} = res{i}{j};
           labels(end+1) = i;
       end
    end
end

