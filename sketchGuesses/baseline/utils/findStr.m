function res = findStr(str,dict)
    res = 0;
    for (i=1:numel(dict))
       if(strcmp(dict{i},str))
           res = i;
           return;
       end
    end
end
