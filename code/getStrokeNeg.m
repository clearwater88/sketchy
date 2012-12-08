function partsNeg = getStrokeNeg(partNum)
    [~,objType,rootDir,iStart] = getClassData(partNum);
    numIm = 10;
    negPerIm = 20;
    OVERLAP_THRESH = 0.5;
    
    ALPHA = 0.1;
    DECAY = 0.5;
    THIN = 200;
    BURNIN= 1000;
    SAMPLES = 10000;
    MINDIM = 51;
    
    partsNeg = {};
    for (i=iStart:iStart+numIm-1)
        display(['On image: ', int2str(i-iStart+1)]);
        negFound = 0;
        [~,strokeStack] = getIm([rootDir,int2str(i)]);

        
        imSize = [size(strokeStack,1),size(strokeStack,2)];
        nStrokes = size(strokeStack,3);
        
        loadFileBB = ['data/', objType, int2str(i),'.mat'];
        load(loadFileBB,'bbAll');        
        imStack = zeros([imSize,size(bbAll,1)]);
        for (i=1:size(bbAll,1))
            imStack(bbAll(i,1):bbAll(i,3),bbAll(i,2):bbAll(i,4),i) = 1;
        end
        

        strokeClusters=sampleddCRP(nStrokes,ALPHA,DECAY,SAMPLES);
        strokeClusters(1:BURNIN) = [];
        strokeClusters = strokeClusters(1:THIN:numel(strokeClusters));
        
        strokeIms = getStrokeIms(strokeStack,strokeClusters);
        
        for (p=1:size(strokeIms,3))
            partTemp = strokeIms(:,:,p);
            minY = find(sum(partTemp,2) > 0,1,'first');
            minX = find(sum(partTemp,1) > 1,1,'first');
            maxY = find(sum(partTemp,2) > 0,1,'last');
            maxX = find(sum(partTemp,1) > 1,1,'last');

            if( ((maxY-minY) < MINDIM) || ...
                 ((maxX-minX) < MINDIM))
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
           temp = zeros(imSize);
           for (k=1:numel(stUse))
              temp = temp + strokeStack(:,:,stUse(k)); 
           end
           res(:,:,counter) = double(temp>0);
           a = res(:,:,counter);
           assert(sum(a(:)) > 0);
           
           counter = counter+1;
       end

    end
end
