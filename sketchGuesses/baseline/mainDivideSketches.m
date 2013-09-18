function [trainData,trainLabels,testData,testLabels] = mainDivideSketches(histFolder,guessesFolder,histHeader,fileListHeader,params)

    classes = getClassNames();
    sketchInfo = getSketchInfo(histFolder, guessesFolder, classes,histHeader,fileListHeader,params.nTurkSketches);
    nWords = size(sketchInfo{1}.feats,2);
    
    % contains equivalence of names of class names
    mappingFile = 'equivClasses.mat';
    [trainData,trainLabels,testData,testLabels] = divideSketches(mappingFile,sketchInfo,nWords,params);
end

function sketchInfo = getSketchInfo(histFolder, guessesFolder, classes,histHeader,fileListHeader,nTurkSketches)
    sketchInfo = cell(numel(classes),1);
    for (n=1:numel(classes))        
        sketchInfo{n}.feats = readBOWFeat([histFolder,histHeader, classes{n}, '.hard']);
        
        fid = fopen([histFolder, fileListHeader, classes{n}, '.txt']);
        temp = textscan(fid,'%s');
        fclose(fid);
        
        sketchInfo{n}.fileList = temp{1};
        sketchInfo{n}.guessesHash = getGuessesHash(guessesFolder,classes{n},nTurkSketches);
        sketchInfo{n}.class = classes{n};
        sketchInfo{n}.classNum = n;
    end
end

function res = getGuessesHash(guessesFolder,class,nTurkSketches)

    fid = fopen([guessesFolder, class, '_files.txt']);
    temp = textscan(fid,'%s');
    fileList = temp{1};
    fclose(fid);

    d = dir(guessesFolder);
    names = cell(numel(d),1);
    inds = randperm(numel(d));
    for (i=1:numel(d))
       names{i} = d(inds(i)).name; % shuffle while we're at it 
    end
    
    keys = {};
    values = {};
    
    used = [];
    
    for (i=1:numel(names))
        name = names{i};
        if(numel(name) < 4) continue; end;
        if (strcmp(name(end-3:end), '.mat') == 0) continue; end;
        if(numel(name) -4 < numel(class)) continue; end;
        
        if(strcmp(class,name(1:numel(class))) == 0) continue; end;
        
        st = strfind(name,'_'); st = st(end);
        stop = strfind(name,'.'); stop = stop(end);
        imFile = fileList{str2num(name(st+1:stop-1))};
        temp = strfind(imFile,'.svg');
        sketchNum = str2double(imFile(1:temp-1));
        
        if(contains(used,sketchNum)) continue; end;
        
        keys{end+1} = sketchNum;
        load([guessesFolder,name], 'Guesses');
        values{end+1} = Guesses;
%         
%         '----'
%         fileList
%         sketchNum
%         d(i).name
        
        if(numel(used) == nTurkSketches) break; end;
    end
    res = containers.Map(keys, values);
end

