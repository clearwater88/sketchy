function [res] = getGramMat(params, features1, features2)
    switch(params.svmKern)
        case 0
            res = dotKer(features1, features2);
        case 1
            features1 = double(features1);
            features2 = double(features2);
            res = histInter(features1, features2);
        case 2
            features1 = double(features1);
            features2 = double(features2);
            res = spm(features1, ...
                      features2, ...
                      params.C, ...
                      params);
        otherwise
            error(['Unknown svm kernel type: ', int2str(params.svmKern)]);
    end
end

