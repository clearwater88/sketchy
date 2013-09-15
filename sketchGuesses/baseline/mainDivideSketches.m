function [trainData,trainLabels,testData,testLabels] = mainDivideSketches(histFolder,guessesFolder,useTurkers,voteThresh,nTrainPerc,nTestPerc,histHeader,fileListHeader)

    classes = getClassNames();
    sketchInfo = getSketchInfo(histFolder, guessesFolder, classes,histHeader,fileListHeader);
    nWords = size(sketchInfo{1}.feats,2);
    
    % contains equivalence of names of class names
    mappingFile = 'equivClasses.mat';
    [trainData,trainLabels,testData,testLabels] = divideSketches(mappingFile,sketchInfo, nTrainPerc,nTestPerc,voteThresh,nWords,useTurkers);
end

function sketchInfo = getSketchInfo(histFolder, guessesFolder, classes,histHeader,fileListHeader)
    sketchInfo = cell(numel(classes),1);
    for (n=1:numel(classes))        
        sketchInfo{n}.feats = readBOWFeat([histFolder,histHeader, classes{n}, '.hard']);
        
        fid = fopen([histFolder, fileListHeader, classes{n}, '.txt']);
        temp = textscan(fid,'%s');
        fclose(fid);
        
        sketchInfo{n}.fileList = temp{1};
        sketchInfo{n}.guessesHash = getGuessesHash(guessesFolder,classes{n});
        sketchInfo{n}.class = classes{n};
        sketchInfo{n}.classNum = n;
    end
end

function res = getGuessesHash(guessesFolder,class)

    fid = fopen([guessesFolder, class, '_files.txt']);
    temp = textscan(fid,'%s');
    fileList = temp{1};
    fclose(fid);

    d = dir(guessesFolder);
    keys = {};
    values = {};
    for (i=1:numel(d))
        if(numel(d(i).name) < 4) continue; end;
        if (strcmp(d(i).name(end-3:end), '.mat') == 0) continue; end;
        if(numel(d(i).name) -4 < numel(class)) continue; end;
        
        if(strcmp(class,d(i).name(1:numel(class))) == 0) continue; end;
        
        st = strfind(d(i).name,'_'); st = st(end);
        stop = strfind(d(i).name,'.'); stop = stop(end);
        imFile = fileList{str2num(d(i).name(st+1:stop-1))};
        temp = strfind(imFile,'.svg');
        sketchNum = imFile(1:temp-1);
        
        keys{end+1} = str2double(sketchNum);
        load([guessesFolder,d(i).name], 'Guesses');
        values{end+1} = Guesses;
%         
%         '----'
%         fileList
%         sketchNum
%         d(i).name
        
    end
    res = containers.Map(keys, values);
end

