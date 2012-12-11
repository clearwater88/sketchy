function [model, probEstimates] = ...
         doClassifySVM(target, trainFeaturesAll, testFeaturesAll, trainLabels, testLabels, params)
     
     if(params.svmCross)
         cTry = [0.01, 0.1, 0.5, 1, 5, 10,100]';
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
     
     classMax = zeros(size(cTry,1),1);
     
     display('Getting gram matrices');
     switch(params.svmKern)
         case 0
             display('Dot product');
             trainKern = dotKer(trainFeaturesAll, trainFeaturesAll);
             testKern = dotKer(testFeaturesAll, trainFeaturesAll);
         case 1
             display('Intersection');
             trainKern = histInter(trainFeaturesAll, trainFeaturesAll);
             testKern = histInter(testFeaturesAll, trainFeaturesAll);
         otherwise
             error('Bad params.svmKern');
     end
     display('Done getting gram matrices');
     
     trainKernSerial = getKern(trainKern, 0);
     
     for (c=1:size(cTry,1))
         %svmStr = sprintf('-m 500 -v 5 -t 4 -b 1 -c %f -w1 %f', cTry(c), wTry);
         svmStr = sprintf('-m 1000 -q -t 4 -b 1 -c %f -w1 %f', cTry(c), wTry);
         for (ii=1:2) %average over 2 cross-val splits trials
             classMax(c,1) = classMax(c,1)+do_binary_cross_validation(trainLabels,trainKernSerial,svmStr,2,params.crossType);
         end
     end

     
     winVal = max(classMax(:));
     [c] = ind2sub(size(classMax), find(classMax==winVal, 1));
     
     CUse = cTry(c);
     svmStr = sprintf('-t 4 -b 1 -q -c %f -w1 %f', CUse, wTry);
     model = svmtrain(trainLabels, trainKernSerial, svmStr);
     
     
     testKernSerial = getKern(testKern, 0);
     [~, ~, probEstimates] = svmpredict(testLabels, testKernSerial, model, '-b 1');

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

function res = getKern(kernAll, checkCol)
    if (checkCol)
        chol(kernAll);
    end
    res = [(1:size(kernAll,1))', kernAll]; % include sample serial number as first column
end
