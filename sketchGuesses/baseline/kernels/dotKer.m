function [res] = dotKer(x1, x2)
    % Symmetric KL
    
    % where x1 and x2 are matrices containing input vectors, where 
    % each row represents a single vector.
    % If x1 is a matrix of size m x o and x2 is of size n x o,
    % the output K is a matrix of size m x n.
    res = x1*x2';
%     for (m=1:size(x1,1))
%         for (n=1:size(x2,1))
%            res(m,n) =  x1(m,:)*x2(n,:)';
%         end
%     end
end