function params = initClassifierParams()
    
    % Used for svm ONLY
    params.svmKernType = 'dot'; %intersect, spm, 'dot'
    
    params.svmErrTerm = 'L1'; % L1, L2. Error penalty
    
    params.svmCross = 0;
    params.svmFeatCross = 0;
    params.svmNorm = 1;
    
    params.poolingMode = 0; % 0: average, 1: max, 2: sum
    
    % 0 0 is special flag: no pooling on that level
    params.pooling = [0 0];

end

