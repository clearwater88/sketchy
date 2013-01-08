function [posFeat,negFeat] = getPartFeatures(classes,params,trialNum,featFile)
    
    posFeatAll = cell(numel(classes),1);
    negFeatAll = cell(numel(classes),1);

    for (cc=1:numel(classes))
        c_featFile = ['C_', int2str(classes(cc)), featFile];
        if (~exist([c_featFile,'.mat'],'file'))
            display(['Feature file for class ', int2str(classes(cc)), ' does not exist. Computing...']);
            [partsPos,partsNeg,imsUse] = extractExampleParts(classes(cc),params.nIm,trialNum);

            posFeat = getFeatures(partsPos,params);
            negFeat = getFeatures(partsNeg,params);

            save(c_featFile,'posFeat','negFeat','imsUse','-v7.3');

            posFeatAll{cc} = posFeat;
            negFeatAll{cc} = negFeat;
        else
            display(['Feature file ', c_featFile, ' exists. Loading...']);
            load(c_featFile,'posFeat','negFeat','imsUse');

            posFeatAll{cc} = posFeat;
            negFeatAll{cc} = negFeat;
        end
    end
    posFeat = []; negFeat = [];
    for (cc=1:numel(posFeatAll))
        posFeat = cat(1,posFeat,posFeatAll{cc});
    end
    for (cc=1:numel(negFeatAll))
        negFeat = cat(1,negFeat,negFeatAll{cc});
    end

end

