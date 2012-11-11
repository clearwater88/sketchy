function parserBB()

    rootDir = '../data/airplane-stroke/';
    objType = 'airplane/';
    numIm = 80;
    
    for (i=1:numIm)
        display(['On image: ', int2str(i)]);
        saveFile = ['data/', objType, int2str(i),'.mat'];
        if(exist(saveFile,'file'))
            display(['File exists: ', saveFile, '. Continuing...']);
            continue;
        end
        j =1;
        while(1)
            if(exist([rootDir,int2str(i),'-',int2str(j+1),'.png'],'file'))
               j=j+1; 
            else
                break;
            end
        end
        fName = [rootDir,int2str(i),'-',int2str(j),'.png'];
        im = imread(fName);

        bbAll = doParserBB(im);
        save(saveFile,'bbAll');
    end    


end

