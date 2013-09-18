function [trainData,trainLabels,testData,testLabels] = divideSketches(mappingFile,sketchInfo,nWords,params)
    
    [resFeat,gtLabels,isFullSketch,exceedVoteThresh] = voteFilterSketches(mappingFile,sketchInfo,params.voteThresh,nWords,params.useTurkers,params.useTurkerLabels);
    
    [trainInds, testInds] = splitData(numel(gtLabels),params.nTrainPerc,params.nTestPerc,exceedVoteThresh);
    
    trainData = resFeat(trainInds,:);
    testData = resFeat(testInds,:);
    trainLabels = gtLabels(trainInds);
    testLabels = gtLabels(testInds);
end

function [resFeat,gtLabels,isFullSketch,exceedVoteThresh] = voteFilterSketches(mappingFile,sketchInfo,voteThresh,nWords,useTurkers,useTurkerLabels)

    nEx = 0;
    for (i=1:numel(sketchInfo))
        nEx = nEx + numel(sketchInfo{i}.fileList);
    end
    nEx=floor(nEx*1.1); %buffer for inputting all unique guesses
    
    load(mappingFile,'equivLin','labels');
    resFeat = zeros(nEx,nWords);
    gtLabels = zeros(nEx,1);
    isFullSketch = zeros(nEx,1);
    exceedVoteThresh = zeros(nEx,1);
    ct = 1;
    
    for (i=1:numel(sketchInfo)) % iterate over all classes
        display(['On class: ', int2str(i), '/', int2str(numel(sketchInfo))]);
        info = sketchInfo{i};
        for (j=1:numel(info.fileList))
            [sketchNum,strokeNum] = getSketchNum(info.fileList{j});
            sketchNum = str2double(sketchNum);
            featUse = info.feats(j,:);
            if(strokeNum == -1) % no stroke number attached; a full sketch
                exceedVoteThresh(ct) = 1;
                resFeat(ct,:) = featUse;
                gtLabels(ct) = info.classNum;
                isFullSketch(ct) = 1;
                ct=ct+1;
            else
                if(~info.guessesHash.isKey(sketchNum)) % no guesses associated with this sketch
                    exceedVoteThresh(ct) = 0 >= voteThresh;
                    resFeat(ct,:) = featUse;
                    gtLabels(ct) = info.classNum;
                    isFullSketch(ct) = 0;
                    ct=ct+1;
                else
                    guesses = info.guessesHash(sketchNum);
                    if(numel(guesses) < strokeNum)
                        display('Warning! Note enough strokes.');
                        display(['sketchNum/guess: ', int2str(sketchNum), '/', int2str(numel(guesses))]);
                        guessStroke = [];
                    else
                        guessStroke = guesses{strokeNum};
                    end
                   
                    if(isempty(guessStroke) || ~useTurkers)
                        exceedVoteThresh(ct) = 0 >= voteThresh;
                        resFeat(ct,:) = featUse;
                        gtLabels(ct) = info.classNum;
                        isFullSketch(ct) = 0;
                        ct=ct+1;                        
                    else
                        cleanGuesses = getCleanGuesses(guessStroke,equivLin,labels);
                        uniqueGuesses = unique(cleanGuesses);
                        for (m=1:numel(uniqueGuesses))
                            nGuess = sum(cleanGuesses == uniqueGuesses(m));

                            exceedVoteThresh(ct) = nGuess >= voteThresh;
                            resFeat(ct,:) = featUse;
                            if(useTurkerLabels)
                                gtLabels(ct) = uniqueGuesses(m);
                            else
                                gtLabels(ct) = info.classNum; % try using gt label
                            end
                            isFullSketch(ct) = 0;
                            ct=ct+1;
                        end
                    end
                end
            end
        end
    end
    resFeat(ct:end,:) = [];
    gtLabels(ct:end) = [];
    isFullSketch(ct:end) = [];
    exceedVoteThresh(ct:end) = [];
end


% function divideSketches(fileLists,equivLin,labels,classes)
%     guessesFolder = '../guesses/';
%     strokesFolder = '../../data/';
%     resFolder = 'guesses/';
%     for (i=1:numel(classes))
%         [~,~,~] = mkdir([resFolder, classes{i}]);
%     end
%     for (i=1:numel(classes))
%        fileListClass = fileLists{i};
%        
%        ex = 1;
%        while(1)
%            file = [guessesFolder, classes{i}, '_', int2str(ex), '.mat'];
%            if(~exist(file,'file')) break; end
%            display(['Analyzing file: ', file]);
% 
%            [cleanedGuesses] = getLabels(file,equivLin,labels);
%            nStrokes = numel(cleanedGuesses);
%            
%            strokeEx = fileListClass{ex}(1:end-4);
%            
%            save([resFolder,resClass,'/',strokeEx, 'cleanedGuesses'], 'cleanedGuesses');
%            for (j=1:nStrokes)
%                
%                strokeFile = [strokesFolder, classes{i}, '-stroke/', strokeEx,'-',int2str(j), '.png'];
%                % need to invert for Mathias' pipeline
%                % black on white background
%                x=logical(1-imread(strokeFile));
%                if(j==1) temp = x;
%                else temp = temp & x;
%                end
%                
%                if(~isempty(cleanedGuesses{j}))
%                    guessedClasses = cleanedGuesses{j};
%                    for (k=1:numel(guessedClasses))
%                        resClass = classes{guessedClasses(k)};
%                        saveImFile = [resFolder,resClass,'/',strokeEx,'-stroke', int2str(j),'.png'];              
%                        imwrite(temp,saveImFile);
%                    end
%                end
% 
%             end
%            
%            ex=ex+1;
%        end   
%     end
% 
% end
