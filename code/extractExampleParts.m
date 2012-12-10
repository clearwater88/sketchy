function [partsPosAll,partsNegAll] = extractExampleParts(partNums)

    numIm = 40;
    nNeg = 20;

    partsPosAll = {};
    partsNegAll = {};

    for (kk=1:numel(partNums))
        partNum = partNums(kk);
        display(['On object class: ', int2str(partNum)]);
        
        [~,objType, rootDir, iStart] = getClassData(partNum);

        partsPos = {};
        partsNeg = {};
        for (i=iStart:iStart+numIm-1)
            display(['On image: ', int2str(i-iStart+1)]);
            loadFileBB = ['data/', objType, int2str(i),'.mat'];

            im = double(getIm([rootDir,int2str(i)]));
            load(loadFileBB,'bbAll');

            bbAll(:,1) = max(bbAll(:,1),1);
            bbAll(:,2) = max(bbAll(:,2),1);
            bbAll(:,3) = min(bbAll(:,3),size(im,1));
            bbAll(:,4) = min(bbAll(:,4),size(im,2));

            for (p=1:size(bbAll,1))
                partTemp = im(bbAll(p,1):bbAll(p,3),bbAll(p,2):bbAll(p,4));
                minY = find(sum(partTemp,2) > 0,1,'first');
                minX = find(sum(partTemp,1) > 1,1,'first');
                maxY = find(sum(partTemp,2) > 0,1,'last');
                maxX = find(sum(partTemp,1) > 1,1,'last');

                partTemp = partTemp(minY:maxY,minX:maxX);
                partsPos{end+1,1} = partTemp;
            end
            partNegTemp = getNegatives(im,bbAll,nNeg);
            partsNeg = cat(1,partsNeg,partNegTemp);
        end
        
        partsPosAll = cat(1,partsPosAll,partsPos);
        partsNegAll = cat(1,partsNegAll,partsNeg);
        
        % Stroke based?
        partsNegStroke = getStrokeNeg(partNum);
        partsNegAll = cat(1,partsNegAll,partsNegStroke);
    end
end

function res = getNegatives(im,bbAll,nNeg)
    MINWIN = (51 -1)/2;
    MAXWIN = (301 - 1) /2;
    OVERLAP_THRESH = 0.5;
    
    imStack = zeros([size(im),size(bbAll,1)]);
    for (i=1:size(bbAll,1))
       imStack(bbAll(i,1):bbAll(i,3),bbAll(i,2):bbAll(i,4),i) = 1; 
    end
    areasStack = sum(sum(imStack,1),2);
    
    res = {};
    for (i=1:nNeg)
        px = find (im(:) ~= 0);
        ind = randi(numel(px),1);

        [y,x] = ind2sub(size(im),px(ind));
        dims = round(MINWIN + (MAXWIN-MINWIN)*rand(2,1));
        bbNeg = [max(1,y-dims(1)), max(1,x-dims(2)), ...
                 min(size(im,1),y+dims(1)), min(size(im,2),x+dims(2))];
        imNeg = zeros(size(im));
        imNeg(bbNeg(1):bbNeg(3),bbNeg(2):bbNeg(4)) = 1;
        areaImNeg = sum(imNeg(:));
        
        areaInt = double(bsxfun(@and,imStack,imNeg));
        areaInt = sum(sum(areaInt,1),2);
        percentOverlap = 2*areaInt./(areasStack+areaImNeg);
        
        if (any(percentOverlap > OVERLAP_THRESH))
            continue;
        end

        res{end+1,1} = im(bbNeg(1):bbNeg(3),bbNeg(2):bbNeg(4));
    end
end

