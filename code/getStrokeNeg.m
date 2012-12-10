function partsNeg = getStrokeNeg(partNum,num)
    [~,objType,rootDir,~] = getClassData(partNum);

    negPerIm = 20;
    OVERLAP_THRESH = 0.5;
    
    ALPHA = 0.1;
    DECAY = 0.5;
    SAMPLES = 40;
    MINDIM = 51;
    
    partsNeg = {};
    [~,strokeStack] = getIm([rootDir,int2str(num)]);
    
    imSize = [size(strokeStack,1),size(strokeStack,2)];
    nStrokes = size(strokeStack,3);
    
    loadFileBB = ['data/', objType, int2str(num),'.mat'];
    load(loadFileBB,'bbAll');
    imStack = zeros([imSize,size(bbAll,1)]);
    for (i=1:size(bbAll,1))
        startY = max(bbAll(i,1),1);
        startX = max(bbAll(i,3),1);
        
        endY = min(bbAll(i,2),imSize(1));
        endX = min(bbAll(i,4),imSize(2));
        
        imStack(startY:endY,startX:endX,i) = 1;
    end
    
    strokeClusters=sampleddCRP(nStrokes,ALPHA,DECAY,SAMPLES);
    
    strokeIms = getStrokeIms(strokeStack,strokeClusters);
    
    negFound = 0;
    for (p=1:size(strokeIms,3))
        partTemp = strokeIms(:,:,p);
        minY = find(sum(partTemp,2) > 0,1,'first');
        minX = find(sum(partTemp,1) > 1,1,'first');
        maxY = find(sum(partTemp,2) > 0,1,'last');
        maxX = find(sum(partTemp,1) > 1,1,'last');
        
        if( ((maxY-minY) < MINDIM) || ...
            ((maxX-minX) < MINDIM) )
            continue;
        end
        [percentOverlap] = findOverlap(imStack,[minY,minX,maxY,maxX],imSize);
        if (any(percentOverlap > OVERLAP_THRESH)) continue; end;
        
        partTemp = partTemp(minY:maxY,minX:maxX);
        partsNeg{end+1,1} = partTemp;
        negFound = negFound+1;
        if(negFound >= negPerIm)
            break;
        end
    end
end

function res = getStrokeIms(strokeStack,strokeClusters)
    nIm = 0;
    for (i=1:numel(strokeClusters))
       nIm = nIm + numel(strokeClusters{i}); 
    end
    imSize = [size(strokeStack,1),size(strokeStack,2)];
    res = zeros([imSize,nIm]);

    counter = 1;
    for (i=1:numel(strokeClusters))
       st = strokeClusters{i};
       for (j=1:numel(st))
           stUse = st{j};
           temp = sum(strokeStack(:,:,stUse),3);
           res(:,:,counter) = double(temp>0);
           a = res(:,:,counter);
           assert(sum(a(:)) > 0);
           
           counter = counter+1;
       end

    end
end
