function classifyTest(types, nStart, nTrials, C, R, patchSize, gridSpacing, setType, numTrainEx, numTestEx, penalty, deviceNum, strat, DO_SPARSE, USE_COLOUR,crossType,simTry)
    startup;
    
    if (size(types,1) == 1)
        types = types';
    end
    if (size(C,1) == 1)
       C = C'; 
    end
    if (size(R,1) == 1)
       R = R'; 
    end
    assert(size(R,1) == size(C,1));
    
    paramsOrig = initParams(setType);
    paramsOrig.C = C;
    paramsOrig.R = R;
    paramsOrig.patchSize = patchSize;
    paramsOrig.gridSpacing = gridSpacing;
    paramsOrig.numTrainEx = numTrainEx;
    paramsOrig.numTestEx = numTestEx;
    paramsOrig.penalty = penalty;
    paramsOrig.deviceNum = deviceNum;
    paramsOrig.strat=strat;
    paramsOrig.types = types;
    
    paramsClassifier = initClassifierParams(setType);
    paramsClassifier.DO_SPARSE = DO_SPARSE;
    paramsClassifier.USE_COLOUR = USE_COLOUR;
    paramsClassifier.crossType = crossType;
    if (exist('simTry', 'var'))
       paramsClassifier.simTry = simTry; 
    end
    
    [~,~] = mkdir(paramsClassifier.saveFolder); % Surpress warning messages
    
    classifierStr = toStringClassifier(paramsClassifier);
    kFeatCount = 1;
    for (n=nStart:nTrials+nStart-1)
        params = paramsOrig; % Copy over "static" fields....
        params.trialNum = n;
        
        stelFile = toStringInfer(params.dataSplitHeader, params);
        saveFile = [paramsClassifier.saveFolder, stelFile, classifierStr];
        
        if (~exist([saveFile,'.mat'],'file'))
            display(['Classifier file does not exist. Calculating...', saveFile]);
            params2 = params;
            load(toStringSplit(params.dataSplitHeader, params), 'params');
            params = copySplit(params,params2); clear param2;
            
            % [nEx, nFeatures]
            if (~paramsClassifier.DO_SPARSE)
                assert(params.strat == 0);
                trainFeatures = getQc(params,1);
                testFeatures = getQc(params,2);
            else
                load(toStringTrain(params.trainHeader, params), 'stels');
                computeCoeffs(params,1,stels,paramsClassifier);
                computeCoeffs(params,2,stels,paramsClassifier);
                
                trainFeatures = getCoeffs(params,paramsClassifier,1);
                testFeatures = getCoeffs(params,paramsClassifier,2);
            end
            trainFeaturesAll{kFeatCount,1} = bsxfun(@rdivide, trainFeatures, sum(trainFeatures,2));
            testFeaturesAll{kFeatCount,1} = bsxfun(@rdivide, testFeatures, sum(testFeatures,2));
            kFeatCount = kFeatCount + 1;
            
            if (paramsClassifier.USE_COLOUR)
                
                trainFeatures = getAllColourHist(params,paramsClassifier,1);
                testFeatures = getAllColourHist(params,paramsClassifier,2);
                
                trainFeaturesAll{kFeatCount,1} = bsxfun(@rdivide, trainFeatures, sum(trainFeatures,2));
                testFeaturesAll{kFeatCount,1} = bsxfun(@rdivide, testFeatures, sum(testFeatures,2));
                kFeatCount = kFeatCount + 1;
            end
            
            trainLabels = getLabels(params.trainSplit,params.types);
            testLabels = getLabels(params.testSplit,params.types);
            
            [model, probEstimates, classMap, sims] = ...
                classifySVM(paramsClassifier, trainFeaturesAll, testFeaturesAll, trainLabels, testLabels);
            
            [acc,confuse,allWinners] = getPerform(probEstimates, testLabels, classMap);
            
            save(saveFile, 'model', 'probEstimates', 'acc', 'confuse', 'allWinners', 'testLabels', 'classMap', 'sims', '-v7.3');
        else
            display(['Classifier file exists. Loading...', saveFile]);
            load(saveFile, 'model', 'probEstimates', 'acc', 'confuse', 'allWinners', 'testLabels', 'classMap', 'sims');
        end
        display('allWinners|labels:');
        display([allWinners,testLabels])
        display(['Accuracy: ', num2str(acc)]);
    end
