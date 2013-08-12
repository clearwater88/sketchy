function [res] = KL(x1, x2)
    % Symmetric KL
    
    % where x1 and x2 are matrices containing input vectors, where 
    % each row represents a single vector.
    % If x1 is a matrix of size m x o and x2 is of size n x o,
    % the output K is a matrix of size m x n.
    for (m=1:size(x1,1))
        for (n=1:size(x2,1))
           res(m,n) =  (sum(x1(m,:) .* log(x1(m,:)./x2(n,:))) + ...
                        sum(x2(n,:) .* log(x2(n,:)./x1(m,:))));
           res(m,n) = exp(-res(m,n));
        end
    end
end

