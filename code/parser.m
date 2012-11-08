function [bbAll,partTypes] = parser(im)

    lab{1} = 'window';
    lab{2} = 'left wing';
    lab{3} = 'right wing';
    lab{4} = 'tail';

    figure(1);
    imshow(im);

    bbAll = [];
    partTypes = [];
    
    imOrig = im;
    while(1)
        figure(2);
        [~,rect] = imcrop(im);
        close(2);
        rect = round(rect);
        resp = str2num(input('Part type?: ', 's'));
        
        if(resp == 0)
            break;
        end
        
        %[yStart,xStart.yStop,xStop]
        bb(1) = rect(2);
        bb(2) = rect(1);
        bb(3) = rect(2)+rect(4);
        bb(4) = rect(1)+rect(3);

        im(bb(1):bb(3),bb(2):bb(4)) = 0;
        
        bbAll(end+1,:) = bb;
        partTypes(end+1,1) = resp;
        
    end
end

