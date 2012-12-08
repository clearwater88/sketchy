function [model, probEstimates, simWin] = ...
         doClassifySVM(target, trainFeaturesAll, testFeaturesAll, trainLabels, testLabels, params)
     
     if (size(trainFeaturesAll,1) > 1)
         if((isfield(params,'simTry')) && (params.simTry ~= -1))
             simTry= params.simTry;
         else
             simTry = [0:0.1:1]';
         end
     else
         simTry = 1;
     end
     
     if(params.svmCross)
         cTry = [0.01, 0.1, 0.5, 1, 5, 10]';
     else
         cTry = [1]';
     end

     temp = ones(size(trainLabels));
     temp(trainLabels ~= target) = -1;
     trainLabels = temp;
     
     temp = ones(size(testLabels));
     temp(testLabels ~= target) = -1;
     testLabels = temp;
     
     trainRatio = sum(trainLabels == 1) / size(trainLabels,1);
     wTry = 1/trainRatio;
     
     classMax = zeros(size(cTry,1),size(simTry,1));
     
     if (params.svmKern == 3) % dot product, lots of data
         display(['Invoking liblinear...']);

         if (numel(simTry)*numel(cTry) == 1)
            classMax(1,1) = 1; % no need to cross validate stuff; there's only 1 option
         else
             for (s=1:size(simTry,1))    
                 trainFeats = weightUp(trainFeaturesAll, simTry(s));
                 for (c=1:size(cTry,1))
                     svmStr = sprintf('-s 1 -B 1 -q -c %f -w1 %f -v 5', cTry(c), wTry);
                     for (ii=1:1) %average over 1 cross-val splits trials
                         classMax(c,s) = classMax(c,s)+trainLibSVM(trainLabels,sparse(trainFeats),svmStr);
                         %classMax(c,s) = classMax(c,s)+do_binary_cross_validation(trainLabels,sparse(trainFeats),svmStr,5,params.crossType);
                     end
                 end
             end
         end
     else
         trainKernAll = cell(size(trainFeaturesAll,1),1);
         testKernAll = cell(size(testFeaturesAll,1),1);
         for (k=1:size(trainFeaturesAll,1))
             trainKernAll{k,1} = getGramMat(params,trainFeaturesAll{k},trainFeaturesAll{k});
             testKernAll{k,1} = getGramMat(params,testFeaturesAll{k},trainFeaturesAll{k});
         end
         
         for (s=1:size(simTry,1))

             trainKernSerial = getKern(trainKernAll, simTry(s),1);

             for (c=1:size(cTry,1))
                 %svmStr = sprintf('-m 500 -v 5 -t 4 -b 1 -c %f -w1 %f', cTry(c), wTry);
                 svmStr = sprintf('-m 1000 -q -t 4 -b 1 -c %f -w1 %f', cTry(c), wTry);
                 for (ii=1:3) %average over 3 cross-val splits trials
                     classMax(c,s) = classMax(c,s)+do_binary_cross_validation(trainLabels,trainKernSerial,svmStr,5,params.crossType);
                 end
             end
         end
     end
     
     winVal = max(classMax(:));
     [c,s] = ind2sub(size(classMax), find(classMax==winVal, 1));
     
     CUse = cTry(c);
     simWin = simTry(s);
     
     if (params.svmKern == 3) % dot product, lots of data
         trainFeats = weightUp(trainFeaturesAll, simWin);
         svmstr = sprintf('-s 1 -B 1 -q -c %f -w1 %f', cTry(c), wTry);
         model = trainLibSVM(trainLabels,sparse(trainFeats),svmstr);
     else
         trainKernSerial = getKern(trainKernAll, simWin,1);
         svmStr = sprintf('-t 4 -b 1 -q -c %f -w1 %f', CUse, wTry);
         model = svmtrain(trainLabels, trainKernSerial, svmStr);
     end
     
     if (params.svmKern == 3) % dot product, lots of data
         testFeats = weightUp(testFeaturesAll, simWin);
         svmstr = sprintf('-b 1');
         [~, ~, probEstimates]=predictLibSVM(testLabels, sparse(testFeats), model, svmstr);
     else
         testKernSerial = getKern(testKernAll, simWin,0);
         [~, ~, probEstimates] = svmpredict(testLabels, testKernSerial, model, '-b 1');
     end
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

function res = getKern(kernAll, wSim, checkCol)
    res = wSim*kernAll{1};
    if (size(kernAll,1) > 1)
        res = res + (1-wSim)*kernAll{2};
    end
    if (checkCol)
        chol(res);
    end
    res = [(1:size(res,1))', res]; % include sample serial number as first column
end

function trainFeats = weightUp(ft, wSim)
    totNumFeats = 0;
    ft{1} = wSim*ft{1};
    totNumFeats = totNumFeats + size(ft{1},2);
    if (size(ft,1) > 1)
        ft{2} = (1-wSim)*ft{2};
        totNumFeats = totNumFeats + size(ft{2},2);
    end
    trainFeats = zeros(size(ft{1},1), totNumFeats);
    
    start = 1;
    for (ss=1:size(ft,1))
        nf = size(ft{ss},2);
        trainFeats(:,start:start+nf-1) = ft{ss};
        start = start + nf;
    end
    
end
