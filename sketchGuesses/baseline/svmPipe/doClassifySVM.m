function [model, probEstimates, predictLabels, fMax] = ...
         doClassifySVM(target, trainKern, testKern, trainLabelsGT, testLabelsGT, params)
    
    numFeat = size(trainKern,2);
    switch(params.svmErrTerm)
        case 'L1'
            doSvmTrain = @svmtrain;
            doSvmTest = @svmpredict;
        case 'L2'
            doSvmTrain = @svmtrainL2;
            doSvmTest = @svmpredictL2;
        otherwise
            error(['Unrecognized svm err option: ', params.svmErrterm]);
    end
    
    if(params.svmCross)
        cTry = [0.1, 1, 5, 10, 100, 1000]';
        wTry = [0.1, 1, 10, 50]'; % Error set to wTry * cTry
    else
        wTry = [];
        cTry = [1]';
    end
    
    if(~isfield('svmFeatCross',params))
        display(['svmfeatcross defaulting to false']);
        params.svmFeatCross = 0;
    end
    
    if(params.svmFeatCross)
        featCross = [0:0.1:1]';
    else
        featCross = 1/numFeat;
    end

    if (numFeat == 1)
        fTry = 1;
    else
        argStr = [];
        for (f=1:numFeat-1)
           argStr = [argStr, 'featCross'];
           if (f~=numFeat-1)
               argStr = [argStr, ','];
           end
        end
        eval(['fTry = allcomb(', argStr, ');']);
        fTry(:,numFeat) = 1 - sum(fTry,2);
    end
    
    for (i=1:size(trainLabelsGT,1))
        if(trainLabelsGT(i) == target)
            trainLabels(i,1) = 1;
        else
            trainLabels(i,1) = -1;
        end
    end
    trainRatio = sum(trainLabels == 1) / size(trainLabels,1);
    wTry = cat(1, wTry, 1/trainRatio);
    
    for (i=1:size(testLabelsGT,1))
        if(testLabelsGT(i) == target)
            testLabels(i,1) = 1;
        else
            testLabels(i,1) = -1;
        end
    end
    
%     for (w=1:size(wTry,1))
%         for (c=1:size(cTry,1))
%             
%             for (f=1:size(fTry,1))
%                 trainKernUse = 0;
%                 for (fr = 1:numFeat)
%                     trainKernUse = trainKernUse + fTry(f,fr)*trainKern{fr};
%                 end
%                 %chol(trainKernUse); %not always accurate
%                 KTrainSerial = [(1:size(trainKernUse,1))', trainKernUse]; % include sample serial number as first column
%                 %svmStr = sprintf('-v 10 -t 4 -b 1 -c %f -w1 %f', cTry(c), wTry(w));
%                 svmStr = sprintf('-t 4 -b 1 -c %f -w1 %f', cTry(c), wTry(w));
%                 classMax(w,c,f) = doSvmTrain(trainLabels, KTrainSerial, svmStr);
%             end
%         end
%     end

%     winVal = max(classMax(:));
%     [w,c,f] = ind2sub(size(classMax), find(classMax==winVal, 1));
    
%     WUse = wTry(w);
%     CUse = cTry(c);
%     fMax = fTry(f,:);

    WUse = wTry;
    CUse = cTry;
    fMax = fTry;

    trainKernUse = 0;
    for (fr = 1:numFeat)
        trainKernUse = trainKernUse + fMax(fr)*trainKern{fr};
    end
    testKernUse = 0;
    for (fr=1:numFeat)
        testKernUse = testKernUse + fMax(fr)*testKern{fr};
    end
    
    KTrainSerial = [(1:size(trainKernUse,1))', trainKernUse]; % include sample serial number as first column
    svmStr = sprintf('-t 4 -b 1 -c %f -w1 %f', CUse, WUse);
    model = doSvmTrain(trainLabels, KTrainSerial, svmStr);
    
    KTestSerial = [(1:size(testKernUse,1))', testKernUse]; % include sample serial number as first column
	[predictLabels, acc, probEstimates] = doSvmTest(testLabels, KTestSerial, model, '-b 1');

    % probEstimates has 2 columns. The 1st column is the probability of
    % a datapoint being assigned the label of whatever the first training
    % point's label was. So, if trainLabels(1,1) = 1, then 
    % probEstimates(:,1) is the probabiltiy of assigning to class 1. If
    % trainLabels(1,1) = -1, then probEstimates(:,1) is the probability of
    % assigning to class -1. Note that the meaning of probEstimates(:,1)
    % changes depending on trainLabels(1,1). By our contract, we must
    % report probability of a positive class assignment, so we switch
    % which column of probEstimates to take in accordance with 
    % trainLabels(1,1).
        % SVMlib takes first class in training labels as entry 1 of the class
    if ((trainLabels(1) ~= 1))
        probEstimates = probEstimates(:,2);
    else
        probEstimates = probEstimates(:,1);
    end
end

