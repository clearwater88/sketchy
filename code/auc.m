function [res] = auc(fp,tp)
    xVals = fp(2:end)-fp(1:end-1);
    yVals = (tp(2:end)+tp(1:end-1))/2;
    res = sum(xVals.*yVals);
end