end

function computeCoeffs(params,learnState,stels,paramsClassifier) 
    [N,R,C] = size(stels);
    nColours = params.nColours;
    W = getSparseWeights(params);
    pDims = computePDims(params.imSize,params.patchSize,params.gridSpacing);
    
    switch(learnState)
        case 1
            splitUse = params.trainSplit;
            fileHeader = [params.saveFolder, toStringInfer(params.inferTrainHeader, params),'Batch'];
            dataHeader = params.dataTrainHeader;
            sFile = [params.saveFolder,toStringInfer(params.inferTrainHeader, params)];
        case 2
            splitUse = params.testSplit;
            fileHeader = [params.saveFolder, toStringInfer(params.inferTestHeader, params),'Batch'];
            dataHeader = params.dataTestHeader;
            sFile = [params.saveFolder,toStringInfer(params.inferTestHeader, params)];
        otherwise
            error(['Unrecognized learnState: ', int2str(learnState)]);
    end
    M = countEx(splitUse);
    
    mb = 0;
    mmCounter = 0;
    while(mmCounter < M)
        mb = mb+1;
        if(mod(mb,1)==0)
            display(['On batch: ', int2str(mb)]);
        end

        switch(params.strat)
            case 0
                load([fileHeader, int2str(mb)], 'meanStel', 'patchInd');
            case 1
                patchInd = 0; % hack
            otherwise
                error(['Bad strategy: ', int2str(params.strat)]);
        end
        ids = unique(patchInd);
        
        for (m=1:numel(ids))
            
            mmCounter = mmCounter + 1;
            indsm = (patchInd==ids(m));
            
            sFileUse = [sFile,'im',int2str(mmCounter)];
            if(exist([sFileUse,'.mat'],'file'))
                display(['Coefficient file ', sFileUse, ' exists. Continuing...']);
                continue;
            end
            
            if (params.strat == 1)
                [meanStel,patchInd] = sparseStel(params,learnState,stels,mmCounter);
            end
            
            tic
            % Construct dictionary
            D = cell(pDims(1),pDims(2));
            switch(params.strat)
                case 0
                    meanStelUse = meanStel(:,:,indsm);
                    meanStelUse = reshape(permute(meanStelUse,[3,1,2]), [pDims,nColours,R]);
                    for (xx=1:pDims(1))
                        for(yy=1:pDims(2))
                            meanTemp = meanStelUse(xx,yy,:,:);
                            meanTemp = reshape(meanTemp,[size(meanTemp,3),size(meanTemp,4)])';
                            D{xx,yy} = reshape(tensorMatRightMult(stels,meanTemp),[N*nColours,C]);
                        end
                    end
                case 1
                    meanStelUse = reshape(permute(meanStel,[4,1,2,3]),...
                                                  [pDims,nColours,R,C]);

                    for (xx=1:pDims(1))
                        for(yy=1:pDims(2))
                            meanTemp = meanStelUse(xx,yy,:,:,:);
                            meanTemp = reshape(meanTemp,[size(meanTemp,3),size(meanTemp,4),size(meanTemp,5)]);
                            meanTemp = permute(meanTemp,[2,1,3]); %[R,nColours,C]
                            
                            dtemp = zeros(N,nColours,C);
                            for (c=1:C)
                                dtemp(:,:,c) = stels(:,:,c)*meanTemp(:,:,c);
                            end
                            
                            D{xx,yy} = reshape(dtemp,[N*nColours,C]);
                        end
                    end
                                                    
                otherwise
                    error(['Bad strategy: ', int2str(strat)]);
            end
  
            coeffs = zeros(pDims(1),pDims(2),C);
            % Is this the right way for patch dims?
            % data: [nPixels, nColors, nPatches]
            [data] = getNextData(params, ...
                                 dataHeader, ...
                                 splitUse, ...
                                 params.types, ...
                                 mmCounter,mmCounter);
            data = permute(reshape(data,[N*nColours,size(data,3)]),[2,1]);
            data = reshape(data,[pDims,N*nColours]);
        
            for (xx=1:pDims(1))
                for(yy=1:pDims(2))
                    coeffs(xx,yy,:) = doGetCoeffs(squeeze(data(xx,yy,:)),D{xx,yy},W,paramsClassifier);
                end
            end
            toc
            save(sFileUse, 'coeffs','-v7.3');
        end
    end
