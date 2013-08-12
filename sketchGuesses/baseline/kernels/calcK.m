% for perms
function [res] = calcK(x,y)
    C = size(x,1);
    py = perms(y);
    res = 0;
    for (i=1:size(py,1))
        temp = sum(min(x',py(i,:)));
        res = max(res,temp);
    end
    
end



