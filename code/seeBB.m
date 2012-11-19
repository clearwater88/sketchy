function seeBB(n,ii)

    [~,objType, rootDir,iStart] = getClassData(n);
    numIm = 80;
    
    for (i=iStart+ii-1:iStart+numIm-1)
        display(['On image: ', int2str(i-iStart+1)]);
        %load(['data/', objType, int2str(i),'.mat'],'bbAll');

        j =1;        
        while(1)                        
            if(exist([rootDir,int2str(i),'-',int2str(j+1),'.png'],'file'))
                fName = [rootDir,int2str(i),'-',int2str(j),'.png'];
                im = imread(fName);
                
                imshow(im);
                pause
                j=j+1;
            else
                break;
            end
        end

    end    


end

