function [partTypes] = doParserTypes(im,bbAll,lab)
    
    partTypes = [];
    for (i=1:size(bbAll,1))
        imRect = imWithRect(im,bbAll(i,:));
        imshow(imRect);
                resp = str2num(input('Part type?: ', 's'));
        if(resp == 0)
            break;
        end
        if(resp == -1)
            partTypes(end+1) = -1;
        end

        partTypes(end+1,1) = resp;
        display(lab{resp});
        
    end
    
    bbAll(partTypes==-1,:) = [];
    partTypes(partTypes==-1) = [];
    
    st = '';
    for (i=1:numel(partTypes))
        st = [st, ',',lab{partTypes(i)}];
    end
    st
end

