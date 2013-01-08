function [partsPosAll,partsNegAll,imsUse] = extractExampleParts(classNum,numIm,trialNum)
    TOT_IM = 40;
    MIN_DIM = 28;
    
    nNeg = 20;
    nNegStroke = 20;
    
    partsPosAll = {};
    partsNegAll = {};

    partsFile = sprintf('parts_C%d_nIm%d_t%d',classNum,numIm,trialNum);
    
    if(exist([partsFile,'.mat'],'file'))
        display(['Parts file exists. Loading...']);
        load(partsFile,'partsPosAll','partsNegAll','imsUse');
        return;
    end
    display(['Parts file does not exist. Computing...']);

    [~,objType, rootDir, iStart] = getClassData(classNum);
    
    partsPos = {};
    partsNeg = {};
    
    temp = randperm(TOT_IM)-1;
    imsUse = temp(1:numIm);
    
    nImsUse = numel(imsUse);
    for (i=1:nImsUse)
        display(['On image: ', int2str(i), ' of ', int2str(nImsUse)]);
        num = iStart+imsUse(i);
        display(['Loading file number: ', int2str(num)]);
        
        loadFileBB = ['data/', objType, int2str(num),'.mat'];
        
        [im,strokesStack] = getIm([rootDir,int2str(num)]);
        im = double(im);
        
        load(loadFileBB,'bbAll');
        
        % fix to image size
        bbAll(:,1) = max(bbAll(:,1),1);
        bbAll(:,2) = max(bbAll(:,2),1);
        bbAll(:,3) = min(bbAll(:,3),size(im,1));
        bbAll(:,4) = min(bbAll(:,4),size(im,2));
        
        % crop to smallest image size
        bbAllCrop = cropBB(im,bbAll);
        
        for (p=1:size(bbAllCrop,1))
            if (((bbAllCrop(p,3)-bbAllCrop(p,1)) < MIN_DIM) || ...
                ((bbAllCrop(p,4)-bbAllCrop(p,2)) < MIN_DIM))
                continue
            end
            partTemp = getPartTemp(bbAllCrop,p,im);
            partsPos{end+1,1} = partTemp;
        end
        partNegTemp = getNegatives(im,bbAll,nNeg,MIN_DIM);
        partsNeg = cat(1,partsNeg,partNegTemp);
        
        % Stroke based?
        partsNegStroke = getStrokeNeg(strokesStack,bbAll,nNegStroke,MIN_DIM);
        partsNeg = cat(1,partsNeg,partsNegStroke);
        
    end
    
    partsPosAll = cat(1,partsPosAll,partsPos);
    partsNegAll = cat(1,partsNegAll,partsNeg);
    save(partsFile,'partsPosAll','partsNegAll','imsUse','-v7.3');
end

function partTemp = getPartTemp(bbAllCrop,p,im)
    bbUse = bbAllCrop(p,:);
   
    %disable contained checks
%    bbAllCrop(p,:) = [];
%     isContained = (bbAllCrop(:,1) > bbUse(1)) & ...
%                   (bbAllCrop(:,2) > bbUse(2)) & ...
%                   (bbAllCrop(:,3) < bbUse(3)) & ...
%                   (bbAllCrop(:,4) < bbUse(4));
    
%     containedIm = zeros(size(im));
%     for (i=1:numel(isContained))
%         if (isContained(i) == 0)
%             continue;
%         end
%         bb = bbAllCrop(i,:);
%         containedIm(bb(1):bb(3),bb(2):bb(4)) = ...
%                       containedIm(bb(1):bb(3),bb(2):bb(4)) + ...
%                       im(bb(1):bb(3),bb(2):bb(4));
%     end
%     partTemp = im - containedIm;
%     partTemp = max(partTemp,0);
    %disable contained checks
    
    partTemp = im;
    partTemp = partTemp(bbUse(1):bbUse(3),bbUse(2):bbUse(4));
end

function res = getNegatives(im,bbAll,nNeg,MINWIN)
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

        bbNeg = cropBB(im,bbNeg);
        if (((bbNeg(3)-bbNeg(1)) < MINWIN) || ...
            ((bbNeg(4)-bbNeg(2)) < MINWIN))
            continue;
        end;
        
        res{end+1,1} = im(bbNeg(1):bbNeg(3),bbNeg(2):bbNeg(4));
    end
end