end

function res = getCoeffs(params,paramsClassifier,learnState)
    switch(learnState)
        case 1
            M = countEx(params.trainSplit);
            sFile = [params.saveFolder,toStringInfer(params.inferTrainHeader, params)];
        case 2
            M = countEx(params.testSplit);
            sFile = [params.saveFolder,toStringInfer(params.inferTestHeader, params)];
        otherwise
            error(['Unrecognized learnState: ', int2str(learnState)]);
    end
    
    C = sum(params.C);
    nLevels = sum(prod(paramsClassifier.pooling,2));
    res = zeros(M,2*C*nLevels);
    
    for (m=1:M)
        load([sFile,'im',int2str(m)],'coeffs');
        if (mod(m,10) == 0)
            display(['Loading coefficients from file: ', int2str(m) , '/', int2str(M)]);
        end
        coeffs = full(coeffs);
        temp = doPooling(coeffs, paramsClassifier.pooling, paramsClassifier.poolingMode);
        res(m,1:C*nLevels) = max(temp,0);
        res(m,C*nLevels+1:end) = -min(temp,0);        
    end
    
end

function res = doGetCoeffs(data,D,W,classifierParams)
    D = double(D);
    classifierParams.L = min(size(D));
    res = mexLassoWeighted(data,D,W,classifierParams);    
end

function pC = getSparseWeights(params)
    pC = zeros(sum(params.C,1));
    cStart = 1;
    for (c=1:size(params.C,1))
        %penaltyUse = exp(-params.penalty*(params.R(c)^2));
        penaltyUse = exp(1*(0.1*params.R(c)^2)); %higher penalty on more complex regions
        pC(cStart:cStart+params.C(c)) = penaltyUse;
        cStart = cStart+params.C(c);
    end
    pC = pC/sum(pC);
    pC = pC/min(pC); % normalize so smallest is 1
end

function res = getQc(params,learnState)
    paramsClassifier = initClassifierParams;
    switch(learnState)
        case 1
            M = countEx(params.trainSplit);
            fileHeader = [toStringInfer(params.inferTrainHeader, params), 'Batch'];
        case 2
            M = countEx(params.testSplit);
            fileHeader = [toStringInfer(params.inferTestHeader, params),'Batch'];
        otherwise
            error(['Bad learnState: ', int2str(learnState)]);
    end
    
    C = sum(params.C);
    nFeats = sum(prod(paramsClassifier.pooling,2));
    res = zeros([M,C*nFeats]);
    pDims = computePDims(params.imSize,params.patchSize,params.gridSpacing);
                
    mb = 0;
    mmCounter = 0;
    while(mmCounter < M)
        mb = mb+1;
        if(mod(mb,1)==0)
            display(['On batch: ', int2str(mb)]);
        end
        
        fileUse = [fileHeader, int2str(mb)];
        load(fileUse, 'log_qC', 'patchInd');
        ids = unique(patchInd);
        
        for (m=1:numel(ids))
            mmCounter = mmCounter+1;
            indsm = (patchInd==ids(m));
            
            log_qCUse = log_qC(:,indsm);
            qC = permute(exp(log_qCUse),[2,1]);
            temp = doPooling(reshape(qC,[pDims,C]),...
                             paramsClassifier.pooling,...
                             paramsClassifier.poolingMode);
            res(mmCounter,:) = temp;
        end
    end

end

