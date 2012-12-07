function [x] = getIm(fileHeader)
    j=1;
    while(1)
        if(exist([fileHeader,'-',int2str(j+1),'.png'],'file'))
            j=j+1;
        else
            break;
        end
    end
    fName = [fileHeader,'-',int2str(j),'.png'];
    x = imread(fName); 
end

