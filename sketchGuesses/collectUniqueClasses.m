function res = collectUniqueClasses()

    files = dir();
    
    res = {};
    
    % collect all answers
    for (i=1:numel(files))
       f = files(i).name;
       if(numel(f) < 4) continue; end;
       if(strcmp(f(end-3:end),'.mat'))
          load(f,'Guesses');
          for(j=1:numel(Guesses))
             if(~isempty(Guesses{j}))
                 temp = Guesses{j};
                 for (k=1:numel(temp))
                    res{end+1} = lower(temp{k});
                 end
             end
          end
       end
    end
    res = sort(res);
    res = removeDuplicates(res);
end

function res = removeDuplicates(strs)
    res = {};
    res{1} = strs{1};
    
    for (i=1:numel(strs)-1)
        if(strcmp(strs{i},strs{i+1})) continue; end
        res{end+1} = strs{i+1};
    end

end

