function [bbAll] = doParserBB(im)
    
    %figure(1);
    %imshow(im);

    bbAll = [];
    
    while(1)
        figure(2);
        %[~,rect] = imcrop(imAll(:,:,end));
        imRect = imWithRect(im,bbAll);
        [~,rect] = imcrop(imRect);
        rect = round(rect);
        
        %[yStart,xStart.yStop,xStop]
        bb(1) = rect(2);
        bb(2) = rect(1);
        bb(3) = rect(2)+rect(4);
        bb(4) = rect(1)+rect(3);
        
        if((bb(3)-bb(1))*(bb(4)-bb(2)) < 16)
            break;
        end
        bbAll(end+1,:) = bb;
    end


end

