function parserTypes()
    
    lab{1} = 'window';
    lab{2} = 'left wing';
    lab{3} = 'right wing';
    lab{4} = 'tail';
    lab{5} = 'cockpit';
    lab{6} = 'body';
    lab{7} = 'fuselage';
    lab{8} = 'engine';
    lab{9} = 'gears';
    lab{10} = 'propeller';

    rootDir = '../data/airplane-stroke/';
    objType = 'airplane/';
    numIm = 80;
    
    for (i=1:numIm)
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

