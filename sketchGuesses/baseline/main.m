function main()
    histFolder = 'hists/';

    data = loadData(histFolder);
    [trainData,testData,trainLabels,testLabels] = splitData(data);
    
end

function data = loadData(histFolder)
    files = dir(histFolder);

    data=[];
    for (i=1:numel(files))
        name = files(i).name;
        if (numel(name) < 5) continue; end;
        
        if(strcmp(name(1:5), 'mHist') == 1)
           data{end+1} = readBOWFeat([histFolder,name]);
        end
        
    end
    
end

function [trainData,testData,trainLabels,testLabels] = splitData(data)

    trainData = [];
    testData= [];
    trainLabels = [];
    testLabels = [];
    
    for (n=1:numel(data))
        display(['Loading class: ', int2str(n)]);
        nTrain = floor(size(data{n},1)/2);
        nTest = size(data{n},1)-nTrain;
        
        inds = randperm(size(data{n},1));
        
        trainData = cat(1,trainData,data{n}(inds(1:nTrain),:));
        trainLabels = cat(1,trainLabels,n*ones(nTrain,1));
        
        testData = cat(1,testData,data{n}(inds(nTrain+1:end),:));
        testLabels = cat(1,testLabels,n*ones(nTest,1));
    end
end