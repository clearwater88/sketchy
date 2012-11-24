function parserTypes(n)

    [lab,objType,rootDir,iStart] = getClassData(n);
    numIm = 80;
    
    for (i=iStart:iStart+numIm-1)
        display(['On image: ', int2str(i-iStart+1)]);
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
        for (i=1:numel(lab))
            display([int2str(i), '/', lab{i}]) ;
        end
    
        [partTypes,bbAll] = doParserTypes(im,bbAll,lab);
        display('Done');
        pause
        save(saveFile,'bbAll','lab','partTypes');
    end    

    
end

