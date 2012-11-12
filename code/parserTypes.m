function parserTypes()
    classNum = 0; % airplane

    [lab,objType,rootDir,iStart] = getClassData(classNum);
    numIm = 80;
    
    for (i=iStart:iStart+numIm-1)
        display(['On image: ', int2str(i)]);
        loadFile = ['data/', objType, int2str(i),'.mat'];
        saveFile = ['data/', objType, int2str(i),'-Parts.mat'];
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

        load(loadFile,'bbAll');
        partTypes = doParserTypes(im,bbAll,lab);
        save(saveFile,'bbAll','lab','partTypes');
    end    

    
end

