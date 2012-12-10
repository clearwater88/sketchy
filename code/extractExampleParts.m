function [partsPosAll,partsNegAll] = extractExampleParts(classNum,numIm)

    TOT_IM = 40;
    imsUse = randperm(TOT_IM)-1;
    imsUse = imsUse(1:numIm);
    
    nNeg = 20;
    
    partsPosAll = {};
    partsNegAll = {};
    
    for (kk=1:numel(classNum))
        partNum = classNum(kk);
        display(['On object class: ', int2str(partNum)]);
        
        [~,objType, rootDir, iStart] = getClassData(partNum);
        
        partsPos = {};
        partsNeg = {};

        for (i=1:numel(imsUse))
            display(['On image: ', int2str(i), ' of ', int2str(numel(imsUse))]);
            num = iStart+imsUse(i);
            display(['Loading file number: ', int2str(num)]);
            
            loadFileBB = ['data/', objType, int2str(num),'.mat'];
            
            im = double(getIm([rootDir,int2str(num)]));
            load(loadFileBB,'bbAll');
            
            % fix to image size
            bbAll(:,1) = max(bbAll(:,1),1);
            bbAll(:,2) = max(bbAll(:,2),1);
            bbAll(:,3) = min(bbAll(:,3),size(im,1));
            bbAll(:,4) = min(bbAll(:,4),size(im,2));
            
            % crop to smallest image size
            bbAllCrop = zeros(size(bbAll));
            for (p=1:size(bbAll,1))
                partTemp = im(bbAll(p,1):bbAll(p,3),bbAll(p,2):bbAll(p,4));
                bbAllCrop(p,1) = find(sum(partTemp,2) > 0,1,'first') + bbAll(p,1)-1;
                bbAllCrop(p,3) = find(sum(partTemp,2) > 0,1,'last') + bbAll(p,1)-1;
                
                bbAllCrop(p,2) = find(sum(partTemp,1) > 0,1,'first') + bbAll(p,2)-1;
                bbAllCrop(p,4) = find(sum(partTemp,1) > 0,1,'last') + bbAll(p,2)-1;
            end
            
            for (p=1:size(bbAllCrop,1))
                partTemp = getPartTemp(bbAllCrop,p,im);
                partsPos{end+1,1} = partTemp;
            end
            partNegTemp = getNegatives(im,bbAll,nNeg);
            partsNeg = cat(1,partsNeg,partNegTemp);
            
            % Stroke based?
            partsNegStroke = getStrokeNeg(partNum,num);
            partsNeg = cat(1,partsNeg,partsNegStroke);
        
        end
        
        partsPosAll = cat(1,partsPosAll,partsPos);
        partsNegAll = cat(1,partsNegAll,partsNeg);
    end
end

function partTemp = getPartTemp(bbAllCrop,p,im)
    bbUse = bbAllCrop(p,:);
    bbAllCrop(p,:) = [];
    
    isContained = (bbAllCrop(:,1) > bbUse(1)) & ...
                  (bbAllCrop(:,2) > bbUse(2)) & ...
                  (bbAllCrop(:,3) < bbUse(3)) & ...
                  (bbAllCrop(:,4) < bbUse(4));
    
    containedIm = zeros(size(im));
    for (i=1:numel(isContained))
        if (isContained(i) == 0)
            continue;
        end
        bb = bbAllCrop(i,:);
        containedIm(bb(1):bb(3),bb(2):bb(4)) = ...
                      containedIm(bb(1):bb(3),bb(2):bb(4)) + ...
                      im(bb(1):bb(3),bb(2):bb(4));
    end
    partTemp = im - containedIm;
    partTemp = max(partTemp,0);
    partTemp = partTemp(bbUse(1):bbUse(3),bbUse(2):bbUse(4));
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

