function [x,strokeStack] = getIm(fileHeader)
    nStrokes=1;
    SIZE_THRESH = 60;
    while(1)
        if(exist([fileHeader,'-',int2str(nStrokes+1),'.png'],'file'))
            nStrokes=nStrokes+1;
        else
            break;
        end
    end
 
    fName = [fileHeader,'-',int2str(nStrokes),'.png'];
    x = imread(fName); 
    
    strokes = zeros([size(x,1),size(x,2),nStrokes]);
    for (i=1:nStrokes)
        strokes(:,:,i) = imread([fileHeader,'-',int2str(i),'.png']);
    end
    
    strokeStack = zeros([size(x,1),size(x,2),nStrokes]);
    strokeOn = strokes(:,:,1);
    
    counter = 1;
    for (j=2:nStrokes)
        temp = strokes(:,:,j)-strokeOn;
        if (sum(temp(:)) < SIZE_THRESH)
            continue;
        end
        strokeStack(:,:,counter) = temp;
        strokeOn = strokes(:,:,j);
        counter = counter+1;
    end
    strokeStack(:,:,counter:end) = [];
end

