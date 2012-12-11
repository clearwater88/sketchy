function res = nocircshift(arr,offset)
% res = nocircshift(arr,offset)
%
% Applies non-circular (0-padded) shift to input array. Only works for 
% dim(offset) <= 2
% inputs:
%   arr: input array
%   offset: vector of shifts to apply to arr
% outputs:
%   res: the shifted array

	assert(numel(offset) <= 2);
    res = circshift(arr,offset);
    if (offset(1) > 0)
        res(1:offset(1),:) = 0;
    else
        res(end+offset(1):end,:) = 0;
    end
    if (offset(2) > 0)
        res(:,1:offset(2)) = 0;
    else
        res(:,end+offset(2):end) = 0;
    end
end

