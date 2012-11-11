function x = imWithRect(x,rect)

    if(size(x,3) == 1)
        x = repmat(x,[1,1,3]);
    end
    m = [1,0,0]';
    m = reshape(m,[1,1,3]);
    
    for (i=1:size(rect,1))
        x(rect(i,1),rect(i,2):rect(i,4),:) = repmat(m,[1,rect(i,4)-rect(i,2)+1,1]);
        x(rect(i,3),rect(i,2):rect(i,4),:) = repmat(m,[1,rect(i,4)-rect(i,2)+1,1]);

        x(rect(i,1):rect(i,3),rect(i,2),:) = repmat(m,[rect(i,3)-rect(i,1)+1,1,1]);
        x(rect(i,1):rect(i,3),rect(i,4),:) = repmat(m,[rect(i,3)-rect(i,1)+1,1,1]);
    end
    x = im2double(x);

end

