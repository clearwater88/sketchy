function partsNeg = getStrokeNeg(strokesStack,bbAll,numNeg,MIN_DIM)

    OVERLAP_THRESH = 0.5;
    
    ALPHA = 0.1;
    DECAY = 0.4;
    
    partsNeg = {};
    
    imSize = [size(strokesStack,1),size(strokesStack,2)];
    nStrokes = size(strokesStack,3);
    
    imStack = zeros([imSize,size(bbAll,1)]);
    for (i=1:size(bbAll,1))
        startY = max(bbAll(i,1),1);
        startX = max(bbAll(i,3),1);
        
        endY = min(bbAll(i,2),imSize(1));
        endX = min(bbAll(i,4),imSize(2));
        
        imStack(startY:endY,startX:endX,i) = 1;
    end
    
    negFound = 0;
    attempts = 0;
    while ((negFound < numNeg) && attempts < 10)
        strokeClusters=sampleddCRP(nStrokes,ALPHA,DECAY,1);
        strokeIms = getStrokeIms(strokesStack,strokeClusters);
        attempts = attempts+1;
        for (p=1:size(strokeIms,3))
            partTemp = strokeIms(:,:,p);
            
            [bbCrop] = cropBB(partTemp,[1,1,size(strokeIms,1),size(strokeIms,2)]);

            if( ((bbCrop(3)-bbCrop(1)) < MIN_DIM) || ...
                ((bbCrop(4)-bbCrop(2)) < MIN_DIM) )
                continue;
            end
            [percentOverlap] = findOverlap(imStack,bbCrop,imSize);
            if (any(percentOverlap > OVERLAP_THRESH)) continue; end;

            partTemp = partTemp(bbCrop(1):bbCrop(3),bbCrop(2):bbCrop(4));
            partsNeg{end+1,1} = partTemp;
            negFound = negFound+1;
            if(negFound >= numNeg)
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
           temp = sum(strokeStack(:,:,stUse),3);
           res(:,:,counter) = double(temp>0);
           a = res(:,:,counter);
           assert(sum(a(:)) > 0);
           
           counter = counter+1;
       end

    end
end
