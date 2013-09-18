function [res] = contains(arr,elem)
    % arr should be small. no need to sort.
    res= 0;
    for (i=1:numel(arr))
       if(arr(i) == elem) res = 1; break; end; 
    end

end

