function [trainInds, testInds] = splitData(nData,nTrainPerc,nTestPerc,trainMask)
% trainMask must be nData x 1. 1 where it is OK to train on, 0 otherwise
    
    assert(nTrainPerc+nTestPerc <= 1.000001);
    inds = randperm(nData);

    nTrain = floor(nData*nTrainPerc);
    nTest = floor(nData*nTestPerc);
    testInds = inds(nTrain+1:nTrain+nTest);
    
    trainInds = inds(1:nTrain);
    trainMaskInds = trainMask(trainInds);
    trainInds(trainMaskInds==0) = [];

end

